function panelHandles = createExcelPanel(ImportSelector)

% CREATEEXCELPANEL builds the Excel file import panel. Returns handles to
% components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:45 $


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
% |PNLxls     |         |       |
% |___________|         |       |
% ______________________        |
%                               |          
% ____________                  |
% PNLoptions  |                 |
%             |                 |
% ____________                  |
% ______________________________


% create file import panel: PNLfile
PNLfile = JPanel(BorderLayout);

LBLfile = JLabel(sprintf('File: '));
javaHandles.TXTfile = JTextField(12);
javaHandles.TXTfile.setName('excelimport:textfield:filename');
javaHandles.BTNfile = JButton(sprintf('Browse...'));
javaHandles.BTNfile.setName('excelimport:button:browse');
LBLsheet = JLabel(sprintf('Select sheet: '));
COMBOsheet = JComboBox;
COMBOsheet.setName('excelimport:combo:sheetname');
COMBOsheet.setSize(120,27);
PNLfileinner1 = JPanel;
PNLfileinner1.add(LBLfile);
PNLfileinner1.add(javaHandles.TXTfile);
PNLfileinner1.add(javaHandles.BTNfile);
PNLfileinner2 = JPanel;
PNLfileinner2.add(LBLsheet);
PNLfileinner2.add(COMBOsheet);
PNLfileinner = JPanel(BorderLayout);
PNLfileinner.add(PNLfileinner1,BorderLayout.WEST);
PNLfileinner.add(Box.createHorizontalGlue,BorderLayout.CENTER);
PNLfileinner.add(PNLfileinner2,BorderLayout.EAST);
PNLfile.add(PNLfileinner, BorderLayout.CENTER);

% Create xls panel
javaHandles.PNLxls = JPanel(BorderLayout);
javaHandles.PNLxls.setPreferredSize(Dimension(650,400));

% Create empty @exceltable
ImportSelector.excelsheet = sharedlsimgui.exceltable;
ImportSelector.excelsheet.initialize;
ImportSelector.excelsheet.STable.setName('excelimport:table:excelsheet');
ImportSelector.excelsheet.addlisteners(handle.listener(ImportSelector.excelsheet, ...
    'rightmenuselect',{@localExcelRightSelect ImportSelector.excelsheet ImportSelector.importtable}));
scroll1 = JScrollPane(ImportSelector.excelsheet.STable);
javaHandles.PNLxls.add(scroll1,BorderLayout.CENTER);

% Build source panel container
PNLsource = JPanel(BorderLayout);
PNLsource.add(PNLfile,BorderLayout.NORTH);
PNLsource.add(javaHandles.PNLxls,BorderLayout.CENTER);
PNLsource.setBorder(BorderFactory.createTitledBorder(sprintf('Data source:')));

% Build options panel
PNLoptions1 = JPanel;
LBLSkipped = JLabel(sprintf('Ignore header rows prior to row: '));
filterHandles.TXTrowEnd = JTextField(5);
filterHandles.TXTrowEnd.setName('excelimport:textfield:header');
filterHandles.TXTrowEnd.setText('1');
set(filterHandles.TXTrowEnd,'Tag','1','ActionPerformedCallback',...
{@localChkNum filterHandles.TXTrowEnd},'FocusLostCallback',{@localChkNum filterHandles.TXTrowEnd});
PNLoptions1.add(LBLSkipped);
PNLoptions1.add(filterHandles.TXTrowEnd);
PNLoptions1outer = JPanel(BorderLayout);
PNLoptions1outer.add(PNLoptions1,BorderLayout.WEST);
PNLoptions2 = JPanel;
LBLbadData = JLabel(sprintf('Bad data substitution method:'));
filterHandles.COMBOinterp = JComboBox;
filterHandles.COMBOinterp.addItem(xlate('Skip rows'));
filterHandles.COMBOinterp.addItem(xlate('Skip cells'));
filterHandles.COMBOinterp.addItem(xlate('Linearly interpolate'));
filterHandles.COMBOinterp.addItem(xlate('Zero order hold'));
filterHandles.COMBOinterp.setName('excelimport:combo:baddata');
PNLoptions2.add(LBLbadData);
PNLoptions2.add(filterHandles.COMBOinterp);
PNLoptions2outer = JPanel(BorderLayout);
PNLoptions2outer.add(PNLoptions2,BorderLayout.WEST);
PNLoptions3 = JPanel(GridLayout(2,1));
PNLoptions3.add(PNLoptions1outer);
PNLoptions3.add(PNLoptions2outer);
PNLoptions = JPanel(BorderLayout);
PNLoptions.add(PNLoptions3, BorderLayout.WEST);
PNLoptions.setBorder(BorderFactory.createTitledBorder(xlate('Options for text and missing data:')));

% callbacks
set(javaHandles.BTNfile, 'ActionPerformedCallback',{@openFile, ImportSelector,  COMBOsheet, ...
        javaHandles.TXTfile, filterHandles.TXTrowEnd});
set(javaHandles.TXTfile,'ActionPerformedCallback', {@localUpdateFile, javaHandles.TXTfile,...
        COMBOsheet ImportSelector, filterHandles.TXTrowEnd});
set(COMBOsheet,'ItemStateChangedCallback',{@localSheetSelect COMBOsheet ImportSelector filterHandles.TXTrowEnd});  
% Build final panel
PNLdata = JPanel(BorderLayout);
PNLdata.add(PNLsource, BorderLayout.CENTER);
PNLdata.add(PNLoptions, BorderLayout.SOUTH);

panelHandles = {PNLdata, javaHandles, filterHandles, scroll1};

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
    
ImportSelector.excelsheet.sheetname = char(COMBOsheet.getSelectedItem);

% set header length
HeadEnd.setText(num2str(min(find(all(isnan(ImportSelector.excelsheet.numdata)')'==false))));

% reset cursor
if ~isempty(thisFrame)
    thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
end
    
function openFile(eventSrc, eventData, ImportSelector, COMBOsheet, TXTfile, HeaderBox)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded with the "Browse" button

[fname pname] = uigetfile('*.xls',sprintf('Select .xls file'));

% Check for cancel
if ~ischar(fname)
    return
end
filename = [pname fname];

% open file and write default header length
HeaderBox.setText(num2str(localProcessFile(filename,ImportSelector, COMBOsheet, TXTfile)));

function localExcelRightSelect(eventSrc, eventData, h, inputtable)

selectedRows = double(h.STable.getSelectedRows)+1;
selectedCols = double(h.STable.getSelectedColumns);

if ~isempty(selectedCols)
    headEnd = str2num(char(inputtable.importSelector.importhandles.filterHandles.TXTrowEnd.getText)); 
    interpStr = inputtable.importSelector.importhandles.filterHandles.COMBOinterp.getSelectedItem; 
    rawdata = xlsInterp(h.numdata, headEnd, interpStr, selectedCols);
    if ~isempty(rawdata)
        inputtable.copieddatabuffer = struct('data',rawdata,'source','xls','length',size(rawdata,1), ...
            'subsource',h.sheetname,'construction',h.filename,'columns',selectedCols);
        % Enable paste and inset menus
        inputtable.STable.getModel.setMenuStatus([1 1 1 1 1]);
    end
end

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
HeadBox.setText(num2str(localProcessFile(file,ImportSelector, COMBOsheet, TXTfile)));

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
if fileerr || length(dir(filename))==0 % should have the full path here
    errordlg(sprintf('File not found'),sprintf('Linear simulation tool'),'modal')
    numericStart = 0;
    return
end 

if ~isempty(status) && length(sheetnames)>0% Don't update anything unless xlsread returns valid status
    
    % turn on hourglass cursor since the spread sheet load may take a while
    thisFrame = ImportSelector.importhandles.importDataFrame;
	if ~isempty(thisFrame)
        thisFrame.setCursor(Cursor(Cursor.WAIT_CURSOR));
	end

    TXTfile.setText(filename);
    
    % update sheet combo box
    COMBOsheet.removeAllItems;
    for k=1:length(sheetnames)
        awtinvoke(COMBOsheet,'addItem(Ljava.lang.Object;)',sheetnames{k});
    end
    
    % listeners will open the spreadsheet
    ImportSelector.excelsheet.filename = filename;
    ImportSelector.excelsheet.sheetname = sheetnames{1};
    
    % find the start row for the numeric data
    numericStart = min(find(all(isnan(ImportSelector.excelsheet.numdata)')'==false));

    % reset cursor
	if ~isempty(thisFrame)
        thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
	end
else
    TXTfile.setText('');
    numericStart = 0;
    errordlg(sprintf('Invalid or empty workbook'),sprintf('Linear simulation tool'),'modal')
end


function outData = xlsInterp(numdata,headEnd,interpMethod,selectedCols)

% find the start row for the numeric data
numericStart = min(find(all(isnan(numdata)')'==false));
if isempty(numericStart) %no numeric data
    outData = [];
    return
end

% the specified header is smaller than the default used by xlsread
if headEnd < numericStart 
    if numericStart>1
        warndlg(sprintf('Using the minimum valid header size of %s row(s)',num2str(numericStart-1)),...
            sprintf('Linear simulation tool'),'modal')
    end
    thisData = numdata(numericStart:end,selectedCols);
else
    thisData = numdata(headEnd:end,selectedCols); 
end
outData = zeros(size(thisData));
switch lower(interpMethod)
case xlate('skip rows')
    if min(size(thisData))>=2
        goodRows = find(max(isnan(thisData)')'==0);
    else
        goodRows = find(isnan(thisData)==0);
    end
    outData = thisData(goodRows,:);
case xlate('skip cells')
    
    if size(thisData,1)>1
         outData = NaN*zeros(max(sum(~isnan(thisData))),size(thisData,2));
    else
         outData = NaN*zeros(1,size(thisData,2));
    end
    % dimensions are longest skipped column x all selected rows
    for col=1:length(selectedCols)
        I = find(~isnan(thisData(:,col)));
        if length(I)>1
             outData(1:length(I),col) = thisData(I,col);
        else
             errordlg(sprintf('One or more columns has no numeric data, aborting import'),...
                 sprintf('Linear simulation tool'),'modal')
             outData = [];
             return
        end
    end 
  
case xlate('linearly interpolate')
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 | I(end) == 1
            errordlg(sprintf('Cannot extrpolate over non-numeric data'),...
                sprintf('Linear simulation tool'),'modal');
            outData = [];
            return
        else
            ind = find(I==0);
            y = thisData(ind,col);
            xraw = 1:size(thisData,1);
            if length(xraw)>=2 && length(ind)>=2
                outData(:,col) = interp1(ind,y,xraw,'linear')';
            else
                errordlg(sprintf('Cannot interpolate less than 2 points'),...
                    sprintf('Linear simulation tool'),'modal')
                outData = [];
            end
        end
    end
case xlate('zero order hold')
    for col=1:length(selectedCols)
        I = isnan(thisData(:,col));
        if I(1) == 1 
            errordlg(sprintf('Cannot start with non-numeric data. Use header specification to exclude these cells'),...
                sprintf('Linear simulation tool'),'modal');
            return
        else
            temp = thisData(find(~I),col);
            outData(:,col) = temp(cumsum(~I));
        end
    end    
end

if isempty(outData) || min(size(outData))<1
    errordlg(sprintf('One or more columns has no numeric data, aborting copy'),...
        sprintf('Linear simulation tool'),'modal')
    outData = [];
    return
end

function localChkNum(eventSrc, eventData, textbox)

boxcontents = char(textbox.getText);
try 
    eval([boxcontents ';']);
catch
    errordlg(sprintf('%s is an invalid text box entry',boxcontents),...
        sprintf('Linear simulation tool'),'modal')
    textbox.setText(get(textbox,'Tag'));
end
