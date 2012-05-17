function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@genqamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:24 $

h = modem.genqamdemod;

% Default properties
h.Type = 'General QAM Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_IntBin);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
