function Hd = set_filterobject(this, Hd)
%SET_FILTEROBJECT   PreSet function for the FilterObject property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:22:22 $

names = coefficientnames(Hd);
for indx = 1:length(names)
    p(indx) = Hd.findprop(names{indx});
end

p(end+1) = Hd.findprop('PersistentMemory');
p(end+1) = Hd.findprop('States');

l = handle.listener(Hd, p, 'PropertyPostSet', ...
    @(h, ed) updateCoefficients(this, Hd));
set(this, 'FilterListener', l);

updateCoefficients(this, Hd);

[pkg, cls] = strtok(class(Hd), '.');
cls(1) = [];

set(this.FixedPoint, 'Structure', cls);
updateSettings(this.FixedPoint, Hd);

% -------------------------------------------------------------------------
function updateCoefficients(this, Hd)

names  = coefficientnames(Hd);
values = get(Hd, names);

props = sprintf('CoefficientVector%d\n', 1:length(names));
props(end) = [];
props = cellstr(props);

for indx = 1:length(values)
    values{indx} = mat2str(values{indx});
end

set(this, props, values);

if Hd.PersistentMemory
    pMem = 'on';
else
    pMem = 'off';
end

set(this, 'PersistentMemory', pMem, 'States', mat2str(get(Hd, 'States')));

% [EOF]
