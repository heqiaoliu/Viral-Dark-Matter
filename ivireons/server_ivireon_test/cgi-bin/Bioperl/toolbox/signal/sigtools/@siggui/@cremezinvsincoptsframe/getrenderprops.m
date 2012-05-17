function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:27:07 $

[props, lbls] = cremez_getrenderprops(hObj);

props = {props{:}, 'invSincFreqFactor'};
lbls  = {lbls{:}, 'InvSinc Freq. Factor'};

% [EOF]
