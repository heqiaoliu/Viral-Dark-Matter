function h = baseInitPropValuePairs(h, readOnlyProperties, varargin)
%BASEINITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object H. Odd elements of VARARGIN are property names; even
%   elements are property values.  Error out if a read only property is to
%   be set

% @modem\@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:47 $

nPropValue = length(varargin);
if floor(nPropValue/2) ~= nPropValue/2
    error([getErrorId(h) ':InvalidParamValue'], ['Number of values must be ' ...
                        'same as number of properties.']);
end

for k=1:2:nPropValue
    idx = strmatch(lower(varargin{k}), lower(readOnlyProperties));
    if ~isempty(idx)
        % A read-only property is specified - not allowed - error out
        error([getErrorId(h) ':ReadOnlyProperty'], ['%s is a read-only ' ...
                            'property.'], readOnlyProperties{idx});
    else
        % set the property
        set(h, varargin{k}, varargin{k+1});
    end
end
%-------------------------------------------------------------------------------

% [EOF]
