function delsample(this,varargin)
%DELSAMPLE  Deletes samples from a dataset object.
%
%   DELSAMPLE(VALUE) removes the data points whose indices
%   are given by the VALUE vector.  
%   
%   DELSAMPLE(VAR, VALUE) removes the data points in variable VAR, whose
%   values equal the values given by the VALUE vector. VAR is a string.
%
%   DELSAMPLE(VAR, MIN, MAX) removes the data points in variable VAR, whose
%   values are within the range given by MIN and MAX (numerical value
%   only). VAR is a string.
%
%   The number of grid variales should be zero or one.

%   Author(s): Rong Chen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 21:31:13 $

% Check grid dimensionality
if length(this.Grid_)>1
    error('DELSAMPLE currently does not supported multi-dimensional grids.');
end

% get variables
AllVars = getvars(this);
allvarnames=this.getFields;
GridVar = this.Grid_.Variable;
if isempty(GridVar)
    idx_dv=1:length(AllVars);
else
    [junk,idx_dv] = setdiff(AllVars,GridVar);
end
OriginalLength=this.Grid_.Length;
fullindex=1:OriginalLength;

% Parse inputs
if nargin>4
    error('Too many input arguments.');
elseif nargin>3
    % use range to remove corresponding points in grid/non-grid variable
    varname=varargin{1};
    if ~ischar(varname) || ~isvector(varname)
        error('variable name must be a string of characters.');
    end
    [junk1,varidx,junk2] = intersect(allvarnames,varname);
    if isempty(varidx)
        error(sprintf('variable ''%s'' couldn''t be found.',varname));
    end
    minvalue=varargin{2};
    maxvalue=varargin{3};
    if ~isnumeric(minvalue) || ~isscalar(minvalue) || ~isnumeric(maxvalue) || ~isscalar(maxvalue)
        error('MIN and MAX values should be numerical scalar values.');
    end
    c = this.Data_(varidx);
    data=getArray(c);
    if ~isvector(data)
        error('variable has to be a vector.');
    end
    if minvalue<=maxvalue
        left=fullindex(data>=minvalue);
        right=fullindex(data<=maxvalue);
    else
        left=fullindex(data>=maxvalue);
        right=fullindex(data<=minvalue);
    end
    RemovedSection=intersect(left,right);
    if isempty(RemovedSection)
        warning('no data points have been removed.');
    end
    KeptSection=setdiff(fullindex,RemovedSection);
elseif nargin>2
    % use value to remove corresponding points in grid/non-grid variable
    varname=varargin{1};
    value=varargin{2};
    if ~ischar(varname) || ~isvector(varname)
        error('variable name must be a string of characters.');
    end
    [junk1,varidx,junk2] = intersect(allvarnames,varname);
    if isempty(varidx)
        error(sprintf('variable ''%s'' couldn''t be found.',varname));
    end
    c = this.Data_(varidx);
    data=getArray(c);
    try
        RemovedSection=fullindex(ismember(data,value));
    catch
        error('value format does not match the format used by the variable.')
    end
    if isempty(RemovedSection)
        warning('no data points have been removed.');
    end
    KeptSection=setdiff(fullindex,RemovedSection);
elseif nargin>1
    % use indices to remove corresponding points in grid/non-grid variables
    value = varargin{1};
    if any(~isnumeric(value)) || any(~isvector(value)) || any(~isreal(value)) || any(~isequal(round(value),value)) || any(isinf(value))
        error('Indices should be a vector of integers.');
    else
        % make sure indices are unique
        RemovedSection=unique(value);
        % check if all the indices are valid    
        if any(RemovedSection<0) || any(RemovedSection>OriginalLength)
            error(sprintf('Indices should be within the range of 1 and %s.\n',num2str(OriginalLength)));
        end
        if isempty(RemovedSection)
            warning('no data points have been removed.');
        end
        KeptSection=setdiff(fullindex,RemovedSection);
    end
else
    error('More input arguments are required.');
end

% remove from grid variables
if ~isempty(GridVar)
    c = this.Data_(GridVar==AllVars);
%     data=getArray(c);
%     data(GridSection)=[];
%     c.setArray(data);
    c.setSlice({RemovedSection},[],OriginalLength);
end

% remove value arrays for dependent values
for ct=1:length(idx_dv)
   % for each value array
   c = this.Data_(idx_dv(ct));
   SampleSize = c.SampleSize;
   if ~isempty(SampleSize)
      % Update data
      c.setSlice({RemovedSection},[],OriginalLength);
   end
end

this.Grid_.Length = length(KeptSection);

% remove link arrays
for ct=1:length(this.Children_)
   c = this.Children_(ct);
   % remove value
   c.Links=c.Links(RemovedSection);
end
