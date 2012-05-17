function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@dpskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:56 $

h = modem.dpskdemod;

% Default properties
h.Type = 'DPSK Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

h = initFromObject(h, refObj);

% Copy the state
h.PrivPhaseState = refObj.PrivPhaseState;

%-------------------------------------------------------------------------------

% [EOF]
