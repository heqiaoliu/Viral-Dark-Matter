function update(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Listener to changes in the viewNode due to selecting a different
%% view target node

import javax.swing.*; 
import java.awt.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;

if isempty(h.ViewNode) || ~ishandle(h.ViewNode)
    return % All views deleted
end

I = find(h.ViewNode==get(h.Handles.COMBOselectView,'Userdata'));
if ~isempty(I)
    % Select the combo
    set(h.Handles.COMBOselectView,'Value',I(1)) 
    
    % Update the timeseries table with the member time series of the 
    % selected View
    if ~isempty(h.ViewNode.Plot)
        memberts = h.ViewNode.Plot.getTimeSeries;
    else
        memberts = {};
    end
    tstabledata = cell(length(memberts),4);
    for k=1:length(memberts)
        tstabledata{k,1} = true;
        tstabledata{k,2} = memberts{k}.Name;
        tstabledata{k,3} = constructNodePath(h.ViewNode.getRoot.find('Timeseries',memberts{k}));
        tstabledata{k,4} = ['1:' sprintf('%d',size(memberts{k}.Data,2))];
    end
    h.Handles.tsTable.getModel.setDataVector(tstabledata,...
        {xlate('Select from (y/n)?'),xlate('Time Series'),xlate('Path'),xlate('Selected Column(s)')},...
        h.Handles.tsTable);
end 
