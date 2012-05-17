function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@pamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:55 $

h = modem.pamdemod;

% Default properties
h.Type = 'PAM Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
