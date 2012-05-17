function this = baseInitPropValuePairs(this, readOnlyProperties, varargin)
%BASEINITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
% for the object THIS. Odd elements of VARARGIN are property names; even
% elements are property values.

%   @commsutils/@baseclass
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:58 $

nPropValue = length(varargin);
if floor(nPropValue/2) ~= nPropValue/2
    error([getErrorId(this) ':InvalidParamValue'], ['Number of values ' ...
                        'must be same as number of properties.']);
end

for p=1:2:nargin-2
    if ~ischar(varargin{p})
        error([this.getErrorId ':InvalidPropValue'], ['Property names ', ...
            'must be strings.  Type "help %s" for proper usage.'], class(this));
    end
end

% Add base class read only properties to the list
readOnlyProperties = [readOnlyProperties, 'Type'];

for k=1:2:nPropValue
    idx = strmatch(lower(varargin{k}), lower(readOnlyProperties));
    if ~isempty(idx)
        % A read-only property is specified - not allowed - error out
        error([getErrorId(this) ':ReadOnlyProperty'], ['%s is a read-only ' ...
                            'property.'], readOnlyProperties{idx});
    else
        % set the property.
        set(this, varargin{k}, varargin{k+1});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
