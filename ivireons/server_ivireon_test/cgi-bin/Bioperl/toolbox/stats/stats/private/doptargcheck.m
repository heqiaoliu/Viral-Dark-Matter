function [eid,emsg,varargout] = ...
                         doptargcheck(caller,okargs,nfactors,nruns,varargin)
%DOPTARGCHECK Check arguments common to D-optimal design functions
%   Utility function used by CORDEXCH and ROWEXCH.

%   The undocumented parameters 'start' and 'covariates' are used when
%   this function is called by the daugment and dcovary functions to
%   implement D-optimal designs with fixed rows or columns, and are
%   supported only by the caller CORDEXCH.
   
%   Copyright 2005-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:59:49 $

%
% Define all arguments and their defaults
%
z = zeros(0,nfactors);
pnames = {'start'      'covariates'  'display'   'init'       'maxiter' ...
          'tries'      'bounds'      'levels'    'excludefun' 'categorical' 'options'};
pdflts = {z            []            []          []           10            ...
          1            []            []          []           []            []};

% Take a subset if caller allows only some of them
if ~isempty(okargs)
   allowed = ismember(pnames,okargs);
   pnamesub = pnames(allowed);
   pdfltsub = pdflts(allowed);
else
   pnamesub = pnames;
   pdfltsub = pdflts;
   allowed = true(size(pnames));
end

% Get specified values of allowed parameters
varargout = cell(1,length(pnamesub));
[eid,emsg,varargout{:}] = internal.stats.getargs(pnamesub, pdfltsub, varargin{:});
if ~isempty(eid)
   eid = sprintf('stats:%s:%s',caller,eid);
   return
end

% Deal these out to separate variables for convenience in error checking
allvalues = pdflts;
allvalues(allowed) = varargout;
[startdes,   covariates, dodisp,  settings, maxiter,  ...
 tries,      bnds,       nlevels, excluder, categ,    paropt] = deal(allvalues{:});

%
% Perform parameter checks
%

% If there is no 'display' parameter in command line, and if the caller
% supports the 'display' parameter, set the default depending on whether
% parallel or serial computation.
if isempty(dodisp)
    dispix = strmatch('display',pnamesub);
    if ~isempty(dispix)
        dodisp = 'on';
        if ~isempty(paropt)
            if isstruct(paropt) && isfield(paropt,'UseParallel')
                if strcmpi(paropt.UseParallel,'always')
                    dodisp = 'off';
                end
            else
                % There is something wrong with the parallel options field.
                % However, we take no action here.  The caller will test the
                % field and error as indicated.
            end
        end
        varargout{dispix} = dodisp;
    end
end


% Check number of iterations
if ~isnumeric(maxiter) || ~isscalar(maxiter) || maxiter<1
   eid = sprintf('stats:%s:BadMaxIter',caller);
   emsg = 'Value of the ''maxiter'' parameter must be a number 1 or greater.';
   return
end

% Check exclusion function, if any
if ~isempty(excluder)
   if ~isa(excluder,'function_handle') && ...
      ~(ischar(excluder) && exist(excluder,'file')>0)
      eid = sprintf('stats:%s:BadExcludeFun',caller);
      emsg = 'Value of ''excludefun'' argument must be a function.';
      return
   end
end

% Check dimensions of initial design, if any
nvars = nfactors + size(covariates,2);
if ~isempty(settings)
   if size(settings,2)~=nvars
      eid = sprintf('stats:%s:BadInit',caller);
      emsg = 'Initial design must have one column for each factor.';
      return
   elseif size(settings,1)~=nruns
      eid = sprintf('stats:%s:BadInit',caller);
      emsg = 'Initial design must have one row for each run.';
      return
   end
end

% Check dimensions of the specified rows and columns, if any
if ~isempty(startdes) && size(startdes,2)~=nfactors
   eid = sprintf('stats:%s:BadStart',caller);
   emsg = 'Starting design must have one column for each factor.';
   return
end
if ~isempty(covariates) && size(covariates,1)~=nruns
   eid = sprintf('stats:%s:InputSizeMismatch',caller);
   emsg = 'Must supply fixed covariate values for each run.';
   return
end

% Check the specification of categorical factors
if ~isempty(categ)
   if ~isvector(categ) || ~all(ismember(categ,1:nfactors))
      eid = sprintf('stats:%s:BadCategorical',caller);
      emsg = 'The ''categorical'' value must be a vector of factor numbers.';
      return
   end
end

% Check the bounds for each factor, if specified
boundsrow = strmatch('bounds',pnamesub);
if isempty(bnds) && ~isempty(boundsrow)
   bnds = ones(2,nfactors);
   bnds(1,:) = -1;
   if ~isempty(categ)
      bnds(1,categ) = 1;
      if isempty(nlevels)
          lev = 2;
      else
          lev = nlevels;
      end
      bnds(2,categ) = lev;
   end
   varargout{boundsrow} = bnds;
end
if isempty(boundsrow)
   % ok
elseif iscell(bnds)
   if ~isvector(bnds) || length(bnds)~=nfactors
       eid = sprintf('stats:%s:BadBounds',caller);
       emsg = 'The ''bounds'' cell array must have one entry per factor.';
       return
   end
   obsnlevels = cellfun('prodofsize',bnds);
   if any(obsnlevels<2)
      eid = sprintf('stats:%s:BadBounds',caller);
      emsg = 'The ''bounds'' array must have at least 2 levels for each factor.';
      return
   end
elseif isnumeric(bnds)
   if ~isequal(size(bnds),[2 nfactors])
      eid = sprintf('stats:%s:BadBounds',caller);
      emsg = 'The ''bounds'' matrix must have 2 rows, and 1 column per factor.';
      return
   end
else
   eid = sprintf('stats:%s:BadBounds',caller);
   emsg = 'The ''bounds'' parameter must be a cell array or matrix.';
   return
end    

% Check the numbers of levels for each factor, if specified
levrow = strmatch('levels',pnamesub);
if iscell(bnds)
   if ~isequal(nlevels,obsnlevels)
      if ~isempty(nlevels) 
         warning(sprintf('stats:%s:BadLevels',caller), ...
             ['The ''levels'' parameter doesn''t match the number of levels'...
              '\nactually appearing in the ''bounds'' parameter;'...
              ' using the actual number instead.']);
      end
   nlevels = obsnlevels;
   end
end
if ~isempty(nlevels) && ~isempty(levrow)
   if ~isscalar(nlevels) && ~isvector(nlevels)
      eid = sprintf('stats:%s:BadLevels',caller);
      emsg = 'The ''levels'' parameter must be a scalar or vector.';
      return
   elseif ~isscalar(nlevels) && length(nlevels)~=nfactors
      eid = sprintf('stats:%s:BadLevels',caller);
      emsg = 'The ''levels'' vector must have one element for each factor.';
      return
   elseif any(nlevels<2 | nlevels~=round(nlevels))
      eid = sprintf('stats:%s:BadLevels',caller);
      emsg = 'The ''levels'' values must be integers greather than 1.';
      return
   end
   if isscalar(nlevels)
       nlevels = nlevels*ones(1,nfactors);
   end
end
if ~isempty(levrow)
   varargout{levrow} = nlevels;
end

