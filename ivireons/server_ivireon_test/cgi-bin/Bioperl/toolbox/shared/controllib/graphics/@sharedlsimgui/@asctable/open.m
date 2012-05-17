function open(h)
% OPEN opens a new @asctable once filename and delimiter properties are
% defined

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:46 $

import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.mwswing.*;
import javax.swing.*;

if ~isempty(h.filename)
    try
        if ~isempty(h.delimiter)
            numData = dlmread(h.filename,h.delimiter);
        else
            numData = load(h.filename);
        end
        h.colnames = [{' '} cellstr(char('A'+(1:size(numData,2))-1)')'];      
    catch ME
        msg = sprintf('Could not open file. Message returned from dlmread: %s',ME.message);
        errordlg(msg,sprintf('Ascii File Import'),'modal')
        awtinvoke(h.STable,'setVisible(Z)',false);
        awtinvoke(h.STable.getTableHeader,'setVisible(Z)',false);
        return
    end    
else % Hide table and return 
    awtinvoke(h.STable,'setVisible(Z)',false);
    awtinvoke(h.STable.getTableHeader,'setVisible(Z)',false);
    return
end

% Only need to create a new STable if one didn't previously exist, since
% listeners should do all the work otherwise
h.numdata = numData;
thisTableModel = SheetTableModel(numData,h);
rw = MLthread(h.STable,'setModel',{thisTableModel});
SwingUtilities.invokeLater(rw);

% Enable context menus
h.STable.getModel.setMenuStatus(1);
% column only selections
rw = MLthread(h.STable,'setCellSelectionEnabled',{boolean(0)},'boolean');
SwingUtilities.invokeLater(rw);
rw = MLthread(h.STable,'setColumnSelectionAllowed',{boolean(1)},'boolean');
SwingUtilities.invokeLater(rw);

% Make table & header visible
drawnow
awtinvoke(h.STable,'setVisible(Z)',true);
awtinvoke(h.STable.getTableHeader,'setVisible(Z)',true);
rw = MLthread(h.STable.getColumnModel.getColumn(0),'setMaxWidth',{int32(20)});
SwingUtilities.invokeLater(rw);
rw = MLthread(h.STable,'setAutoResizeMode',{int32(JTable.AUTO_RESIZE_OFF)},'int');
SwingUtilities.invokeLater(rw);
rw = MLthread(h.STable,'sizeColumnsToFit',{int32(JTable.AUTO_RESIZE_OFF)},'int');
SwingUtilities.invokeLater(rw);
