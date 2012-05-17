function h = matpanel(importSelector)
% MATPANEL @matpanel constructor
%
% Builds the MAT file import panel. Returns handles to components
% with callbacks, since there need to remain in scope
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 21:45:34 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h= sharedlsimgui.matpanel;


% Panel organization

% ______________________
% PNLdata               |
% ___________           |
% |PNLfile    |         |
% |___________|         |
%                       |
% ____________          |
% |PNLbrowser |         |
% |___________|         |
% ______________________

%workspace browser
h.matbrowser = sharedlsimgui.varbrowser;
h.matbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
h.matbrowser.javahandle.setName('matimport:browser:matvars');
% assign the copy callback
h.matbrowser.addlisteners(handle.listener(h.matbrowser,'rightmenuselect',...
    {@localWorkpsaceCopy importSelector}));

PNLbrowser = JPanel(BorderLayout(10,10));
PNLbrowser.add(h.matbrowser.javahandle,BorderLayout.CENTER);
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

PNLbrowser.add(PNLrowcols,BorderLayout.SOUTH);
PNLbrowser.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

% file panel
PNLfile = JPanel(FlowLayout(FlowLayout.LEFT));
PNLfile.setBorder(EmptyBorder(0,0,0,0));
LBLfile = JLabel(sprintf('File:'),SwingConstants.LEFT);
h.Jhandles.TXTfile = JTextField;
h.Jhandles.TXTfile.setName('matimport:textfield:filename');
h.Jhandles.TXTfile.setColumns(12);
h.Jhandles.BTNfile = JButton(sprintf('Browse...'));
h.Jhandles.BTNfile.setName('matimport:button:browse');
PNLfile.add(LBLfile);
PNLfile.add(h.Jhandles.TXTfile);
PNLfile.add(h.Jhandles.BTNfile);

% file open callbacks
hc = handle(h.Jhandles.BTNfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localMATfileOpen(es,ed,h));
hc = handle(h.Jhandles.TXTfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localthisMATfileOpen(es,ed,h.matbrowser, h.Jhandles.TXTfile));


% list selection listener
radios = {h.FilterHandles.radioCol, h.FilterHandles.radioRow};
selections = {h.FilterHandles.TXTselectedCols h.FilterHandles.TXTselectedRows};
h.matbrowser.addlisteners(handle.listener(h.matbrowser,'listselect',...
      {@localMatSelect h.matbrowser, radios, selections}));

% Radio button selection listener
% set(h.FilterHandles.radioCol, 'StateChangedCallback', ...
%     {@localMatSelect h.matbrowser, radios, selections});

%PNLfile.setBorder(BorderFactory.createEmptyBorder(0,10,0,0));

PNLdata = JPanel(BorderLayout(0,0));
PNLdata.add(PNLfile,BorderLayout.NORTH);
PNLdata.add(PNLbrowser,BorderLayout.CENTER);
h.Panel = PNLdata;

%-------------------- Local Functions ---------------------------

function localWorkpsaceCopy(eventSrc, eventData, importSelector)

importSelector.matpanel.import(importSelector.importtable,'copy');

function localMATfileOpen(eventSrc, eventData, h)

[fname pname] = uigetfile([h.Folder '*.mat'],sprintf('Select MAT file'));
if strcmp(class(fname),'char')
    h.Jhandles.TXTfile.setText([pname fname]);
    h.Folder = pname;
    localthisMATfileOpen([], [], h.matbrowser,h.Jhandles.TXTfile)
end

function localthisMATfileOpen(eventSrc, eventData, matbrowser,TXTfile)

try
    matbrowser.filename = eval(char(TXTfile.getText),['''' char(TXTfile.getText) '''']);
    if isempty(matbrowser.filename) % No filename - clear vars
        matbrowser.variables = [];
        matbrowser.javahandle.removeAllItems;
    else
        matbrowser.open;
    end
catch
    matbrowser.filename = '';
    TXTfile.setText('');
    errordlg(sprintf('Invalid file or file not found'), sprintf('MAT File Import'),'modal')
end


function localMatSelect(eventSrc, eventData, h, radios, TXTcolrow)

% listener callback to write the number of cols/rows of the selected
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
