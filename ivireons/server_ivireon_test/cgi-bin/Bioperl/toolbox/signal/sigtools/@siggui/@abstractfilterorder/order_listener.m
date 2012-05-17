function order_listener(h, eventData)
%ORDER_MODIFIED Callback executed by listener to the order property.

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:53 $

% Get the order
Order = get(h, 'order');

% Get the handle to the edit box
handles = get(h, 'handles');
eb = handles.eb;

% Get the string of the edit box
set(eb, 'string', Order);

% [EOF]
