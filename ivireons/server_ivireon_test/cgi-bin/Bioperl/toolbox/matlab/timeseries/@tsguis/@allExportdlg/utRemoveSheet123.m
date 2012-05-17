function utRemoveSheet123(h,filefullname,bar)

%  Author(s): Rong Chen, James Owen
%  Copyright 2004-2005 The MathWorks, Inc.
%  $Revision: 1.1.10.1 $ $Date: 2005/07/14 15:24:04 $

if ispc 
    try
        if isempty(h.Handles.Excel)
            try
                h.Handles.Excel = actxserver('Excel.Application');
            catch
                delete(bar);
                warning on
                return
            end
            h.Handles.Excel.Visible = 0;
            h.Handles.oldWorkbooks = h.Handles.Excel.Workbooks;
        end
        invoke(h.Handles.oldWorkbooks, 'open', filefullname);
        h.Handles.Excel.ActiveWorkBook.Sheets.Item(1).Delete;
        h.Handles.Excel.ActiveWorkBook.Sheets.Item(1).Delete;
        h.Handles.Excel.ActiveWorkBook.Sheets.Item(1).Delete;
        h.Handles.Excel.ActiveWorkBook.Save;
    catch
        % do nothing
    end
    if ~isempty(h.Handles.Excel)
        invoke(h.Handles.Excel, 'quit'); 
        invoke(h.Handles.Excel, 'delete'); 
    end
end
