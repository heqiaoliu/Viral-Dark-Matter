function h = timeimport(state)
%TIMEIMPORT
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/05/10 16:58:52 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

% create an initialselector dialog
h = lsimgui.timeimportdialog;

%workspace browser
h.workbrowser = sharedlsimgui.varbrowser;
h.workbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};

h.workbrowser.open([1 NaN; NaN 1]);
h.workbrowser.javahandle.setName('timeworkimport:browser:timevec');

% Window closing listener
h.addListeners(handle.listener(state,state.findprop('Visible'),'PropertyPostSet',...
    {@localVisibleToggle h state}));

% buttons
PNLbtns = JPanel(GridLayout(1,2,5,5));
javahandles.BTNimport = JButton(sprintf('Import'));
hc = handle(javahandles.BTNimport, 'callbackproperties');
set(hc,'ActionPerformedCallBack',@(es,ed) localImportTimeVec(es,ed,state,h));
javahandles.BTNclose = JButton(sprintf('Close'));
hc = handle(javahandles.BTNclose, 'callbackproperties');
set(hc,'ActionPerformedCallBack',@(es,ed) localClose(es,ed,h));
PNLbtns.add(javahandles.BTNimport);
PNLbtns.add(javahandles.BTNclose);
PNLbtnsouter = JPanel;
PNLbtnsouter.add(PNLbtns);

% Build data panel
PNLdata = JPanel(BorderLayout);
PNLbrowse = JPanel;
PNLbrowse.add(h.workbrowser.javahandle);
PNLdata.add(PNLbrowse,BorderLayout.CENTER);
PNLdata.add(PNLbtnsouter, BorderLayout.SOUTH);
PNLdata.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

% build frame/dialog
h.Frame = MJFrame(sprintf('Import Time Vector From Workspace'));
h.Frame.setSize(Dimension(340,207));
h.Frame.getContentPane.add(PNLdata);
h.importhandles = javahandles;

%-------------------- Local Functions ---------------------------

function localImportTimeVec(eventSrc, eventData, state, h) %#ok<*INUSL>

currentRows = double(h.workbrowser.javahandle.getSelectedRows);
if ~isempty(currentRows)
    selectedvar = h.Workbrowser.variables(currentRows(1)+1);
    if length(selectedvar.size)~=2 || min(selectedvar.size)>1
        msgbox(sprintf('Variable must be a vector'),'Linear Simulation Tool','modal')
    end
    
    % Write time vec start, interval and end to the lsimgui
    timevec = evalin('base', selectedvar.name);
    if length(timevec)>2 && issorted(timevec)
        intervals = timevec(2:end)-timevec(1:end-1);
        thisinterval = max(intervals);
        if thisinterval-min(intervals)<10*eps && thisinterval>0
            state.Inputtable.starttime = timevec(1);
            state.Handles.LBLstartTime.setText(sprintf('%s%0.3g',xlate('Start time (sec): '),timevec(1)));
            state.Inputtable.Interval = thisinterval;
            state.Handles.TXTtimeStep.setText(sprintf('%0.3g',thisinterval));
            state.Handles.TXTendTime.setText(sprintf('%0.3g',timevec(end)));
            state.Inputtable.updatetime(state.Handles.TXTendTime,state.Handles.TXTtimeStep,...
              state.Handles.LBLnumSamples); % refresh
        else
            errordlg(sprintf('The selected time vector must be uniformly sampled with a strictly positive interval'),...
                'Linear Simulation Tool', 'modal')
        end
    else
            errordlg(sprintf('The selected time vector must be sorted and have length at least 3'),...
                'Linear Simulation Tool', 'modal')        
    end  
end    
    
function localClose(eventSrc, eventData, h)

awtinvoke(h.Frame,'setVisible(Z)',false);

function localVisibleToggle(eventSrc, eventData, h, state)

awtinvoke(h.Frame,'setVisible(Z)',strcmp(state.Visible,'on'));
