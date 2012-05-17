function y = feval(this,f,varargin)
%FEVAL  Evaluates a function at each grid point.
%
%   Y = D.FEVAL(FCN,ARG1,...,ARGN) evaluates
%   FCN(ARG1,...,ARGN) at each grid point of the 
%   data set D and returns the cell array Y of 
%   function values.  The function arguments can
%   be data set variables (@variable objects)
%   or static values.
%
%   D.FEVAL(FCN,ARG1,...,ARGN,'-output',VAR)
%   writes the result directly into some variable 
%   VAR of the data D.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/12/22 18:14:41 $

% Look for '-output' flag
idx = find(strcmp(varargin,'-output'));
RedirectOutput = ~isempty(idx);
if RedirectOutput
   arglist = varargin(1:idx-1);
   [OutputVar,isLocalVar] = LocalFindVar(this,varargin{idx+1});
   if isempty(OutputVar)
      error('Variable %s cannot be found or is not accessible to FEVAL.',OutputVar)
   end
else
   arglist = varargin;
end

% Collect list of variables
nargs = length(arglist);
isVar = false(1,nargs);
for ct=1:nargs
   isVar(ct) = isa(arglist{ct},'hds.variable');
end
idxVar = find(isVar);
nvarargs = length(idxVar);
[varArgs,junk,ju] = unique(cat(1,arglist{idxVar}));

% Grid size
GridSize = getGridSize(this);
y = cell(GridSize);

% Evaluate function over grid 

% Converts top level of HDS to a struct with grid dims placed last. Avoids
% many repeated calls to getsample with associated udd property access 
% penalty (g246813). TO DO: This approach won't scale up to large data sets -
% this struct effectively amounts to loading the whole data set in memory. 
 
hdsstruc = struct(this);
newstruc = struct;
griddims = this.Cache_.GridDim(this.Cache_.GridDim>0);
for k=1:length(varArgs)
    vardims = 1:ndims(hdsstruc.(varArgs(k).Name));
    newstruc.(varArgs(k).Name) = permute(hdsstruc.(varArgs(k).Name),...
         [setdiff(vardims,griddims), griddims(:)']);
end

try
   for ct=1:prod(GridSize)
      s = localgetsample(newstruc,ct,length(GridSize));
      for ctv=1:nvarargs
         % Robust to repeated variables
         arglist{idxVar(ctv)} = s.(varArgs(ju(ctv)).Name);
      end
      r = feval(f,arglist{:});
      if RedirectOutput && ~isLocalVar
         stmp.(OutputVar) = r;
         setsample(this,ct,stmp)
      else
         y{ct} = r;
      end
   end
catch
   rethrow(lasterror)
end

if RedirectOutput
   if isLocalVar
      % Write result
      this.(OutputVar) = y;
   end
   y = [];
end

%------------------ Local Functions ----------------------

function [v,isLocal] = LocalFindVar(this,OutputVar)
% Locates variable among set of variables visible from the root
v = findvar(this,OutputVar);
isLocal = ~isempty(v);
if ~isLocal
   for c=this.Children_'
      if strcmp(c.Transparency,'on') && ~isempty(c.LinkedVariables)
         v = findvar(c.Links{1},OutputVar);
         if ~isempty(v)
            break
         end
      end
   end
end
if ~isempty(v)
   v = v.Name;
end

function s = localgetsample(hdsstruc,ct,gridlen)

%% Get the ct-th sample of an HDS defined by a structure hdsstruc
s = struct;
propnames = fieldnames(hdsstruc);
for k=1:length(propnames)
    x = hdsstruc.(propnames{k});
    if ~isempty(x)
        if ndims(x)>gridlen
            ind = repmat({':'},[ndims(x)-gridlen 1]);
            s = setfield(s,propnames{k},x(ind{:},ct));
        else
            % Convert 1x1 cells to 1x1 (Time series cell arrays)
            if iscell(x) && numel(x(ct))==1
                s = setfield(s,propnames{k},x{ct});
            else
                s = setfield(s,propnames{k},x(ct));
            end
        end
    end
end
        