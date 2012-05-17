function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@pskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:24 $

h = modem.pskdemod;

% Default properties
h.Type = 'PSK Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
