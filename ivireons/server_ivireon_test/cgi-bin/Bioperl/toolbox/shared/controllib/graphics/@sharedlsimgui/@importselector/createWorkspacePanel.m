function panelHandles = createWorkspacePanel(importSelector)

% CREATEWORKSPACEPANEL creates a panel for the importbrowser workspace browser and returns
% handles to those object which must remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:07 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

%workspace browser
workbrowser = sharedlsimgui.varbrowser;
workbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
workbrowser.open;
workbrowser.javahandle.setName('workimport:browser:workfiles');
% assign the copy context menu callback
workbrowser.addlisteners(handle.listener(workbrowser,'rightmenuselect',...
    {@localWorkspaceCopy workbrowser importSelector}));

% Build data panel
PNLdata = JPanel(BorderLayout(5,5));
defaultColText = ['1-'];
PNLdata.add(workbrowser.javahandle,BorderLayout.CENTER);
PNLcols = JPanel(FlowLayout.LEFT);
PNLcolsouter = JPanel(BorderLayout);
PNLcols.add(JLabel(sprintf('Selected columns:')));
TXTselectedCols = JTextField(5);
TXTselectedCols.setName('workimport:textfield:whichcols');
PNLcols.add(TXTselectedCols);
PNLcolsouter.add(PNLcols,BorderLayout.WEST);
PNLdata.add(PNLcolsouter,BorderLayout.SOUTH);
PNLdata.setBorder(BorderFactory.createTitledBorder(sprintf('Data source:')));

% list selection listener
workbrowser.addlisteners(handle.listener(workbrowser,'listselect',...
    {@localWorkspaceSelect workbrowser TXTselectedCols}));

% Refresh the workspace browser if PNLdata is reopened and the workspace
% variables may have changed
set(PNLdata,'PropertyChangeCallback', {@varBrowserRefresh workbrowser});
set(PNLdata,'FocusGainedCallback', {@varBrowserRefresh workbrowser});
set(PNLdata,'AncestorAddedCallback', {@varBrowserRefresh workbrowser});

panelHandles = {PNLdata, workbrowser,TXTselectedCols};

%-------------------- Local Functions ---------------------------

function localWorkspaceCopy(eventSrc, eventData, browser, importSelector)

% created a copyStruc from the workspace browser selected variable and
% transfers it to the copieddatabuffer property of the @importslector

thisRow = double(browser.javahandle.getSelectedRows);
if ~isempty(thisRow)
    thisSize = browser.variables(thisRow+1).size;
    importSelector.importtable.copieddatabuffer = struct('data',evalin('base', browser.variables(thisRow+1).name),...
        'source','wor','length',thisSize(1),'subsource',browser.variables(thisRow+1).name,'construction','',...
        'columns',[1:thisSize(2)]);
    % Enable paste and inset menus
    importSelector.importtable.STable.getModel.setMenuStatus([1 1 1 1 1]);
end

function varBrowserRefresh(eventSrc, eventData, workbrowser)

% check the var browser is valid since this listener may get called when
% disposing of the workspace browser
if ~isempty(workbrowser) && ~isempty(workbrowser.javahandle) && workbrowser.javahandle.isValid
    % refresh variable viewer
    workbrowser.open;
    % If there are variables select the first one
    if length(workbrowser.variables)>0
        workbrowser.javahandle.setSelectedIndex(0);
    end
end

function localWorkspaceSelect(eventSrc, eventData, h, TXTselectedCols)

% listener callback to write the number of cols of the selected 
% variable to the workbrowser "columns selected" textbox

varstruc = h.getSelectedVarInfo;
if ~isempty(varstruc) 
    if varstruc.size(2)>=2
        TXTselectedCols.setText(['[1:' num2str(varstruc.size(2)) ']']);
    elseif varstruc.size(2)==1
        TXTselectedCols.setText('1');
    end
end