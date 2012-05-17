function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@qammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:49:07 $

h = modem.qammod;

% Default properties
h.Type = 'QAM Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
