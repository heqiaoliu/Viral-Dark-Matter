function checkAbsoluteTimeFormat(h,sheetname,colrow,index)
% this part of code should be replace by the new xlsread function in SP2

% Copyright 2004-2006 The MathWorks, Inc.

if strcmp(colrow,'column')
    % check if recheck is necessary
    if getfield(h.IOData.formatcell,'columnIndex')~=index || ~strcmp(getfield(h.IOData.formatcell,'sheetName'),sheetname)
        % try column
        localCheckColumn(h,sheetname,index);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'columnIndex',index);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'rowIndex',0);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'sheetName',sheetname);
    end
elseif strcmp(colrow,'row')
    % check if recheck is necessary
    if getfield(h.IOData.formatcell,'rowIndex')~=index || ~strcmp(getfield(h.IOData.formatcell,'sheetName'),sheetname)
        % try row
        localCheckRow(h,sheetname,index);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'columnIndex',0);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'rowIndex',index);
        h.IOData.formatcell=setfield(h.IOData.formatcell,'sheetName',sheetname);
    end
elseif strcmp(colrow,'rowcolumn')
    % only called once at the initialization stage
    % try column
    localCheckColumn(h,sheetname,index);
    % try row
    localCheckRow(h,sheetname,index);
    % indicate which sheet and which row and which column is this struct for
    h.IOData.formatcell=setfield(h.IOData.formatcell,'rowIndex',index);
    h.IOData.formatcell=setfield(h.IOData.formatcell,'columnIndex',index);
    h.IOData.formatcell=setfield(h.IOData.formatcell,'sheetName',sheetname);
end
          

function localCheckColumn(h,sheetname,index)
sheet = get(h.Handles.oldSheets,'Item',sheetname);
% initialize numberformat storage
tmpcell=cell(size(sheet.UsedRange.Value,1),1);
% initialize flag storage
h.IOData.formatcell=setfield(h.IOData.formatcell,'columnIsAbsTime',-1);
% get column letter
columnLetter=h.findcolumnletter(index+sheet.UsedRange.Column-1);
% check each cell in the column, be careful about the UsedRange offset
for i=1:size(sheet.UsedRange.Value,1)
    % get numberformat
    tmpstr=[columnLetter num2str(i+sheet.UsedRange.Row-1)];
    readinfo=get(sheet,'Range',tmpstr);
    tmpcell(i)={readinfo.NumberFormat};
    % Call to .Value may fail for some weird cell entries, e.g. #NULL
    % due to error out of ActiveX control
    try
        CellValue = readinfo.Value;
    catch
        CellValue = NaN;
    end
    % if it is date/time, set the flag true
    tmpFlag=h.IsTimeFormat(tmpcell(i),{CellValue},columnLetter,'col');
    if ~isempty(tmpFlag)
        h.IOData.formatcell=setfield(h.IOData.formatcell,'columnIsAbsTime',tmpFlag);
    end
end
% store the info struct
h.IOData.formatcell=setfield(h.IOData.formatcell,'columnFormat',tmpcell);


function localCheckRow(h,sheetname,index)
sheet = get(h.Handles.oldSheets,'Item',sheetname);
% initialize numberformat storage
tmpcell=cell(size(sheet.UsedRange.Value,2),1);
% initialize flag storage
h.IOData.formatcell=setfield(h.IOData.formatcell,'rowIsAbsTime',-1);
% get row number
rowNumber=num2str(index+sheet.UsedRange.Row-1);
% check each cell in the row, be careful about the UsedRange offset
for i=1:size(sheet.UsedRange.Value,2)
    % get numberformat
    tmpstr=[h.findcolumnletter(i+sheet.UsedRange.Column-1) rowNumber];
    readinfo=get(sheet,'Range',tmpstr);
    tmpcell(i)={readinfo.NumberFormat};
    % Call to .Value may fail for some weird cell entries, e.g. #NULL
    % due to error out of ActiveX control
    try
        CellValue = readinfo.Value;
    catch
        CellValue = NaN;
    end
    % if it is date/time, set the flag true
    tmpFlag=h.IsTimeFormat(tmpcell(i),{CellValue},rowNumber,'row');
    if ~isempty(tmpFlag)
        h.IOData.formatcell=setfield(h.IOData.formatcell,'rowIsAbsTime',tmpFlag);
    end
end
% store the info struct
h.IOData.formatcell=setfield(h.IOData.formatcell,'rowFormat',tmpcell);

