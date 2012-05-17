function h = workpanel(importSelector)
% WORTPANEL-@workpanel constructor.
%
% Creates a panel for the importbrowser workspace browser and returns
% handles to those object which must remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 21:45:35 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.workpanel;

h.workbrowser = sharedlsimgui.varbrowser;
h.workbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
h.workbrowser.open;
h.workbrowser.javahandle.setName('workimport:browser:workfiles');

% assign the copy context menu callback
h.workbrowser.addlisteners(handle.listener(h.workbrowser,'rightmenuselect',...
    {@localWorkspaceCopy importSelector}));

% Build data panel
PNLdata = JPanel(BorderLayout(10,10));
% defaultColText = ['1-'];
PNLdata.add(h.workbrowser.javahandle,BorderLayout.CENTER);

PNLrowcols =  JPanel(GridLayout(2,1,5,5));
PNLcols =  JPanel(FlowLayout.LEFT);
PNLrows = JPanel(FlowLayout.LEFT);
PNLcolsOuter =  JPanel(BorderLayout);
PNLrowsOuter = JPanel(BorderLayout);

% Define radio buttons
%h.FilterHandles.radioRow = JRadioButton(sprintf('Assign rows'));
%h.FilterHandles.radioCol = JRadioButton(sprintf('Assign columns'));
h.FilterHandles.radioRow = JRadioButton(sprintf('Assign the following rows to selected channel(s):'));
h.FilterHandles.radioCol = JRadioButton(sprintf('Assign the following columns to selected channel(s):'));
h.FilterHandles.radioRow.setPreferredSize(h.FilterHandles.radioCol.getPreferredSize);
h.FilterHandles.radioCol.setSelected(true);
btngrp = ButtonGroup;
btngrp.add(h.FilterHandles.radioRow);
btngrp.add(h.FilterHandles.radioCol);
PNLcols.add(h.FilterHandles.radioCol);
PNLrows.add(h.FilterHandles.radioRow);

% Define row/col selection text boxes
h.FilterHandles.TXTselectedCols = JTextField(5);
h.FilterHandles.TXTselectedCols.setName('workimport:textfield:whichcols');
h.FilterHandles.TXTselectedRows = JTextField(5);
h.FilterHandles.TXTselectedRows.setName('workimport:textfield:whichrows');
PNLcols.add(h.FilterHandles.TXTselectedCols);
PNLrows.add(h.FilterHandles.TXTselectedRows);

% Add "to where" labels
%PNLcols.add(JLabel(sprintf('to selected channel(s)')));
%PNLrows.add(JLabel(sprintf('to selected channel(s)')));

% Assemble row col section panel
PNLcolsOuter.add(PNLcols,BorderLayout.WEST);
PNLrowsOuter.add(PNLrows,BorderLayout.WEST);
PNLrowcols.add(PNLcolsOuter);
PNLrowcols.add(PNLrowsOuter);

PNLdata.add(PNLrowcols,BorderLayout.SOUTH);
%PNLdata.setBorder(BorderFactory.createTitledBorder('Data source:'));

% list selection listener
radios = {h.FilterHandles.radioCol, h.FilterHandles.radioRow};
selections = {h.FilterHandles.TXTselectedCols h.FilterHandles.TXTselectedRows};
h.workbrowser.addlisteners(handle.listener(h.workbrowser,'listselect',...
      {@localWorkspaceSelect h.workbrowser, radios, selections}));


% Radio button selection listener
% set(h.FilterHandles.radioCol, 'StateChangedCallback', ...
%     {@localWorkspaceSelect h.workbrowser, radios, selections});

% Refresh the workspace browser if PNLdata is reopened and the workspace
% variables may have changed
hc = handle(PNLdata, 'callbackproperties');
set(hc,'PropertyChangeCallback',@(es,ed) localRefreshWorkspace(es,ed,h.workbrowser));
hc = handle(PNLdata, 'callbackproperties');
set(hc,'AncestorAddedCallback',@(es,ed) localRefreshWorkspace(es,ed,h.workbrowser));

% Listener to window activation so that variable browser updates to reflect
% the current workspace
hc = handle(importSelector.importhandles.importDataFrame, 'callbackproperties');
set(hc,'WindowActivatedCallback',@(es,ed) localRefreshWorkspace(es,ed,h.workbrowser));


h.Panel = PNLdata;

%-------------------- Local Functions ---------------------------

function localWorkspaceCopy(eventSrc, eventData, importSelector)

importSelector.workpanel.import(importSelector.importtable,'copy');


function localWorkspaceSelect(eventSrc, eventData, h, radios, TXTcolrow)

% Listener callback to write the number of cols/rows of the selected
% variable to the workbrowser "columns selected" textbox

varstruc = h.getSelectedVarInfo;
dim = double(radios{2}.isSelected)+1;

if ~isempty(varstruc) % Non-empty selection
    if varstruc.size(dim)>=2 % Matrix
        TXTcolrow{3-dim}.setText(['[1:' num2str(varstruc.size(dim)) ']']);
    elseif varstruc.size(dim)==1 % Vector
        TXTcolrow{3-dim}.setText('1');
    end
    if varstruc.size(3-dim)>=2 % Matrix
        TXTcolrow{dim}.setText(['[1:' num2str(varstruc.size(3-dim)) ']']);
    elseif varstruc.size(3-dim)==1 % Vector
        TXTcolrow{dim}.setText('1');
    end
end

function localRefreshWorkspace(es,ed, browser)


if ~isempty(browser) && ~isempty(browser.javahandle) && ...
    browser.javahandle.isVisible
    selectedVar = browser.getSelectedVarInfo;
    % Window activation callback which refreshes the workspace browser to
    % reflect the current state of the workspace
    browserChangedFlag = browser.open;
    if browserChangedFlag && length(selectedVar)
        browser.setSelectedVar(selectedVar.name)
    end
end
