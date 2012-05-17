function delind = packAxes(h)

% Copyright 2005 The MathWorks, Inc.

%% Removes empty trailing axes

%% Find the largest row index
maxrowinds = 1;
for k=1:length(h.Waves)
    maxrowinds = max([maxrowinds;h.Waves(k).RowIndex(:)]);
end

%% Remove additional axes
delind = [];
if maxrowinds<h.AxesGrid.size(1)
     delind = maxrowinds+1:h.AxesGrid.size(1);
     h.rmaxes(delind);
end