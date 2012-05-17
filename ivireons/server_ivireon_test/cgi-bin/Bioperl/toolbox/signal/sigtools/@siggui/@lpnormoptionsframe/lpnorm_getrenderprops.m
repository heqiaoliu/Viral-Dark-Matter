function [props, lbls] = lpnorm_getrenderprops(hObj)
%LPNORM_GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:27:53 $

[props, lbls] = remez_getrenderprops(hObj);

props = {props{:}, 'pnormend'};
lbls  = {lbls{:}, 'Pth Norm'};

% [EOF]
