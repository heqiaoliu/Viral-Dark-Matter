function strs = usesaxes_getlegendstrings(hObj, full)
%USESAXES_GETLEGENDSTRINGS Returns the legend strings

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:28:46 $

if nargin > 1
    extra = [' ' legendstring(hObj)];
else
    extra = '';
end

if isempty(extra)
    extrad = extra;
else
    extrad = [':' extra];
end

strs = {};

for indx = 1:length(hObj.Filters),
    name = get(hObj.Filters(indx), 'Name');
    if isempty(name),
        name = sprintf('Filter #%d', indx);
    end
    if isquantized(hObj.Filters(indx).Filter),
        strs = {strs{:}, sprintf('%s: Quantized%s', name, extra)};
        strs = {strs{:}, sprintf('%s: Reference%s', name, extra)};
    else
        strs = {strs{:}, sprintf('%s%s', name, extrad)};
    end
end

% [EOF]
