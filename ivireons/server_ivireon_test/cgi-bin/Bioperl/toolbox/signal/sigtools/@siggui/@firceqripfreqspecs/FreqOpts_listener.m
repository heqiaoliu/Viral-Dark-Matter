function FreqOpts_listener(h, eventData)
%FREQOPTS_LISTENER  Listen to the freqSpecType property.

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:04:16 $

% Get current option
CurrOpts = get(h, 'freqSpecType');

% Get the handles to the radio buttons
handles = get(h, 'handles');
rbs_handles = handles.rbs_handles;

% Set the option to the one selected from the radio button
AllOpts = set(h, 'freqSpecType');
I = find(strcmp(AllOpts, CurrOpts));
set(h, 'freqSpecType', AllOpts{I});

% Turn the radio button selected on
set(rbs_handles(2), 'value', I);

% handle to FS label
fs_handles = get(h, 'handles');
Fs_Label = fs_handles.freq_handles(1);

% Handle to the dynamic property and delete the property
% After retrieving the value

% Get the listener for the old property and update
WRL = get(h,'WhenRenderedListeners');

for i = 1:length(WRL)
    Property = find(WRL(i).SourceObject,'Description','Frequency');
    if ~isempty(Property)
        break
    end
end

delete(WRL(i));
WRL(i) = [];

p = get(h, 'Dynamic_Prop_Handles');
frequency = get(h, p.Name);
delete(p)

indx = I;
if indx == 1,
    Name = 'Fc';
elseif indx == 2,
    Name = 'Fpass';
elseif indx == 3,
    Name = 'Fstop';
end

set(Fs_Label, 'string', [Name,':']);
p = schema.prop(h, Name, 'string');
set(h, p.Name, frequency);

% Store the new dynamic property handle
set(h, 'Dynamic_Prop_Handles', p);

WRL(end+1) = handle.listener(h, ...
    h.findprop(Name), ...
    'PropertyPostSet', @Frequency_listener);

set(WRL, 'callbacktarget',h);

% Update the listener array
set(h,'WhenRenderedListeners',WRL);

send(h, 'UserModifiedSpecs', handle.EventData(h, 'UserModifiedSpecs'));

% [EOF]
