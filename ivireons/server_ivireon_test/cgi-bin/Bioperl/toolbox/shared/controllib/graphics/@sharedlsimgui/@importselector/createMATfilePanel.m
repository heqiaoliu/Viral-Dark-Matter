function panelHandles = createMATfilePanel(importSelector)

% CREATEMATFILEPANEL builds the MAT file import panel. Returns handles to components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:06 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

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
matbrowser = sharedlsimgui.varbrowser;
matbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
matbrowser.javahandle.setName('matimport:browser:matvars');
% assign the copy callback
matbrowser.addlisteners(handle.listener(matbrowser,'rightmenuselect',...
    {@localWorkpsaceCopy matbrowser importSelector}));

% browser panel
PNLbrowser = JPanel(BorderLayout);
PNLbrowser.add(matbrowser.javahandle,BorderLayout.CENTER);
PNLcols = JPanel;
javaHandles.TXTcols = JTextField(6);
javaHandles.TXTcols.setName('matimport:textfield:whichcols');
LBLcols = JLabel(sprintf('Selected columns:'));
PNLcols.add(LBLcols);
PNLcols.add(javaHandles.TXTcols);
PNLcolsouter = JPanel(BorderLayout);
PNLcolsouter.add(PNLcols,BorderLayout.WEST);
PNLbrowser.add(PNLcolsouter,BorderLayout.SOUTH);

% file panel
PNLfile = JPanel(BorderLayout);
PNLfileinner = JPanel;
LBLfile = JLabel(sprintf('File:'),SwingConstants.LEFT);
javaHandles.TXTfile = JTextField;
javaHandles.TXTfile.setName('matimport:textfield:filename');
javaHandles.TXTfile.setColumns(12);
javaHandles.BTNfile = JButton(sprintf('Browse...'));
javaHandles.BTNfile.setName('matimport:button:browse');
PNLfileinner.add(LBLfile);
PNLfileinner.add(javaHandles.TXTfile);
PNLfileinner.add(javaHandles.BTNfile);
PNLfile.add(PNLfileinner,BorderLayout.WEST);

% file open callbacks
set(javaHandles.BTNfile, 'ActionPerformedCallBack', {@localMATfileOpen matbrowser javaHandles.TXTfile});
set(javaHandles.TXTfile, 'ActionPerformedCallBack', {@localthisMATfileOpen matbrowser javaHandles.TXTfile});

% list selection listener
matbrowser.addlisteners(handle.listener(matbrowser,'listselect',...
    {@localMATfileSelect matbrowser javaHandles.TXTcols}));

PNLfile.setBorder(BorderFactory.createEmptyBorder(20,0,20,20));

PNLdata = JPanel(BorderLayout);
PNLdata.add(PNLfile,BorderLayout.NORTH);
PNLdata.add(PNLbrowser,BorderLayout.CENTER);
PNLdata.setBorder(BorderFactory.createTitledBorder(sprintf('Data source:')));

panelHandles = {PNLdata, javaHandles, matbrowser};

%-------------------- Local Functions ---------------------------

function localWorkpsaceCopy(eventSrc, eventData, browser, importSelector)

% created a copyStruc from the matfile browser selected variable and
% transfers it to the copieddatabuffer property of the @importslector

thisRow = double(browser.javahandle.getSelectedRows);
if ~isempty(thisRow)
    loadedData = load(browser.filename, browser.variables(thisRow+1).name);
    thisSize = browser.variables(thisRow+1).size;
    copyStruc.source = 'mat';
    copyStruc.length = thisSize(1);
    copyStruc.subsource = browser.variables(thisRow+1).name;
    copyStruc.construction = browser.filename;
    copyStruc.columns = [1:thisSize(2)];
    copyStruc.data = getfield(loadedData,browser.variables(thisRow+1).name);
    importSelector.importtable.copieddatabuffer = copyStruc;
    % Enable paste and inset menus
    importSelector.importtable.getModel.setMenuStatus([1 1 1 1 1]);
end

function localMATfileOpen(eventSrc, eventData, matbrowser,TXTfile)

[fname pname] = uigetfile('*.mat',sprintf('Select MAT file'));
if strcmp(class(fname),'char')
    TXTfile.setText([pname fname]);
    localthisMATfileOpen([], [], matbrowser,TXTfile)  
end

function localthisMATfileOpen(eventSrc, eventData, matbrowser,TXTfile)

try
    matbrowser.filename = char(TXTfile.getText);
    matbrowser.open
catch
    matbrowser.filename = '';
    TXTfile.setText('');
    errordlg(sprintf('Invalid file or file not found'),sprintf('Linear simulation tool'),'modal')
end

function localMATfileSelect(eventSrc, eventData, h, TXTselectedCols)

% listener callback to write the number of cols of the selected 
% variable to the matbrowser "columns selected" textbox

varstruc = h.getSelectedVarInfo;
if ~isempty(varstruc) 
    if varstruc.size(2)>=2
        TXTselectedCols.setText(['[1:' num2str(varstruc.size(2)) ']']);
    elseif varstruc.size(2)==1
        TXTselectedCols.setText('1');
    end
end