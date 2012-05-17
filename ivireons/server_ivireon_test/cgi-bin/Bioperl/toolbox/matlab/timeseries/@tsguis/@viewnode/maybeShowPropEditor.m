function maybeShowPropEditor(h,groupContainer)

% Copyright 2006 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.widgets.*;

dt = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
% Create a property editor, since its already open in the MDI
if ~dt.isClientShowing('Property Editor',xlate('Time Series Plots'))
    if isempty(h.Plot.axesgrid.parent.jpanel) && length(h.Plot.waves)<=1 && ~isempty(groupContainer) && ...
         (~dt.hasClient('Property Editor',xlate('Time Series Plots')) || ...
          ~dt.isClientShowing ('Property Editor','Time Series Plots'))
        msg = sprintf('The Property Editor can be used to customize\nthe appearance and behavior of time series plots.\nOpen the Property Editor?');
        propEditOpen = Dialogs.showOptionalConfirmDialog(...
             groupContainer,...
             msg,xlate('Time Series Tools'), MJOptionPane.YES_NO_OPTION,...
             MJOptionPane.QUESTION_MESSAGE,tsPrefsPanel.PROPKEY_PROPEDITDLG,1,true);
        if propEditOpen == 0
             drawnow % Flush the queue so that property editor initialized correctly
             showplottool(ancestor(h.Plot.AxesGrid.Parent,'Figure'),'on',...
                 'propertyeditor');
             drawnow
        end
    end
end