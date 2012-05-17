function Frequency_listener(h, eventData)
%FREQUENCY_LISTENER  Listens to the Frequency property and updates as necessary

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:04:04 $

% Get the name of the frequency prperty
Name = getdynamicname(h);

% Get the current frequency
Frequency = get(h, Name);

% Get the handle to the edit box
handles = get(h, 'handles');
freq_eb_handle = handles.freq_handles(2);

% Set the string to the new frequency
set(freq_eb_handle, 'string', Frequency);

send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));

% [EOF]
