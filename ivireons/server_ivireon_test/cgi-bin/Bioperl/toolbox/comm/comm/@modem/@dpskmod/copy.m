function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@dpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:14 $

h = modem.dpskmod;

% Default properties
h.Type = 'DPSK Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

% Copy the state
h.PrivPhaseState = refObj.PrivPhaseState;

%-------------------------------------------------------------------------------

% [EOF]
