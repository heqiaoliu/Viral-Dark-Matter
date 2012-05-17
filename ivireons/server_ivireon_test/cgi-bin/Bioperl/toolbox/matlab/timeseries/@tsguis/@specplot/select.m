function select(h,ts,I)

% Copyright 2006 The MathWorks, Inc.

%% Select the points on the specified time series. I is a logical array of
%% the same size as the ordinate data which defined which points are
%% selected

%% Find the Wave for the specified time series
idx = [];
tsList = h.getTimeSeries;
for k=1:length(tsList)
    if tsList{k} == ts
        idx = k;
        break
    end
end

%% Set the selected points in each view to the specified logical array
if ~isempty(idx)
    L = h.Waves(idx).View.Curves;
    if isempty(h.Waves(idx).View.selectedpoints)
        h.Waves(idx).View.selectedpoints = ...
            cell(length(h.Waves(idx).View.Curves),1);
    end 
    h.Waves(idx).View.selectedpoints = I;
    
    %% Refresh
    h.draw
end



