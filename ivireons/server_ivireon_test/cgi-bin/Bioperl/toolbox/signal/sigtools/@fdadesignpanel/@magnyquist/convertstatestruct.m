function sout = convertstatestruct(hObj, sin)
%CONVERTSTATESTRUCT Convert the state structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 22:49:51 $

sout = [];

if isfield(sin.mag, 'nyquist'),
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    sout.DesignType = sin.mag.nyquist.designtype;
end

% [EOF]
