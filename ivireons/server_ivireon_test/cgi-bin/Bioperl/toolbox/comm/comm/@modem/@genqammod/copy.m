function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@genqammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:42 $

h = modem.genqammod;

% Default properties
h.Type = 'General QAM Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

%-------------------------------------------------------------------------------

% [EOF]
