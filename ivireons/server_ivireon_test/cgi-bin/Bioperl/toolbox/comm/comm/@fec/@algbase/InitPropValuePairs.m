function h = InitPropValuePairs(h,  varargin)
%INITPROPVALUEPAIRS Initialize/set property-value pairs stored in VARARGIN
%   for the object H. Odd elements of VARARGIN are property names; even
%   elements are property values.  Error out if a read only property is to
%   be set

% @fec\@algbase

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:32 $

readOnlyProperties = {'Type','nSet','kSet','T2','t','m','PrimPoly'};
allProperties = {'Type','nSet','kSet','T2','t','N','K','ParityPosition'...
    'ShortenedLength','PuncturePattern','GenPoly'};

nPropValue = length(varargin);
if floor(nPropValue/2) ~= nPropValue/2
    error([getErrorId(h),':InvalidParamValue'], ['Number of values must be ' ...
                        'same as number of properties.']);
end

for k=1:2:nPropValue
    idx = find(strcmp(lower(varargin{k}), lower(allProperties)));
    if isempty(idx)
        error([getErrorId(h),':NotProp'],'%s is not a valid property name',varargin{k})
    end
    idx = find(strcmp(lower(varargin{k}), lower(readOnlyProperties)));
    if ~isempty(idx)
        % A read-only property is specified - not allowed - error out
        error([getErrorId(h),':ReadOnlyProperty'], ['%s is a read-only ' ...
                            'property.'], readOnlyProperties{idx});
    else
        % set the property
        set(h, varargin{k}, varargin{k+1});
    end
end

h.Type = algType(h,h.N,h.K,h.ShortenedLength,h.PuncturePattern);


% [EOF]
