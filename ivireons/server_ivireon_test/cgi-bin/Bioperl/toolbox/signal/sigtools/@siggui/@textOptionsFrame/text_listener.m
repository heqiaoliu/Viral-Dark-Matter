function text_listener(h, eventData)
%TEXT_LISTENER  Listen to the text property of the object and update the UI as necessary

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:10:21 $

% Get the text to be set and set it to the ui
Text = get(h, 'Text');
handles = get(h, 'handles');
set(handles.text,'String',Text);

% [EOF]
