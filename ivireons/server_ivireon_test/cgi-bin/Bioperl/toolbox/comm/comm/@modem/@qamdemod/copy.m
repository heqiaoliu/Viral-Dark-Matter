function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@qamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:49 $

h = modem.qamdemod;

% Default properties
h.Type = 'QAM Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_SquareQAMIntBin);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
