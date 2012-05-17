function flag=ReadExcelFile(h,FileName) 
% READEXCELFILE populates the spreadsheet in the activex/uitable
% the input option should be either 'ActiveX' or 'uiTable'

% Author: Rong Chen 
%  Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.9 $ $Date: 2010/04/21 21:33:49 $

import javax.swing.*;

flag=true;
SheetNumber=length(h.IOData.DES);
if ishandle(h.Handle.bar)
   waitbar(40/100,h.Handle.bar);
end
% -------------------------------------------------------------------------
% option is 'ActiveX'
% -------------------------------------------------------------------------
if ~isempty(h.Handles.ActiveX)
    % activex is used to display excel sheet
    h.Handles.ActiveX.EnableUndo=false;
    % get workbook
    eActiveWorkbook=h.Handles.ActiveX.ActiveWorkbook;
    % get sheets
    eSheets = eActiveWorkbook.Sheets;
    % remove all the default sheets from the activex but one
    for i=1:eSheets.Count-1
        eActiveWorkbook.Sheets.Item(1).Delete;
    end
    % read all the sheets into the active workbook, from the last to the
    % first (because a new sheet is always added as the first sheet)
    for k=SheetNumber:-1:1
        % add a new sheet in the ActiveX if the number of sheet is more
        % than 1 and it will automatically be the active sheet
        if k~=SheetNumber
            eActiveWorkbook.Sheets.Add;
        else
            % clear sheet
            eActiveWorkbook.Sheets.Item(1).UsedRange.Clear;
        end
        % rawdata only contain data in the UsedRange of each sheet
        DataRange = h.Handles.originalSheets.Item(k).UsedRange;
        % get the values in the used regions on the worksheet.
        rawdata = DataRange.Value;
        % save the size of each sheet
        tmpSize=size(rawdata);
        h.IOData.originalSheetSize(k,:)=tmpSize;
        % h.IOData.currentSheetSize(k,:)=tmpSize;
        
        % deal with the NaN issue in the rawdata
        if ~iscell(rawdata)
            % sheet contains a single data point or empty
            if ~ischar(rawdata) && isnan(rawdata)
                rawdata={''};
            end
        else
            rawdata1 = rawdata;
            rawdata1(cellfun('isclass',rawdata,'char')) = {0};
            nan_index=cellfun(@isnan,rawdata1);
            rawdata(nan_index)={''};
        end
        
        waitbar(40/100+(20/SheetNumber/100)*k,h.Handle.bar);
        
        % get the active range of the current sheet based on the rawdata
        firstcell = ['A' '1'];
        lastcell = [h.findcolumnletter(size(rawdata,2)), num2str(size(rawdata,1))];
        ActivesheetRange = eActiveWorkbook.ActiveSheet.Range(strcat(firstcell,':',lastcell));
        % write rawdata into the ActX
        set(ActivesheetRange, 'Value', rawdata);
        % change the sheet name as the source sheet name 
        eActiveWorkbook.ActiveSheet.Name=h.IOData.DES{k};
        % waitbar(40/100+(40/SheetNumber/100)*k,h.Handle.bar);
        eActiveWorkbook.ActiveSheet.Range('A1').Activate;
        % save the size of each sheet (Note: it may different from the original one)
        h.IOData.currentSheetSize(k,:)=size(eActiveWorkbook.ActiveSheet.UsedRange.Value);
    end
    
    h.Handles.ActiveX.EnableUndo=true;
end

% -------------------------------------------------------------------------
% option is 'uiTable'
% -------------------------------------------------------------------------
if ~isempty(h.Handles.tsTable)
    % uitable is used to display excel sheet, which is read only
    % populate the sheet combo box 
    set(h.Handles.COMBdataSheet,'String',h.IOData.DES,'Value',1)
    % read all the sheets into the active workbook
    h.IOData.rawdata=struct();
    for k=1:SheetNumber
        % read data from an excel file whose name is supplied from outside
        swarn = warning('off','MATLAB:xlsread:Mode');
        try
            [~,~, rawdata] = xlsread(FileName,h.IOData.DES{k});
        catch %#ok<CTCH>
            errordlg('This is not a valid Excel workbook.',...
                    'Time Series Tools','modal');
            delete(h.Handle.bar);
            flag=false;
            warning(swarn);
            return
        end
        warning(swarn);
        % save the size of each sheet
        tmpSize=size(rawdata);
        h.IOData.originalSheetSize(k,:)=tmpSize;
        if ishandle(h.Handle.bar)
           waitbar(40/100+(20/SheetNumber/100)*k,h.Handle.bar);
        end
        % in this case, since no number format data is available, it is
        % impossible to get the absolute time format anyway
        % replace NaN with '' for correct display in ActX
        % deal with the NaN issue in the rawdata
        if ~iscell(rawdata)
            % sheet contains a single data point or empty
            if ~ischar(rawdata) && isnan(rawdata)
                rawdata={''};
            end
        else
            % replace NaN with '' for correct display
            for i=1:tmpSize(1)
                for j=1:tmpSize(2)
                    if isnan(rawdata{i,j})
                        rawdata(i,j)={''};
                    end
                end
            end
        end
        % save the rawdata into memory
        h.IOData.rawdata.(genvarname(h.IOData.DES{k}))=rawdata;
        if ishandle(h.Handle.bar)
           waitbar(40/100+(40/SheetNumber/100)*k,h.Handle.bar);
        end
    end
    % populate the first sheet into the table
    set(h.Handles.tsTable,'NumRows',h.IOData.originalSheetSize(1,1));
    set(h.Handles.tsTable,'NumColumns',h.IOData.originalSheetSize(1,2));
    h.Handles.tsTable.setData(h.IOData.rawdata.(genvarname(h.IOData.DES{1})));
    set(h.Handles.tsTable,'Editable',false);
    h.Handles.tsTable.getTable.setRowSelectionAllowed(true);
    h.Handles.tsTable.getTable.setColumnSelectionAllowed(true);
    awtinvoke(h.Handles.tsTable.getTable,'clearSelection');
end

