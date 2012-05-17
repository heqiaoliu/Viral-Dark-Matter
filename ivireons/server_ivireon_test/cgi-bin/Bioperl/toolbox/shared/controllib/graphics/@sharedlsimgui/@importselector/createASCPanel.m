function panelHandles = createASCPanel(ImportSelector)

% CREATEASCPANEL builds the ascii file import panel.Returns handles to
% components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:03 $

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
% |PNLasc     |         |       |
% |___________|         |       |
% ______________________        |
%                               |       
% ______________________________


% Set up "Data Source" panel: PNLdata
gridbagDataSource = GridBagLayout;
gridbagData = GridBagLayout;
constr = GridBagConstraints;

% create file import panel: PNLfile
PNLfileinner1 = JPanel(FlowLayout(FlowLayout.LEFT,5,5));
LBLfile = JLabel(sprintf('File: '));
javaHandles.TXTfile = JTextField(12);
javaHandles.TXTfile.setName('asciiimport:textfield:filename');
javaHandles.BTNfile = JButton(sprintf('Browse...'));
javaHandles.BTNfile.setName('asciiimport:button:browse');
LBLdelimiter = JLabel(sprintf('Select delimiter character: '));
COMBOdelimiter = JComboBox;
COMBOdelimiter.setName('asciiimport:combo:delim');
COMBOdelimiter.addItem(xlate('space'));
COMBOdelimiter.addItem(',');
COMBOdelimiter.addItem(':');
COMBOdelimiter.addItem(xlate('tab'));
PNLfileinner1.add(LBLfile);
PNLfileinner1.add(javaHandles.TXTfile);
PNLfileinner1.add(javaHandles.BTNfile);
PNLfileinner2 = JPanel;
PNLfileinner2.add(LBLdelimiter);
PNLfileinner2.add(COMBOdelimiter);
PNLfileinner = JPanel(BorderLayout);
PNLfileinner.add(PNLfileinner1,BorderLayout.WEST);
PNLfileinner.add(Box.createHorizontalGlue,BorderLayout.CENTER);
PNLfileinner.add(PNLfileinner2,BorderLayout.EAST);
PNLfile = JPanel(BorderLayout);
PNLfile.add(PNLfileinner, BorderLayout.CENTER);
set(COMBOdelimiter,'ItemStateChangedCallback',{@localRender COMBOdelimiter ImportSelector});
localBagConstraints(constr);
constr.anchor = GridBagConstraints.NORTH;
constr.weightx  = 1;
gridbagDataSource.setConstraints(PNLfile,constr);

% Create ascii panel
PNLasc = JPanel(BorderLayout);
PNLasc.setPreferredSize(Dimension(650,400));

% Create empty @exceltable
ImportSelector.ascsheet = sharedlsimgui.asctable;
ImportSelector.ascsheet.initialize;
ImportSelector.ascsheet.STable.setName('asciiimport:table:ascsheet');
ImportSelector.ascsheet.addlisteners(handle.listener(ImportSelector.ascsheet, ...
    'rightmenuselect',{@localASCRightSelect ImportSelector.ascsheet ImportSelector.importtable}));
scroll1 = JScrollPane(ImportSelector.ascsheet.STable);
PNLasc.add(scroll1,BorderLayout.CENTER);

% set file open callbacks
set(javaHandles.BTNfile, 'ActionPerformedCallback',{@openFile, ImportSelector.ascsheet, COMBOdelimiter, javaHandles.TXTfile});
set(javaHandles.TXTfile, 'ActionPerformedCallback',{@localProcessFile ImportSelector.ascsheet  COMBOdelimiter  javaHandles.TXTfile});

localBagConstraints(constr);
constr.gridy = 1;
constr.gridwidth = GridBagConstraints.REMAINDER;
constr.weightx = 1;
constr.weighty = 1;
gridbagDataSource.setConstraints(PNLasc,constr);

% Build source panel container
PNLsource = JPanel(gridbagDataSource);
PNLsource.add(PNLfile);
PNLsource.add(PNLasc);
localBagConstraints(constr);
constr.weightx = 1;
constr.weighty = 1;
gridbagData.setConstraints(PNLsource,constr);
PNLsource.setBorder(BorderFactory.createTitledBorder(sprintf('Data source:')));

% Build final panel
PNLdata = JPanel(gridbagData);
PNLdata.add(PNLsource);


panelHandles = {PNLdata, javaHandles, PNLasc, COMBOdelimiter};

%-------------------- Local Functions ---------------------------

function localRender(eventSrc, eventData, COMBOdelimiter, ImportSelector)

% (Re)renders asctable when delimiter is changed
delimiter = localParseDelimiter(COMBOdelimiter);
ImportSelector.ascsheet.delimiter = delimiter;


function openFile(eventSrc, eventData, ascsheet, COMBOdelimiter, TXTfile)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded

[fname pname] = uigetfile({'*.txt;*.tab;*.dlm;*.tab'},sprintf('Select file'));

% Check for cancel
if ~ischar(fname)
    return
end
TXTfile.setText([pname fname]);
if ischar(fname)
    localProcessFile([],[],ascsheet, COMBOdelimiter, TXTfile)
end

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


function localASCRightSelect(eventSrc, eventData, h, inputtable)

selectedRows = double(h.STable.getSelectedRows)+1;
selectedCols = double(h.STable.getSelectedColumns);

if ~isempty(selectedCols)
    rawdata = dlmread(h.filename,h.delimiter);
    copyStruc.data = rawdata(:,selectedCols);
    copyStruc.source = 'asc';
    copyStruc.length = length(h.celldata)/length(h.colnames);
    copyStruc.subsource = h.delimiter;
    copyStruc.construction = h.filename;
    copyStruc.columns = selectedCols; 
    inputtable.copieddatabuffer = copyStruc;
    % Enable paste and inset menus
    inputtable.STable.getModel.setMenuStatus([1 1 1 1 1]);
end


function delimiter = localParseDelimiter(COMBOdelimiter)

% (Re)renders asctable when delimiter is changed
delimiter = char(COMBOdelimiter.getSelectedItem);
if length(delimiter)>1
    switch delimiter
    case xlate('space')
        delimiter = ' ';
    case xlate('tab')
        delimiter = '\t';
    otherwise
        ctrlMsgUtils.error('Controllib:gui:SharedLsimGUI1')
    end
end


function localProcessFile(eventSrc, eventData, ascsheet, COMBOdelimiter, TXTfile)

try
    ascsheet.filename = char(TXTfile.getText);
    ascsheet.delimiter = localParseDelimiter(COMBOdelimiter);
catch ME
    errordlg(ME.message,sprintf('Linear simulation tool'),'modal')
end

