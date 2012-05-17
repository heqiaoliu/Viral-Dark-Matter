function b = isSubscribed(this)
%ISSUBSCRIBED True if the object is Subscribed

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/01/25 22:47:07 $

b = ~isempty(this.hDataSink);

% [EOF]
