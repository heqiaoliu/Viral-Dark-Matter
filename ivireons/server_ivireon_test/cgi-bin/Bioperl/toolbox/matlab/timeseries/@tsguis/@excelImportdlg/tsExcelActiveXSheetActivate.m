function tsExcelActiveXSheetActivate(h,varargin) 
% TSEXCELACTIVEXSHEETACTIVATE is the callback for activesheet change action

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% callback 

if (strcmp(varargin{5}, 'SheetActivate'))
    % h=varargin{1}.handle;
    % clear all the selections
    h.ClearEditBoxes;
    % check if the first column or row contains
    SheetSize = h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,:);
    h.checkTimeFormat(varargin{3}.Name,'both','1');
    % set correct absolute data/time if in the 1st col or row
    if h.IOData.formatcell.columnIsAbsTime>=0
        rangeStr=strcat('A1:A',num2str(SheetSize(1)));
        varargin{3}.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.columnFormat);
        % update time panel
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime>=0
        rangeStr=strcat('A1:',h.findcolumnletter(SheetSize(2)),'1');
        varargin{3}.Range(rangeStr).NumberFormat=cell2mat(h.IOData.formatcell.rowFormat);
        % update time panel
       set(h.Handles.COMBdataSample,'Value',2);
       h.TimePanelUpdate('row');
    elseif h.IOData.formatcell.columnIsAbsTime==-1
        % update time panel
        set(h.Handles.COMBdataSample,'Value',1);
        h.TimePanelUpdate('column');
    elseif h.IOData.formatcell.rowIsAbsTime==-1
        % update time panel
       set(h.Handles.COMBdataSample,'Value',2);
       h.TimePanelUpdate('row');
    else
        % update time panel
       set(h.Handles.COMBdataSample,'Value',1);
       h.TimePanelUpdate('column');
    end
    set(h.Parent.Handles.EDTsingleNEW,'String',varargin{3}.Name);
end
