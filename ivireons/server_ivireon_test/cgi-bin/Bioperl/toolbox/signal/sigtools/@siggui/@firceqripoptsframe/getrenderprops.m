function [props, lbls] = getrenderprops(hObj)
%GETRENDERPROPS   Returns the properties to render.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2005/06/16 08:45:51 $

props = {'isminphase', 'stopbandslope'};
lbls  = {'Minimum Phase', 'Stopband Slope (dB)'};

% [EOF]