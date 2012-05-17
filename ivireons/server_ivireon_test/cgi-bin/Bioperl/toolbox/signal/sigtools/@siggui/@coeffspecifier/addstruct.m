function addstruct(hC, construct, type, label, default, supportsos)
%ADDSTRUCT Add a structure type to the coefficient specifier
%   ADDSTRUCT(H, CONS, TYPE, LBLS, DEFAULT)

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:18:12 $

error(nargchk(5,6,nargin,'struct'));

if nargin < 6, supportsos = false; end

structs = get(hC, 'AllStructures');
labels  = get(hC, 'Labels');
vars    = get(hC, 'Coefficients');

structs.short{end+1} = construct;
structs.strs{end+1}  = type;
structs.supportsos(end+1) = supportsos;

[pk, shortstruct] = strtok(construct, '.');
if isempty(shortstruct),
    shortstruct = pk;
else,
    shortstruct(1) = [];
end

if ~iscell(label), label = {label}; end
if ~iscell(default), default = {default}; end

labels.(shortstruct) = label;
vars.(shortstruct) = default;

set(hC, 'AllStructures', structs);
set(hC, 'Labels', labels);
set(hC, 'Coefficients', vars);

if isrendered(hC),
    h = get(hC, 'Handles');
    set(h.selectedstructure, 'String', structs.strs);
end

% [EOF]
