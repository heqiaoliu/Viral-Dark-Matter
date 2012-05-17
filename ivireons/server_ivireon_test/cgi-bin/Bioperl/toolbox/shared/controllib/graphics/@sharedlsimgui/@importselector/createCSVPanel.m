function panelHandles = createCSVPanel(ImportSelector)

% CREATEASCPANEL builds the csv file import panel. Returns handles to components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:04 $


import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;


% Panel organization

%_______________________________
% PNLdata                       |
%                               |
% ______________________        |
% PNLsource             |       |
% ___________           |       |
% |PNLfile    |         |       |
% |___________|         |       |
%                       |       |
% ____________          |       |
% |PNLcsv     |         |       |
% |___________|         |       |
% ______________________        |
%                               |          
% ______________________________


% Set up "Data Source" panel: PNLdata

gridbagDataSource = GridBagLayout;
gridbagData = GridBagLayout;
constr = GridBagConstraints;

% create file import panel: PNLfile
%PNLfile1 = JPanel(FlowLayout(FlowLayout.LEFT));
PNLfile = JPanel(FlowLayout(FlowLayout.LEFT));
LBLfile = JLabel(sprintf('File: '));
TXTfile = JTextField(12);
TXTfile.setName('csvimport:textfield:filename');
BTNfile = JButton(sprintf('Browse...'));
BTNfile.setName('csvimport:button:browse');
PNLfile.add(LBLfile);
PNLfile.add(TXTfile);
PNLfile.add(BTNfile);
localBagConstraints(constr);
constr.weightx  = 0;
constr.weighty = 0;
constr.fill = GridBagConstraints.BOTH;
gridbagDataSource.setConstraints(PNLfile,constr);

% Create csv panel
PNLcsv = JPanel(BorderLayout);
PNLcsv.setPreferredSize(Dimension(650,400));

% Create empty @csvtable
ImportSelector.csvsheet = sharedlsimgui.csvtable;
ImportSelector.csvsheet.initialize;
ImportSelector.csvsheet.STable.setName('csvimport:table:csvsheet');
ImportSelector.csvsheet.addlisteners(handle.listener(ImportSelector.csvsheet, ...
    'rightmenuselect',{@localCSVRightSelect ImportSelector.csvsheet ImportSelector.importtable}));
scroll1 = JScrollPane(ImportSelector.csvsheet.STable);
PNLcsv.add(scroll1,BorderLayout.CENTER);
set(BTNfile, 'ActionPerformedCallback',{@openFile, ImportSelector, PNLcsv, TXTfile});
set(TXTfile,'ActionPerformedCallback', {@openThisFile, ImportSelector, TXTfile});
localBagConstraints(constr);
constr.gridy = 1;
constr.gridwidth = GridBagConstraints.REMAINDER;
constr.weightx = 1;
constr.weighty = 1;
gridbagDataSource.setConstraints(PNLcsv,constr);

% Build source panel container
PNLsource = JPanel(gridbagDataSource);
PNLsource.add(PNLfile);
PNLsource.add(PNLcsv);
localBagConstraints(constr);
constr.weightx = 1;
constr.weighty = 1;
gridbagData.setConstraints(PNLsource,constr);
PNLsource.setBorder(BorderFactory.createTitledBorder(sprintf('Data source:')));

% Buil final panel
PNLdata = JPanel(gridbagData);
PNLdata.add(PNLsource);

panelHandles = {PNLdata, BTNfile, PNLcsv, TXTfile};

%-------------------- Local Functions ---------------------------

function localSheetSelect(eventSrc, eventData, COMBOsheet, ImportSelector)

ImportSelector.csvsheet.sheetname = char(COMBOsheet.getSelectedItem);

function openFile(eventSrc, eventData, ImportSelector, PNLcsv,  TXTfile)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded

[fname pname] = uigetfile('*.csv',sprintf('Select .csv file'));

% Check for cancel
if isempty(fname) | ~ischar(fname)
    return
end

filename = [pname fname];
TXTfile.setText(filename);
ImportSelector.csvsheet.filename = filename;

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

function localCSVRightSelect(eventSrc, eventData, h, inputtable)

selectedRows = double(h.STable.getSelectedRows)+1;
selectedCols = double(h.STable.getSelectedColumns);

if ~isempty(selectedCols)
    rawdata = csvread(h.filename);
    copyStruc.data = rawdata(:,selectedCols);
    copyStruc.source = 'csv';
    copyStruc.length = length(h.celldata)/length(h.colnames);
    copyStruc.subsource = '';
    copyStruc.construction = h.filename;
    copyStruc.columns = selectedCols; 
    inputtable.copieddatabuffer = copyStruc;
    
    % Enable paste and inset menus
    inputtable.STable.getModel.setMenuStatus([1 1 1 1 1]);
    
end

function openThisFile(eventSrc, eventData, ImportSelector, TXTfile)

ImportSelector.csvsheet.filename = char(TXTfile.getText);