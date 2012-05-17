function h = ascpanel(ImportSelector)
% ASCPANEL @ascpanel constructor
%
% Builds the ascii file import panel. Returns handles to components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 21:45:31 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.ascpanel;

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
h.Jhandles.TXTfile = JTextField(12);
h.Jhandles.TXTfile.setName('asciiimport:textfield:filename');
h.Jhandles.BTNfile = JButton(sprintf('Browse...'));
h.Jhandles.BTNfile.setName('asciiimport:button:browse');
LBLdelimiter = JLabel(sprintf('Select delimiter character: '));
h.FilterHandles.COMBOdelimiter = JComboBox;
h.FilterHandles.COMBOdelimiter.setName('asciiimport:combo:delim');
h.FilterHandles.COMBOdelimiter.addItem(xlate('space'));
h.FilterHandles.COMBOdelimiter.addItem(',');
h.FilterHandles.COMBOdelimiter.addItem(':');
h.FilterHandles.COMBOdelimiter.addItem(xlate('tab'));
h.FilterHandles.COMBOdelimiter.addItem(xlate('(default)'));
PNLfileinner1.add(LBLfile);
PNLfileinner1.add(h.Jhandles.TXTfile);
PNLfileinner1.add(h.Jhandles.BTNfile);
PNLfileinner2 = JPanel;
PNLfileinner2.add(LBLdelimiter);
PNLfileinner2.add(h.FilterHandles.COMBOdelimiter);
PNLfileinner = JPanel(BorderLayout);
PNLfileinner.add(PNLfileinner1,BorderLayout.WEST);
PNLfileinner.add(Box.createHorizontalGlue,BorderLayout.CENTER);
PNLfileinner.add(PNLfileinner2,BorderLayout.EAST);
PNLfile = JPanel(BorderLayout);
PNLfile.add(PNLfileinner, BorderLayout.CENTER);
hc = handle(h.FilterHandles.COMBOdelimiter, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localRender(es,ed,h.FilterHandles.COMBOdelimiter,ImportSelector));
localBagConstraints(constr);
constr.anchor = GridBagConstraints.NORTH;
constr.weightx  = 1;
gridbagDataSource.setConstraints(PNLfile,constr);

% Create ascii panel
h.Jhandles.PNLasc = JPanel(BorderLayout);
h.Jhandles.PNLasc.setPreferredSize(Dimension(455,280));

% Create empty @exceltable
h.ascsheet = sharedlsimgui.asctable;
h.ascsheet.initialize;
h.ascsheet.STable.setName('asciiimport:table:ascsheet');
h.ascsheet.addlisteners(handle.listener(h.ascsheet, ...
    'rightmenuselect',{@localASCRightSelect ImportSelector}));
scroll1 = JScrollPane(h.ascsheet.STable);
h.Jhandles.PNLasc.add(scroll1,BorderLayout.CENTER);

% set file open callbacks
hc = handle(h.Jhandles.BTNfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) openFile(es,ed, h.ascsheet, h.FilterHandles.COMBOdelimiter, h.Jhandles.TXTfile, h));
hc = handle(h.Jhandles.TXTfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localProcessFile(es,ed,h.ascsheet,  h.FilterHandles.COMBOdelimiter,  h.Jhandles.TXTfile));

localBagConstraints(constr);
constr.gridy = 1;
constr.gridwidth = GridBagConstraints.REMAINDER;
constr.weightx = 1;
constr.weighty = 1;
gridbagDataSource.setConstraints(h.Jhandles.PNLasc,constr);

% Build source panel container
PNLsource = JPanel(gridbagDataSource);
PNLsource.add(PNLfile);
PNLsource.add(h.Jhandles.PNLasc);
localBagConstraints(constr);
constr.weightx = 1;
constr.weighty = 1;
gridbagData.setConstraints(PNLsource,constr);
%PNLsource.setBorder(BorderFactory.createTitledBorder('Data source:'));

% Build final panel
PNLdata = JPanel(gridbagData);
PNLdata.add(PNLsource);

h.Panel = PNLdata;


%-------------------- Local Functions ---------------------------

function localRender(eventSrc, eventData, COMBOdelimiter, ImportSelector)

% (Re)renders asctable when delimiter is changed
delimiter = localParseDelimiter(COMBOdelimiter);
ImportSelector.ascpanel.ascsheet.delimiter = delimiter;


function openFile(eventSrc, eventData, ascsheet, COMBOdelimiter, TXTfile,h)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded


[fname pname] = uigetfile([h.Folder '*.txt;*.tab;*.dlm'],sprintf('Select file'));

% Check for cancel
if ~ischar(fname)
    return
end
h.Folder = pname;
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


function localASCRightSelect(eventSrc, eventData, importSelector)

importSelector.ascpanel.import(importSelector.importtable,'copy');

function delimiter = localParseDelimiter(COMBOdelimiter)

% (Re)renders asctable when delimiter is changed
delimiter = char(COMBOdelimiter.getSelectedItem);
if length(delimiter)>1
    switch delimiter
    case xlate('space')
        delimiter = ' ';
    case xlate('tab')
        delimiter = '\t';
    case xlate('(default)')
        delimiter = '';
    otherwise
        ctrlMsgUtils.error('Controllib:gui:SharedLsimGUI1')
    end
end


function localProcessFile(eventSrc, eventData, ascsheet, COMBOdelimiter, TXTfile)

file = eval(char(TXTfile.getText),['''' char(TXTfile.getText) '''']);
if ~isempty(file) % Do not try to append an empty file
    [pathname filename ext] = fileparts(file); 
    if isempty(pathname) 
       if isunix
          file = [pwd '/' file];
       else
          file = [pwd '\' file];
       end
    end
    if isempty(ext)
       file = [file '.xls'];
    end
end
try
    ascsheet.filename = file;
    ascsheet.delimiter = localParseDelimiter(COMBOdelimiter);
catch ME
    errordlg(ME.message,'Ascii File Import','modal')
end

