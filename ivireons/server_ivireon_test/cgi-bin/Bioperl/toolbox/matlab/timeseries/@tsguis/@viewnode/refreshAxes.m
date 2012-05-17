function refreshAxes(h,wf,newIndices)

% Copyright 2005-2008 The MathWorks, Inc.

%% Assigns a new waveform to the sepcfied indices after removing empty
%% axes at the end. Legends are refreshed.

%% Cache LimitManager
limmgr = h.Plot.AxesGrid.LimitManager; % Cache limit mgr
h.Plot.AxesGrid.LimitManager = 'off';

%% Modify axes to accommodate new wave positions

% Add axes to accommodate new wave

if max(newIndices)>h.Plot.AxesGrid.size(1)    
       h.Plot.addaxes(max(newIndices)-h.Plot.AxesGrid.size(1));
       oldInd = wf.RowIndex;
       wf.RowIndex = newIndices;
%        axh = h.Plot.AxesGrid.getaxes;
%        for k=1:length(axh)
%           legend(double(axh(k)),'show');
%        end
else % Remove any extra empty axes at the end
       oldInd = wf.RowIndex;
       wf.RowIndex = newIndices;
       delind = h.Plot.packAxes;
       % If axes have been removed, update the oldInd array
       if ~isempty(delind)
           ind = false(max(oldInd),1);
           ind(oldInd) = true;
           % delind may be out of range if the deleted axes are already empty
           ind(delind(delind<=length(ind))) = []; 
           oldInd = find(ind);
       end
end
localCreateLegends(h,newIndices)
h.Plot.AxesGrid.refreshlegends([oldInd(:); newIndices(:)]);
 

%% Refresh plot
h.Plot.AxesGrid.LimitManager = limmgr;
h.Plot.AxesGrid.send('ViewChange');

function localCreateLegends(h,newIndices)

% Add new legends to previously empty axes

ax = h.Plot.AxesGrid.getaxes;
for k=1:numel(newIndices)
   if isempty(legend(ax(newIndices(k))))
       legend(ax(newIndices(k)),'show')
   end
end