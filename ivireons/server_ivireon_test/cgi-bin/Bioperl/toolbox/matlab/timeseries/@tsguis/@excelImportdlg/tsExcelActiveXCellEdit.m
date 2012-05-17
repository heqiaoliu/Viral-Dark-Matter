function tsExcelActiveXCellEdit(h,varargin) 
% TSEXCELACTIVEXSHEETACTIVATE is the callback for activesheet change action

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% callback 

if (strcmp(varargin{8}, 'EndEdit'))
    % h=varargin{1}.handle;
    % clear all the selections
    Column = varargin{1}.ActiveCell.Column;
    Row = varargin{1}.ActiveCell.Row;
    % check if the first column or row contains
    SheetSize = h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,:);
    if Column>SheetSize(2)
        SheetSize(2) = Column;
    end
    if Row>SheetSize(1)
        SheetSize(1) = Row;
    end
    h.IOData.currentSheetSize(varargin{1}.ActiveSheet.Index,:) = SheetSize;
end
