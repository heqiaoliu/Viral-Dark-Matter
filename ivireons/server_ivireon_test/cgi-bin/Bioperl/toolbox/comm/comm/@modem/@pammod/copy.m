function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@pammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:13 $

h = modem.pammod;

% Default properties
h.Type = 'PAM Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
