function clearselect(h)

% Copyright 2004 The MathWorks, Inc.

%% Clear selected points points array
for k = 1:length(h.Waves)
    L = h.Waves(k).View.Curves;
    if ~isempty(h.Waves(k).View.selectedpoints)
       h.Waves(k).View.selectedpoints = [];
    end     
    h.Waves(k).View.selectedTimes = [];
    set(h.Waves(k).View.Curves,'Selected','off')
    h.Waves(k).Data.clearwatermark
end
h.SelectionStruct.History = {};
