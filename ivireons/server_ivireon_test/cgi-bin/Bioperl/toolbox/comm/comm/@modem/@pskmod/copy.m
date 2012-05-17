function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@pskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:48:39 $

h = modem.pskmod;

% Default properties
h.Type = 'PSK Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
