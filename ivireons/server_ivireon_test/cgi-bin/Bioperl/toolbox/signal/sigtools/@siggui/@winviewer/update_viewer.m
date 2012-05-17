function update_viewer(hView, eventData)
%UPDATE_VIEWER Callback executed by listener to the Fs, Frequnits, 
%Spectralwintype and Spectralscale properties.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2009/03/09 19:35:42 $

% Get the data
[data, index] = get_data(hView);

% Compute the spectral window
[t, f, fresp] = spectralwin(hView, data);

% Plot
plot(hView, t, data, f, fresp);

% Bold the current window
boldcurrentwin(hView, index);

% Measure the current window
[FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index);

% Display the measurements
display_measurements(hView, FLoss, RSAttenuation, MLWidth);

%---------------------------------------------------------------------
function [data, index] = get_data(hView)
%GET_DATA Get the data from the axes

hndls = get(hView, 'Handles');
haxtd = hndls.axes.td;

htline = findobj(haxtd, 'Tag' , 'tline');
N = length(htline);

% Get data
for i=1:N,
    data(:,N-i+1) = get(htline(i), 'YData')';
    index(i) = get(htline(i), 'LineWidth')';
end

index = find(index == max(index));


% [EOF]
