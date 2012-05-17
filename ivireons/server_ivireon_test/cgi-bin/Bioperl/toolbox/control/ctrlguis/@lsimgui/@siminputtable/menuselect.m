function menuselect(h, menuType)

% MENUSELECT Handles the callback from the "menuselect" STable event

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/09/15 20:36:28 $

selectedRows = double(h.STable.getSelectedRows)+1;
switch lower(menuType)
case lower(xlate('Cut signal')),
    h.copyClipBoardData(selectedRows);
    h.deleterows(selectedRows,'withoutshuffle');
case lower(xlate('Copy signal')),
    h.copyClipBoardData(selectedRows);       
case lower(xlate('Paste signal')),
    h.pasteData(h.copieddatabuffer);
case lower(xlate('Insert signal')),
    % if one row is selected we may need to add additional rows to
    % accommodate the size of the copied data buffer  
    if length(h.copieddatabuffer.columns) == length(selectedRows)
        addrows = h.addrows(selectedRows);
        if addrows>0
            h.pasteData(h.copieddatabuffer);
        end
    elseif length(selectedRows) == 1 
        tempSelection = selectedRows+(0:(length(h.copieddatabuffer.columns)-1));
        addrows = h.addrows(tempSelection);
        if addrows>0
            h.pasteData(h.copieddatabuffer,tempSelection);  
        end
    end
case lower(xlate('Delete signal')),
    h.deleterows(selectedRows,'withshuffle');
end   