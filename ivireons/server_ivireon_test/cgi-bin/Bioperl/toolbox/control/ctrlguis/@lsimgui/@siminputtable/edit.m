function importSelector = edit(h)

% EDIT Creates/links an importSelector with an importtable (h)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2010/05/10 16:58:53 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;


% build importSelector GUI if empty
if isempty(h.importSelector)
    importSelector = sharedlsimgui.importselector;
    
    % assign the target table
    importSelector.importtable = h;
    
    % assign the target importSelector
    h.importSelector = importSelector;
    
    gridbag = GridBagLayout;
    constr = GridBagConstraints;
    
    % initial properties
    importSelector.filetype = 'wor';
    importSelector.importhandles.PNLdataSource = cell(1,5);
    
    % Build source selection combo panel    
    importSelector.importhandles.PNLsource = JPanel;
    importSelector.importhandles.LBLimport = JLabel(sprintf('Import from:'));
    importSelector.importhandles.COMBOimport = JComboBox;
    importSelector.importhandles.COMBOimport.setName('import:combo:source');
    importSelector.importhandles.COMBOimport.addItem(xlate('Workspace'));
    importSelector.importhandles.COMBOimport.addItem(xlate('MAT file'));
    importSelector.importhandles.COMBOimport.addItem(xlate('XLS file'));
    importSelector.importhandles.COMBOimport.addItem(xlate('CSV file'));
    importSelector.importhandles.COMBOimport.addItem(xlate('ASCII file'));
    importSelector.importhandles.PNLsource.add(importSelector.importhandles.LBLimport);
    importSelector.importhandles.PNLsource.add(importSelector.importhandles.COMBOimport);    

                       
    hc = handle(importSelector.importhandles.COMBOimport, 'callbackproperties');
    set(hc,'ItemStateChangedCallback',@(es,ed) localFileTypeSelect(es,ed,importSelector));
    importSelector.importhandles.PNLsource.setBorder(BorderFactory.createEmptyBorder(10,5,10,5));
    localBagConstraints(constr);
    constr.anchor = GridBagConstraints.NORTHWEST;
    constr.fill = GridBagConstraints.NONE;
    constr.gridwidth = GridBagConstraints.REMAINDER;
    gridbag.setConstraints(importSelector.importhandles.PNLsource,constr);
    
    % Build the available data panels 
    importSelector.importhandles.PNLdataSource = cell(1,5);  
    importSelector.addlisteners(handle.listener(importSelector, ...
        findprop(importSelector,'filetype'),'PropertyPostSet',...
        {@localSwitchPanelVisibility importSelector gridbag}));
    
    % Create main panel and frame so that local functions can add things
    importSelector.importhandles.mainPanel = JPanel(gridbag);
    importSelector.importhandles.mainPanel.setBorder(EmptyBorder(10,10,10,10));
    importSelector.importhandles.importDataFrame = MJFrame(sprintf('Data Import'));
    
    % Exercise the visibility listener which will draw the workspace import panel
    importSelector.filetype = 'wor';
    localSwitchPanelVisibility([],[],importSelector,gridbag)
    importSelector.importhandles.PNLdataSource{1} = h.importSelector.importhandles.PNLdataSource{1};
   
    % Build close & help buttons    
    importSelector.importhandles.PNLbuttons = JPanel; 
    importSelector.importhandles.BTNimport = JButton(sprintf('Import'));
    importSelector.importhandles.BTNimport.setName('import:button:import');
    hc = handle(importSelector.importhandles.BTNimport, 'callbackproperties');
    set(hc,'ActionPerformedCallBack',@(es,ed) localImportFromWorkspace(es,ed,importSelector));
    
    importSelector.importhandles.BTNclose = JButton(sprintf('Close'));
    importSelector.importhandles.BTNclose.setName('import:button:close');
    importSelector.importhandles.BTNhelp = JButton(sprintf('Help'));
    importSelector.importhandles.BTNhelp.setName('import:button:help');
    hc = handle(importSelector.importhandles.BTNhelp, 'callbackproperties');
    set(hc,'ActionPerformedCallBack',@(es,ed) localHelp(es,ed));
    
    importSelector.importhandles.PNLbuttons.add(importSelector.importhandles.BTNimport);
    importSelector.importhandles.PNLbuttons.add(importSelector.importhandles.BTNclose);
    importSelector.importhandles.PNLbuttons.add(importSelector.importhandles.BTNhelp);
    importSelector.importhandles.PNLbuttons.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));
    localBagConstraints(constr);
    constr.fill = GridBagConstraints.NONE;
    constr.anchor = GridBagConstraints.SOUTH;
    constr.gridy = 2;
    constr.gridwidth = 3;
    gridbag.setConstraints(importSelector.importhandles.PNLbuttons,constr);
    
    % build main panel & data import frame  
    importSelector.importhandles.mainPanel.add(importSelector.importhandles.PNLsource);
    importSelector.importhandles.mainPanel.add(importSelector.importhandles.PNLbuttons);   
    importSelector.importhandles.importDataFrame.getContentPane.add(importSelector.importhandles.mainPanel);
    importSelector.importhandles.importDataFrame.setSize(414,500);
    importSelector.importhandles.importDataFrame.setLocation(50,50);
    importSelector.importhandles.importDataFrame.setVisible(false);
    importSelector.importhandles.importDataFrame.toFront;
    
    % close the importselector if the siminput table is hidden    
    importSelector.addlisteners(handle.listener(importSelector.importtable,...
        findprop(importSelector.importtable,'visible'),'PropertyPostSet', ...
        {@localVisibilityToggle importSelector}));
    
    % and this window close callback
    hc = handle(importSelector.importhandles.BTNclose, 'callbackproperties');
    set(hc,'ActionPerformedCallBack',@(es,ed) localCloseImport(es,ed,importSelector.importhandles.importDataFrame));   
    awtinvoke(importSelector.importhandles.importDataFrame,'pack');
else
    importSelector = h.importSelector;
end % end importselector GUI build

%-------------------- Local Functions ---------------------------

function localBagConstraints(constr)

% Resets the bag layout constraints 
import java.awt.*;
constr.anchor = GridBagConstraints.NORTHWEST;
constr.fill = GridBagConstraints.BOTH;
constr.weightx = 0;
constr.weighty = 0;
constr.gridwidth = 1;
constr.gridheight = 1;
constr.gridx = 0;
constr.gridy = 0;


function localVisibilityToggle(eventSrc, eventData, importSelector)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

importSelector.visible = importSelector.importtable.visible;
awtinvoke(importSelector.importhandles.importDataFrame,'setVisible(Z)',strcmp(importSelector.visible,'on'));

function localFileTypeSelect(eventSrc, eventData, importSelector)

importSelector.importhandles.importDataFrame.setCursor ...
    (java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));  

thisFileType = importSelector.importhandles.COMBOimport.getSelectedItem;
if ~isempty(thisFileType)
    switch thisFileType
        case xlate('Workspace')
            importSelector.filetype = 'wor';
        case xlate('MAT file')
            importSelector.filetype = 'mat';
        case xlate('XLS file')
            importSelector.filetype = 'xls';
        case xlate('ASCII file')
            importSelector.filetype = 'asc';
        case xlate('CSV file')
            importSelector.filetype = 'csv';
    end
end

importSelector.importhandles.importDataFrame.setCursor ...
    (java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));  

function localSwitchPanelVisibility(eventSrc, eventData, importSelector,gridbag)

import java.awt.*;

thisPanel = [];
switch lower(importSelector.filetype)
    case 'wor'
        if isempty(importSelector.workpanel)
            importSelector.workpanel = sharedlsimgui.workpanel(importSelector);
            % prevents vanishing of the import browser if it's resized too small
            importSelector.workpanel.Panel.setMinimumSize(Dimension(264,140));
        end
        thisPanel = importSelector.workpanel.Panel;
    case 'mat'
        if isempty(importSelector.matpanel)
            importSelector.matpanel = sharedlsimgui.matpanel(importSelector);
            % prevents vanishing of the import browser if it's resized too small
            importSelector.matpanel.Panel.setMinimumSize(Dimension(264,140));
        end
        thisPanel = importSelector.matpanel.Panel;
    case 'xls'
        if isempty(importSelector.excelpanel)
            importSelector.excelpanel = sharedlsimgui.excelpanel(importSelector);
        end
        thisPanel = importSelector.excelpanel.Panel;
    case 'csv'
        if isempty(importSelector.csvpanel)
            importSelector.csvpanel = sharedlsimgui.csvpanel(importSelector);
        end
        thisPanel = importSelector.csvpanel.Panel;
    case 'asc'
        if isempty(importSelector.ascpanel)
            importSelector.ascpanel = sharedlsimgui.ascpanel(importSelector);
        end
        thisPanel = importSelector.ascpanel.Panel;
end      
    
if ~isempty(thisPanel)
    constr = GridBagConstraints;
    localBagConstraints(constr);
    constr.weighty = 1;
    constr.weightx = 1;
    constr.gridy = 1;
    constr.gridwidth = 3;
    gridbag.setConstraints(thisPanel,constr);
    awtinvoke(importSelector.importhandles.mainPanel,'add(Ljava.awt.Component;)',thisPanel);
end

% Turn visible panel on first to reduce the flicker
awtinvoke(thisPanel,'setVisible(Z)',true);
thesePanels = {importSelector.workpanel,importSelector.excelpanel,...
                    importSelector.csvpanel,importSelector.matpanel,...
                    importSelector.ascpanel};
for k=1:5 
	if ~isempty(thesePanels{k}) && ~isempty(thesePanels{k}.Panel) && thesePanels{k}.Panel~=thisPanel
        awtinvoke(thesePanels{k}.Panel,'setVisible(Z)',false);
	end
end

awtinvoke(importSelector.importhandles.importDataFrame,'pack');

function localCloseImport(eventSrc, eventData, frame)

% close button callback
awtinvoke(frame,'setVisible(Z)',false);

function localImportFromWorkspace(eventSrc, eventData, importSelector)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% Copies information from currently selected item in the 
% currently selected variable browser

% Find visible browser
switch lower(importSelector.filetype)
	case 'wor'
        importSelector.workpanel.import(importSelector.importtable);
	case 'mat'
        importSelector.matpanel.import(importSelector.importtable);
	case 'xls'
        importSelector.excelpanel.import(importSelector.importtable);
	case 'asc'
        importSelector.ascpanel.import(importSelector.importtable);
	case 'csv'
        importSelector.csvpanel.import(importSelector.importtable);
end
    
% fire rowselect event so that signal summary updates
importSelector.importtable.javasend('userentry','');

function localHelp(eventSrc, eventData)

ctrlguihelp('lsim_importsignal');