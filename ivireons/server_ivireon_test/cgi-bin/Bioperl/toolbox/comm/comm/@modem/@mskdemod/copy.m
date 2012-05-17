function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:39 $

h = modem.mskdemod;

% Default properties
h.Type = 'MSK Demodulator';
setPrivProp(h, 'ProcessFunction', @demodulate_Conventional);

h = initFromObject(h, refObj);

% Initialize the states
set(h, 'PrivIorQ', get(refObj, 'PrivIorQ'));
set(h, 'PrivSignStateI', get(refObj, 'PrivSignStateI'));
set(h, 'PrivSignStateQ', get(refObj, 'PrivSignStateQ'));
set(h, 'PrivInitDiffBit', get(refObj, 'PrivInitDiffBit'));
set(h, 'PrivDecimFilterI', copy(get(refObj, 'PrivDecimFilterI')));
set(h, 'PrivDecimFilterQ', copy(get(refObj, 'PrivDecimFilterQ')));

%-------------------------------------------------------------------------------

% [EOF]
