function h = excelpanel(importSelector)
% CREATEEXCELPANEL builds the Excel file import panel. Returns handles to
% components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/05/10 17:37:43 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.excelpanel;

% Build North worksheet selection panel
LBLfile = JLabel(sprintf('File: '));
h.Jhandles.TXTfile = JTextField(12);
h.Jhandles.TXTfile.setName('excelimport:textfield:filename');
h.Jhandles.BTNfile = JButton(sprintf('Browse...'));
h.Jhandles.BTNfile.setName('excelimport:button:browse');
LBLsheet = JLabel(sprintf('       Select sheet: '));
COMBOsheet = JComboBox;
COMBOsheet.setName('excelimport:combo:sheetname');
COMBOsheet.setPreferredSize(h.Jhandles.TXTfile.getPreferredSize);
outerworksheetselectPnl = JPanel(BorderLayout(5,5));
worksheetselectPnl = JPanel(FlowLayout.LEFT);
worksheetselectPnl.add(LBLfile);
worksheetselectPnl.add(h.Jhandles.TXTfile);
worksheetselectPnl.add(h.Jhandles.BTNfile);
worksheetselectPnl.add(LBLsheet);
worksheetselectPnl.add(COMBOsheet);
outerworksheetselectPnl.setBorder(EmptyBorder(0,0,10,0));
outerworksheetselectPnl.add(worksheetselectPnl,BorderLayout.WEST);
outerworksheetselectPnl.add(Box.createHorizontalGlue,BorderLayout.CENTER);

% Create center Excel table panel
h.Jhandles.PNLxls = JPanel(GridLayout(1,1));
h.Jhandles.PNLxls.setPreferredSize(Dimension(650,400));
h.excelsheet = sharedlsimgui.exceltable;
h.excelsheet.initialize;
h.excelsheet.STable.setName('excelimport:table:excelsheet');
h.excelsheet.addlisteners(handle.listener(h.excelsheet, ...
    'rightmenuselect',{@localExcelRightSelect importSelector}));
h.Jhandles.scroll1 = JScrollPane(h.excelsheet.STable);
h.Jhandles.PNLxls.add(h.Jhandles.scroll1);

% Build selection options panel 
LBLSkipped = JLabel(sprintf('Ignore header rows prior to row: '));
h.filterHandles.TXTrowEnd = JTextField(5);
h.filterHandles.TXTrowEnd.setName('excelimport:textfield:header');
h.filterHandles.TXTrowEnd.setText('1');
set(h.filterHandles.TXTrowEnd,'Tag','1')
hc = handle(h.filterHandles.TXTrowEnd, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localChkNum(es,ed,h.filterHandles.TXTrowEnd)); 
set(hc,'FocusLostCallback',@(es,ed) localChkNum(es,ed,h.filterHandles.TXTrowEnd)); 
LBLbadData = JLabel(sprintf('Bad data substitution method:'));
h.FilterHandles.COMBOinterp = JComboBox;
interpmethods = {xlate('Skip rows'),xlate('Skip cells'),xlate('Linearly interpolate'),xlate('Zero order hold')};
for k=1:length(interpmethods)
    h.FilterHandles.COMBOinterp.addItem(interpmethods{k});
end
h.FilterHandles.COMBOinterp.setName('excelimport:combo:baddata');
optionsPnl = JPanel(BorderLayout);
optionsPnl.setBorder(BorderFactory.createTitledBorder(sprintf('Text and Missing Data')));

optionsgridPnl = JPanel(GridLayout(2,2,0,10));
optionsgridPnl.add(LBLSkipped);
optionsgridPnl.add(h.filterHandles.TXTrowEnd);
optionsgridPnl.add(LBLbadData);
optionsgridPnl.add(h.FilterHandles.COMBOinterp);
optionsgridPnl.setBorder(EmptyBorder(5,5,5,0));
optionsPnl.add(optionsgridPnl,BorderLayout.WEST);
optionsPnl.add(Box.createHorizontalGlue,BorderLayout.CENTER);


% callbacks
hc = handle(h.Jhandles.BTNfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) openFile(es,ed,importSelector,  COMBOsheet, ...
        h.Jhandles.TXTfile, h.filterHandles.TXTrowEnd, h));     
hc = handle(h.Jhandles.TXTfile, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) localUpdateFile(es,ed,h.Jhandles.TXTfile,...
        COMBOsheet, importSelector, h.filterHandles.TXTrowEnd));
hc = handle(COMBOsheet, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) localSheetSelect(es,ed,COMBOsheet,...
    importSelector, h.filterHandles.TXTrowEnd));

% Build final panel
PNLdata = JPanel(BorderLayout);
PNLdata.add(outerworksheetselectPnl, BorderLayout.NORTH);
PNLdata.add(h.Jhandles.PNLxls, BorderLayout.CENTER);
PNLdata.add(optionsPnl, BorderLayout.SOUTH);

h.Panel = PNLdata;

%-------------------- Local Functions ---------------------------


function localSheetSelect(eventSrc, eventData, COMBOsheet, ImportSelector, HeadEnd)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

% turn on hourglass cursor since the spread sheet load may take a while
thisFrame = ImportSelector.importhandles.importDataFrame;
if ~isempty(thisFrame)
    thisFrame.setCursor(Cursor(Cursor.WAIT_CURSOR));
end
    
ImportSelector.excelpanel.excelsheet.sheetname = char(COMBOsheet.getSelectedItem);

% set header length
HeadEnd.setText(num2str(min(find(all(isnan(ImportSelector.excelpanel.excelsheet.numdata)')'==false))));

% reset cursor
if ~isempty(thisFrame)
    thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
end
    
function openFile(eventSrc, eventData, ImportSelector, COMBOsheet, TXTfile, HeaderBox, h)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded with the "Browse" button

[fname pname] = uigetfile([h.Folder '*.xls'],sprintf('Select .xls file'));

% Check for cancel
if ~ischar(fname)
    return
end
filename = [pname fname];
h.Folder = pname;
% open file and write default header length
awtinvoke(HeaderBox,'setText(Ljava.lang.String;)',num2str(localProcessFile(filename,ImportSelector, COMBOsheet, TXTfile)));

function localExcelRightSelect(eventSrc, eventData, importSelector)

importSelector.excelpanel.import(importSelector.importtable,'copy');

function localUpdateFile(eventSrc, eventData, TXTfile,COMBOsheet, ImportSelector, HeadBox)

file = char(TXTfile.getText);
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

% Callback for the file text box
awtinvoke(HeadBox,'setText(Ljava.lang.String;)',num2str(localProcessFile(file,ImportSelector, COMBOsheet, TXTfile)));

function numericStart = localProcessFile(filename,ImportSelector, COMBOsheet, TXTfile)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded and returns the default header length

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

fileerr = false;
try
    [status, sheetnames] = xlsfinfo(filename); 
catch
    fileerr = true;
end
if fileerr || isempty(dir(filename)) % should have the full path here
    errordlg(sprintf('File not found'),sprintf('Excel File Import'),'modal')
    numericStart = 0;
    return
end    
    
if ~isempty(status) && ~isempty(sheetnames)% Don't update anything unless xlsread returns valid status
    
    % turn on hourglass cursor since the spread sheet load may take a while
    thisFrame = ImportSelector.importhandles.importDataFrame;
	if ~isempty(thisFrame)
        awtinvoke(thisFrame,'setCursor(Ljava.awt.Cursor;)',Cursor(Cursor.WAIT_CURSOR));
	end

    awtinvoke(TXTfile,'setText(Ljava.lang.String;)',filename);
    
    % update sheet combo box
    COMBOsheet.removeAllItems;
    for k=1:length(sheetnames)
        awtinvoke(COMBOsheet,'addItem(Ljava.lang.Object;)',sheetnames{k});
    end
    
    % listeners will open the spreadsheet
    ImportSelector.excelpanel.excelsheet.filename = filename;
    ImportSelector.excelpanel.excelsheet.sheetname = sheetnames{1};
    
    % find the start row for the numeric data
    numericStart = min(find(all(isnan(ImportSelector.excelpanel.excelsheet.numdata)')'==false));

    % reset cursor
	if ~isempty(thisFrame)
        awtinvoke(thisFrame,'setCursor(Ljava.awt.Cursor;)',Cursor(Cursor.DEFAULT_CURSOR));
	end
else
    awtinvoke(TXTfile,'setText(Ljava.lang.String;)','');
    numericStart = 0;
    errordlg(sprintf('Invalid or empty workbook'),sprintf('Excel File Import'),'modal')
end


function localChkNum(eventSrc, eventData, textbox)

boxcontents = char(textbox.getText);
try 
    eval([boxcontents ';']);
catch
    errordlg(sprintf('%s is an invalid text box entry',boxcontents),sprintf('Excel File Import'),'modal')
    awtinvoke(textbox,'setText(Ljava.lang.String;)',get(textbox,'Tag'));
end