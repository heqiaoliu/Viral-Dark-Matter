function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:56 $

h = modem.mskmod;

% Default properties
h.Type = 'MSK Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Conventional);

h = initFromObject(h, refObj);

% Initialize the states
set(h, 'PrivIorQ', get(refObj, 'PrivIorQ'));
set(h, 'PrivSignStateI', get(refObj, 'PrivSignStateI'));
set(h, 'PrivSignStateQ', get(refObj, 'PrivSignStateQ'));
set(h, 'PrivInitDiffBit', get(refObj, 'PrivInitDiffBit'));
set(h, 'PrivInitY', get(refObj, 'PrivInitY'));
set(h, 'PrivInterpFilterI', copy(get(refObj, 'PrivInterpFilterI')));
set(h, 'PrivInterpFilterQ', copy(get(refObj, 'PrivInterpFilterQ')));

%-------------------------------------------------------------------------------
% [EOF]
