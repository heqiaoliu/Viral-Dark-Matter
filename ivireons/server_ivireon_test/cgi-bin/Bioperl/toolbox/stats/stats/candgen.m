function [xcand,fxcand] = candgen(nfactors,model,varargin)
%CANDGEN Generate candidate set for D-optimal design.
%   XCAND = CANDGEN(NFACTORS,MODEL) generates a candidate set
%   appropriate for a D-optimal design with NFACTORS factors and
%   the model MODEL.  The output matrix XCAND is N-by-NFACTORS,
%   with each row representing the coordinates of one of the N
%   candidate points.  MODEL can be any of the following strings:
%
%     'linear'          constant and linear terms (the default)
%     'interaction'     constant, linear, and cross product terms
%     'quadratic'       interactions plus squared terms
%     'purequadratic'   constant, linear, and squared terms
%
%   Alternatively MODEL can be a matrix of term definitions as
%   accepted by the X2FX function.
%
%   [XCAND,FXCAND] = CANDGEN(NFACTORS,MODEL) returns both the
%   matrix of factor values XCAND and the matrix of term values
%   FXCAND.  The latter can be input to CANDEXCH to generate the
%   D-optimal design.
%
%   [...] = CANDGEN(NFACTORS,MODEL,'PARAM1',VALUE1,'PARAM2',VALUE2,...)
%   provides more control over the candidate set generation through a set
%   of parameter/value pairs.  Valid parameters are the following:
%
%      Parameter     Value
%      'bounds'      Lower and upper bounds for each factor, specified
%                    as a 2-by-NFACTORS matrix.  Alternatively, this value
%                    can be a cell array containing NFACTORS elements, each
%                    element specifying the vector of allowable values for
%                    the corresponding factor.
%      'levels'      Vector of number of levels for each factor.
%      'categorical' Indices of categorical predictors.
%
%   The ROWEXCH automatically generates a candidate set using the
%   CANDGEN function, and creates a D-optimal design from it using
%   the CANDEXCH function.  You may prefer to call these functions
%   separately if you want to modify the default candidate set.
%
%   See also ROWEXCH, CANDEXCH, X2FX.

%   Copyright 1993-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:12:34 $

% Get default values for optional arguments
if nargin < 2 || isempty(model)
   model = 'linear';
end

pnames = {'bounds'  'levels'  'categorical'};

[eid,emsg, bnds, levels, categ ] = ...
           doptargcheck('candgen',pnames,nfactors,0,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:candgen:%s',eid),emsg);
end

if ischar(model)
   nchars = length(model);
   isquad = strncmpi(model,'quadratic',nchars) | ...
            strncmpi(model,'purequadratic',nchars);
   islin = strncmpi(model,'linear',nchars) | ...
           strncmpi(model,'interaction',nchars) | ...
           strncmpi(model,'additive',nchars);
end

% Some argument checking
if isempty(bnds)
   bnds = repmat([-1;1],1,nfactors);
elseif iscell(bnds)
   if ~isvector(bnds) || length(bnds)~=nfactors
       error('stats:candgen:BadBounds',...
             'The BOUNDS cell array must have one entry per factor.');
   end
   obslevels = cellfun('prodofsize',bnds);
   if any(obslevels<2)
      error('stats:candgen:BadBounds',...
            'The BOUNDS array must have at least 2 levels for each factor.');
   end
   if ~isempty(levels)
       if ~isequal(levels,obslevels)
           error('stats:candgen:BadBounds',...
                 'The BOUNDS array is not consistent with the LEVELS you specified.');
       end
   end
   levels = obslevels;
elseif isnumeric(bnds)
   if ~isequal(size(bnds),[2 nfactors])
      error('stats:candgen:BadBounds',...
            'The BOUNDS matrix must have 2 rows, and 1 column per factor.');
   end
else
   error('stats:candgen:BadBounds',...
         'The BOUNDS argument must be a cell array or numeric matrix.');
end

% Find the number of levels appropriate for this design
levelsgiven = ~isempty(levels);
if ~isempty(levels)
   if isscalar(levels)
      levels = repmat(levels,1,nfactors);
   end
   if ~isvector(levels) || ~isnumeric(levels)
      error('stats:candgen:BadLevels',...
       'LEVELS must be a scalar or vector of the number of levels for each factor.');
   elseif any(levels~=floor(levels) | levels<2)
      error('stats:candgen:BadLevels',...
            'LEVELS must specify at least 2 levels for each factor.');
   end
elseif ~ischar(model)
   if size(model,2)~=nfactors
      error('stats:candgen:InputSizeMismatch',...
            'MODEL matrix must have one column per factor.');
   end
   levels = max(2, 1+max(model,[],1));
elseif isquad
   levels = 3*ones(nfactors,1);
elseif islin
   levels = 2*ones(nfactors,1);
else
   levels = 5*ones(nfactors,1);
end
if ~levelsgiven
   levels(categ) = 2;  % above values are defaults for continuous factors only
end
xcand = fullfact(levels);

for j=1:nfactors
    if iscell(bnds)
        u = bnds{j};
        if ~isnumeric(u)
           error('stats:candgen:BadBounds',...
                 'The BOUNDS value for factor %d must be numeric.',j);
        end
    else
        u = linspace(bnds(1,j),bnds(2,j),levels(j));
    end
    xcand(:,j) = u(xcand(:,j));
end

% Compute model term values for the candidate set
if nargout>1
   fxcand = x2fx(xcand,model,categ);
end
