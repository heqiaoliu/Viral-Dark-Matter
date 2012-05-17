function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:27:41 $

[props, lbls] = lpnorm_getrenderprops(hObj);

props = {props{:}, 'maxpoleradius'};
lbls  = {lbls{:}, 'Max Pole Radius'};

% [EOF]
