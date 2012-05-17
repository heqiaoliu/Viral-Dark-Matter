function update_labels(h, varargin)
%UPDATE_LABELS updates the uicontrols to have the correct visibility

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/13 00:24:25 $

% Call the super class's update method to turn on and off 
% all the appropriate uis
lvh = getcomponent(h, 'siggui.labelsandvalues');
update_uis(lvh);

Type = get(h, 'IRType');
I = find(strcmp(h.(Type), set(h, Type)));

if I == 1
    % This means we selected dB
    Character = 'A';
elseif I == 2
    % This means we selected Linear or squared
    if strncmpi(Type, 'IIR', 3)
        Character = 'E';
    elseif strncmpi(Type, 'FIR', 3)
        Character = 'D';
    end
end

% Get the labels of the object
labels = get(h, 'labels');

for indx = 1:length(labels)
    
    % Update the appropriate labels' first character
    labels{indx}(1) = Character;
end

% Set the new modified labels
set(h,'labels',labels)

% [EOF]
