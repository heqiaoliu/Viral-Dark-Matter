function out = getname(hObj, out)
%GETNAME Get the name of the magnitude response

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2008/04/21 16:31:08 $

mag = get(hObj, 'MagnitudeDisplay');

switch lower(mag)
    case 'magnitude'
        out = xlate('Magnitude Response');
    case 'magnitude (db)'
        out = xlate('Magnitude Response (dB)');
    case 'magnitude squared'
        out = xlate('Magnitude Response (squared)');
    case 'zero-phase'
        out = xlate('Zero-phase Response');
    otherwise
        out = xlate(out);
end

% [EOF]
