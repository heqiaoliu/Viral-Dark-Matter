function edit(h, frame)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2010/05/10 16:58:51 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

% create an initialselector dialog
h.importSelector = sharedlsimgui.initialselector;

%workspace browser
h.importSelector.workbrowser = sharedlsimgui.varbrowser;
h.importSelector.workbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
if ~isempty(h.numstates)
    h.importSelector.workbrowser.open([h.numstates 1; 1 h.numstates]); %restrict vectors to right size
else
    h.importSelector.workbrowser.open;
end
h.importSelector.workbrowser.javahandle.setName('initialworkimport:browser:workfiles');

% buttons
PNLbtns = JPanel(GridLayout(1,2,5,5));
javahandles.BTNimport = JButton(sprintf('Import'));
hc = handle(javahandles.BTNimport, 'callbackproperties');
set(hc,'ActionPerformedCallBack',@(es,ed) localImportFromWorkspace(es,ed,h));
javahandles.BTNclose = JButton(sprintf('Close'));
hc = handle(javahandles.BTNclose, 'callbackproperties');
set(hc,'ActionPerformedCallBack',@(es,ed) localClose(es,ed,h.importSelector));
PNLbtns.add(javahandles.BTNimport);
PNLbtns.add(javahandles.BTNclose);
PNLbtnsouter = JPanel;
PNLbtnsouter.add(PNLbtns);

% Build data panel
PNLdata = JPanel(BorderLayout);
PNLbrowse = JPanel;
PNLbrowse.add(h.importSelector.workbrowser.javahandle);
PNLdata.add(PNLbrowse,BorderLayout.CENTER);
PNLdata.add(PNLbtnsouter, BorderLayout.SOUTH);
PNLdata.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

% build frame/dialog
h.importSelector.frame = MJDialog(frame,sprintf('Import initial states from workspace'), 0);
h.importSelector.frame.setSize(Dimension(340,207));
h.importSelector.frame.getContentPane.add(PNLdata);
h.importSelector.importhandles = javahandles;

%-------------------- Local Functions ---------------------------

function localImportFromWorkspace(eventSrc, eventData, initialtable)

currentRows = double(initialtable.importSelector.workbrowser.javahandle.getSelectedRows);
if ~isempty(currentRows)
    selectedvar = initialtable.importSelector.workbrowser.variables(currentRows(1)+1);
    if length(selectedvar.size)~=2 || min(selectedvar.size)>1
        msgbox(sprintf('Variable must be a vector'),'Linear Simulation Tool','modal')
    end
    
    % load data and convert to col
    initvec = evalin('base', selectedvar.name);
    if size(initvec,2)>1 %convert to col vector
        initvec =initvec';
    end
    
    %update initial table
    tablecontents = initialtable.celldata;
    tablecontents(1:initialtable.numstates,2) = cellstr(num2str(initvec));
    initialtable.setCells(tablecontents);   
end    
    
function localClose(eventSrc, eventData, importSelector)

awtinvoke(importSelector.frame,'setVisible(Z)',false);


