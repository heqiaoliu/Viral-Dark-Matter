function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:42:51 $

[props, lbls] = remez_getrenderprops(hObj);

props = {props{:}, 'phase', 'firtype'};
lbls  = {lbls{:}, 'Phase', 'FIR Type'};

% [EOF]
