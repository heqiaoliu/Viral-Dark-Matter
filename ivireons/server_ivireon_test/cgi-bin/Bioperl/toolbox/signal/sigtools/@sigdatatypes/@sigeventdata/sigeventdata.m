function obj = sigeventdata(hSrc, eventName, data)
%SIGEVENTDATA Constructor for the sigeventdata object.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:18:00 $

error(nargchk(3, 3, nargin,'struct'));

% Call the built-in constructor which inherits its two
% arguments from the handle.EventData constructor
% which takes a source handle and the name of an event
% that is defined by the class of the source handle.
obj = sigdatatypes.sigeventdata(hSrc, eventName);
% Initialize the Data field with the passed-in value
obj.Data = data;


% [EOF]
