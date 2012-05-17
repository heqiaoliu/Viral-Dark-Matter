function h = copy(refObj)
%COPY Copy the object H from REFOBJ

%   @modem\@oqpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:03:34 $

h = modem.oqpskmod;

% Default properties
h.Type = 'OQPSK Modulator';
setPrivProp(h, 'ProcessFunction', @modulate_Int);

h = initFromObject(h, refObj);

% Copy the state variables
setPrivProp(h, 'PrivInitQ', getPrivProp(refObj, 'PrivInitQ'));

%-------------------------------------------------------------------------------

% [EOF]
