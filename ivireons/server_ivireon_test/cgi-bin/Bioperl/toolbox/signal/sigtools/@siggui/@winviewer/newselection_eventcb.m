function newselection_eventcb(hView, eventData)
%NEWSELECTION_EVENTCB 

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2009/03/09 19:35:40 $

% Callback executed by the listener to an event thrown by another component.
% The Data property stores a vector of handles of winspecs objects
s = eventData.Data;
selectedwin = s.selectedwindows;

% Get the data of the selected windows
data = get_data(hView, selectedwin);

% Compute the spectral window
[t, f, fresp] = spectralwin(hView, data);

% Plot
plot(hView, t, data, f, fresp);

% Bold the current window
currentwinindex = [];
if ~isempty(s.currentindex),
    currentwinindex = find(s.currentindex == s.selection);
end
boldcurrentwin(hView, currentwinindex);

% Measure the current window
[FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, currentwinindex);

% Display the measurements
display_measurements(hView, FLoss, RSAttenuation, MLWidth);


%---------------------------------------------------------------------
function data = get_data(hView, selectedwin)
%GET_DATA

data = [];
names = [];
if ~isempty(selectedwin),
    N = length(selectedwin);
    % Define the maximum length of the selected windows
    for i=1:N,
        winlength(i) = length(selectedwin(i).Data);
    end
    M = max(winlength);
    data = NaN*ones(M,N);
    % Get data - each window is store in a column of the data matrix
    % Reverse order (first window of selection stored in the last column)
    % for graphical reason (colororder)
    for i=1:N,
        data(1:winlength(i),N-i+1) = get(selectedwin(i), 'Data');
        names{N-i+1} = strrep(get(selectedwin(i), 'Name'), '_', '\_');
    end
end
set(hView, 'Names', names);


% [EOF]
