function update_uis(this)
%SUPER_UPDATE_UIS updates visibility of the labels and value uicontrols

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2004/04/13 00:24:18 $

% Determine the object state
visstate = get(this, 'visible');

% Get the necessary data and turn the values
% and labels to the current visstate
h = get(this, 'handles');

% Extract the actual specification values and labels
labels = get(this, 'labels');
values = get(this, 'values');

% First set everything to invisible and turn on as appropriate
set(h.labels(union(this.hiddenlabels, (length(labels)+1):this.Maximum)), ...
    'visible','off')
set(h.values(union(this.hiddenvalues, (length(values)+1):this.Maximum)), ...
    'visible','off')

for i = 1:length(values)
    if ~any(i == this.hiddenvalues)
        set(h.values(i),...
            'visible',visstate,...
            'string',values{i});
    end
end

for i = 1:length(labels)
    if ~any(i == this.hiddenlabels)
        set(h.labels(i),...
            'visible',visstate,...
            'string',labels{i});
    end
end

% [EOF]
