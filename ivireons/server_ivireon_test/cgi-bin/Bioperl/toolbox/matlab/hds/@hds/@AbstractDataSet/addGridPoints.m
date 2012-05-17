function addGridPoints(this,varargin)
%ADDGRIDPOINTS  Adds points along particular grid dimensions.
%
%   ADDGRIDPOINTS(D,X1,X2,..,XN) adds the grid points X1 to
%   the first grid dimension, X2 to the second grid dimension, etc.
%   Each Xj is either a vector for scalar-valued grid variables,
%   or a cell array for string or array-valued grid variables.
%   Set Xj=[] if no grid point are to be added along the j-th 
%   dimension. For example
%      d.addGridPoints([1 2],{'foo' 'bar'})
%   adds the values 1,2 along the first grid dimension, and the
%   values 'foo', 'bar' along the second grid dimension.
%
%   ADDGRIDPOINTS(D,VAR1,DATA1,VAR2,DATA2,...) specifies new grid
%   points for individual grid variables. For example
%      d.addGridPoints('x',[1 2],'y',{'foo' 'bar'})
%   add two new values for the grid variables x and y.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/22 18:13:15 $

% Reduce input arguments to syntax ADDGRIDPOINTS(D,X1,X2,..,XN)

% At least one gird variables should exist
% note that GridVar = this.Grid_.Variable could not be used for
% multi-dimentional grids
if length(this.Grid_)==1
    GridVar = this.Grid_.Variable;
    if isempty(GridVar)
        error('No grid variable detected');
    end
end

try
   NewGridPoints = LocalParseData(this,varargin);
catch
   rethrow(lasterror)
end
oldGridSize = [this.Grid_.Length];

% Loop over each grid dimension
AllVars = getvars(this);
idx_new = find(cellfun('length',NewGridPoints));
for ct=1:length(idx_new)
   % Check user input
   ctd = idx_new(ct);
   Xj = NewGridPoints{ctd};
   nv = length(this.Grid_(ctd).Variable);
   if nv==1
      Xj = {Xj};
   elseif ~isa(Xj,'cell') || length(Xj)~=nv
      error('Xj must be a cell array with as many entries as variables along grid dimension.')
   end
   % Now Xj is a 1xnv cell array. Make Xj{k} a 1x1 cell when not a vector
   % of scalar samples
   for ctv=1:nv
      if ~iscell(Xj{ctv}) && (~isnumeric(Xj{ctv}) || ~isvector(Xj{ctv}))
         Xj{ctv} = {Xj{ctv}};
      end
   end
   % Check consistency
   ns = cellfun('length',Xj);
   if any(diff(ns))
      error('Number of grid points must be the same for all variables along a grid dimension.')
   end
   % Update grid dimension length
   this.Grid_(ctd).Length = this.Grid_(ctd).Length + ns(1);
   % Update data for grid variables
   for ctv=1:nv
      c = this.Data_(this.Grid_(ctd).Variable(ctv)==AllVars);
      c.SampleSize = [1 1];  % in case grid dimension is empty
      % REVISIT: should automatically convert to cell array when fails
      c.setArray([getArray(c) ; Xj{ctv}(:)]);
   end
end

% Built index locating old grid inside new grid
idx = cell(1,length(oldGridSize));
for ct=1:length(oldGridSize)
   idx{ct} = 1:oldGridSize(ct);
end
newGridSize = [this.Grid_.Length];

% Grow value arrays for dependent values
[junk,idx_dv] = setdiff(AllVars,cat(1,this.Grid_.Variable));
for ct=1:length(idx_dv)
   % for each value array
   c = this.Data_(idx_dv(ct));
   B = getArray(c);
   if ~isempty(B)
      SampleSize = c.SampleSize;
      is = repmat({':'},[1 length(SampleSize)]);
      if c.GridFirst
         A = hdsNewArray(B,[newGridSize SampleSize]);
         A = hdsSetSlice(A,[idx is],B);
      else
         A = hdsNewArray(B,[SampleSize newGridSize]);
         A = hdsSetSlice(A,[is idx],B);
      end
      c.setArray(A);
   end
end

% Grow link arrays
for ct=1:length(this.Children_)
   c = this.Children_(ct);
   B = c.Links;
   if ~isempty(B)
      % Create array of the right size
      A = cell(newGridSize);
      A(idx{:}) = B;
      c.Links = A;
   end
end

%----------------- Local Functions ------------------------

function NewGridPoints = LocalParseData(this,ArgList)
% Parses argument list and recognize supported syntax
ndims = length(this.Grid_);
nargs = length(ArgList);
if nargs>0 && rem(nargs,2)==0 && ischar(ArgList{1}) && ~isempty(findvar(this,ArgList{1}))
   % Syntax ADDGRIDPOINTS(D,VAR1,DATA1,...)
   NewGridPoints = cell(1,ndims);
   for ct=1:2:nargs
      v = findvar(this,ArgList{ct});
      if isempty(v)
         error('Invalid syntax or unknown variable.')
      else
         gdim = locateGridVar(this,v);
         gvars = this.Grid_(gdim).Variable;
         if isempty(gdim)
            error(sprintf('Variable %s does not belong to the grid.',v.Name))
         elseif length(gvars)==1 
            % Single variable along grid dimension
            NewGridPoints{gdim} = ArgList{ct+1};
         else
            % Multiple variables along grid dimension
            if isempty(NewGridPoints{gdim})
               NewGridPoints{gdim} = cell(length(gvars),1);
            end
            NewGridPoints{gdim}{gvars==v} = ArgList{ct+1};
         end
      end
   end
else
   % Syntax ADDGRIDPOINTS(D,X1,X2,..,XN)
   NewGridPoints = ArgList;
   if length(NewGridPoints)~=ndims
      error('Number of arguments does not match number of grid dimensions.')
   end
end
  
   
