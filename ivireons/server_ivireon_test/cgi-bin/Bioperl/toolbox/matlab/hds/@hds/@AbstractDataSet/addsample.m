function addsample(this,varargin)
%ADDSAMPLE  Adds sample to data set.
%
%   ADDSAMPLE(D,S) adds a new sample S to the data set D. 
%   S is a structure whose field names and values are the 
%   variable names and values.  The data set D should be
%   mono-dimensional.
%   
%   ADDGRIDPOINTS(D,VAR1,DATA1,VAR2,DATA2,...) specifies 
%   the new sample as a collection of variable name/value
%   pairs.  For example
%      d.addsample('x',1,'y','foo')
%   add a new sample for which x=1 and y='foo'.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/03/31 16:34:37 $

% Check grid dimensionality
if length(this.Grid_)>1
   error('Use ADDGRIDPOINTS for multi-dimensional grids.')
end

% Parse inputs
if nargin>1
   for ct=1:length(varargin)
      % Beware of nonscalar cell causing S to be a struct array
      if isa(varargin{ct},'cell')
         varargin{ct} = {varargin{ct}};
      end
   end
   try
      s = struct(varargin{:});
   catch
      error('Invalid list of variable name/value pairs.')
   end
else
   s = varargin{1};
   if ~isa(s,'struct') || ~isscalar(s)
      error('New sample must be specified as a scalar structure.')
   end
end

% Update grid info
if isempty(this.Grid_)
   this.Grid_(1,1).Length = 1;
else
   this.Grid_.Length = this.Grid_.Length + 1;
end
ns = this.Grid_.Length;

% Update data for grid variables
AllVars = getvars(this);
GridVars = this.Grid_.Variable;
nv = length(GridVars);
for ctv=1:nv
   c = this.Data_(GridVars(ctv)==AllVars);
   try
      X = s.(GridVars(ctv).Name);
   catch
      error('Undefined value for grid variable %s',GridVars(ctv).Name)
   end
   if isnumeric(X)
      c.setArray([getArray(c) ; X(:)]);
   else
      c.setArray([getArray(c) ; {X}]);
   end
end

% Grow value arrays for dependent values
[junk,idx_dv] = setdiff(AllVars,GridVars);
for ct=1:length(idx_dv)
   % for each value array
   c = this.Data_(idx_dv(ct));
   vname = c.Variable.Name;
   % Get data
   SampleSize = c.SampleSize;
   if ~isempty(SampleSize) || isfield(s,vname)
      % Get sample value
      try
         X = s.(vname);
         % Special handling of strings when getArray(c) is empty
         % (preference for cell array over char array)
         if isempty(SampleSize) && isa(X,'char')
            X = {X};
         end
      catch
         % Create default sample value
         X = hdsNewArray(getArray(c),SampleSize);
         if isa(X,'cell')
            % If C uses cell storage, extract cell content = sample value
            X = X{1};
         end
      end
      % Update data
      % RE: SETSLICE expect a 1x1 cell containing the sample value
      c.setSlice({ns},{X},ns)
   end
end

% Grow link arrays
for ct=1:length(this.Children_)
   c = this.Children_(ct);
   try
      DS = s.(c.Alias.Name);
      % Check validity/compatibility of new sample
      c.checkLinks({DS});
      c.Links{ns,1} = DS;
   catch
      if ~isempty(c.Links)
         c.Links{ns,1} = [];
      end
   end
end
