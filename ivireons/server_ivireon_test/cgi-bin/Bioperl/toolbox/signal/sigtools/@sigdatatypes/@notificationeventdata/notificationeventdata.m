function obj = notificationeventdata(hSrc, NType, data)
%SIGEVENTDATA Constructor for the sigeventdata object.

%   Author(s): V. Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:17:49 $

error(nargchk(2, 3, nargin,'struct'));
if nargin < 3, data = []; end

% Call the built-in constructor which inherits its two
% arguments from the handle.EventData constructor
% which takes a source handle and the name of an event
% that is defined by the class of the source handle.
obj = sigdatatypes.notificationeventdata(hSrc, 'Notification');
% Initialize the Data field with the passed-in value
obj.NotificationType = NType;
obj.Data = data;

% [EOF]
