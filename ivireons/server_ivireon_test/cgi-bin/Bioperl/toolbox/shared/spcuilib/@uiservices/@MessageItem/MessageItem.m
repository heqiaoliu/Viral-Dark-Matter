function h = MessageItem(mType,mCategory,mSummary,mDetail)
%MessageItem Constructor for uiservices.MessageItem
%  Constructs a new messages for use with MessageLog.
%  A time/date stamp is automatically added when message
%  is first created.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:28 $

h = uiservices.MessageItem;
h.Time = now; % date number

if nargin>0, h.Type=mType; end % required arg: info, warn, fail
if nargin>1, h.Category=mCategory; end
if nargin>2, h.Summary=mSummary; end
if nargin>3, h.Detail=mDetail; end

% [EOF]
