function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@oqpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:13 $

h = modem.oqpskdemod;

% Default properties
h.Type = 'OQPSK Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

h = initFromObject(h, refObj);

% Copy the state variables
setPrivProp(h, 'PrivInitI', getPrivProp(refObj, 'PrivInitI'));

%-------------------------------------------------------------------------------
% [EOF]
