function open(h)
% OPEN Opens @exceltable with known file and sheet names 

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:59 $

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

if ~isempty(h.filename) && ~isempty(h.sheetname)
    try
        [numData_, txtData, rawdata] = xlsread(h.filename,h.sheetname);
        
        if ~isempty(rawdata)
            numData = NaN*ones(size(rawdata));
            I = cellfun('isclass',rawdata,'double');
            numData(I) = [rawdata{I}];
        else % Without ActiveX support xlsread returns empty
            warndlg(sprintf('There is no ActiveX client support for Excel on this machine. Loading numeric data only'),...
               sprintf('Excel File Import'));
            numData = numData_;
            txtData = {''};
        end
                
        % limit header size to 20x50 to prevent excessive loading times
        if size(txtData,1)>20 
            txtData = txtData(1:20,:);
        end
        if size(txtData,2)>50 
            txtData = txtData(:,1:50);
        end    
    catch
        errordlg(sprintf('Requested Excel file or sheet name not found'), ...
            sprintf('Excel File Import'), 'modal')
        % Hide table and return
        awtinvoke(h.STable,'setVisible(Z)',false);
        awtinvoke(h.STable.getTableHeader,'setVisible(Z)',false);
        return
    end
else
    % Hide table and return
    awtinvoke(h.STable,'setVisible(Z)',false);
    awtinvoke(h.STable.getTableHeader,'setVisible(Z)',false);
    return
end
        
% non-numeric text
h.setCells(txtData);

% letter column headings
h.colnames = [{' '} cellstr(char('A'+(1:size(numData,2))-1)')'];

% limit the displayed size due to MatlabVariableData constraint
%     if prod(size(numData))>64000 && 64000>=size(numData,2)
%         warndlg('The size of the spreadsheet exceeds the display capability of 64000 cells, truncating displayed columns to fit...',...
%             'Linear simulation tool', 'modal')
%         numData = thisData1(1:floor(64000/size(numData,2)),:);
%     elseif 64000<size(numData,2)
%         errordlg('Spreadsheets with more than 64000 columns cannot be used','Linear simulation tool', 'modal')
%         %thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
%         return
%     end

% Update table
h.numdata = numData;
thisTableModel = SheetTableModel(numData,h);
awtinvoke(h.STable,'setModel(Ljavax.swing.table.TableModel;)',thisTableModel);
awtinvoke(h.STable.getModel,'fireTableDataChanged');

% Enable context menus
h.STable.getModel.setMenuStatus(1);

% column only selections
awtinvoke(h.STable,'setCellSelectionEnabled',false);
awtinvoke(h.STable,'setColumnSelectionAllowed',true);

awtinvoke(h.STable.getColumnModel.getColumn(0),'setMaxWidth',int32(40));
awtinvoke(h.STable,'setAutoResizeMode',int32(JTable.AUTO_RESIZE_OFF));
awtinvoke(h.STable,'sizeColumnsToFit(I)',JTable.AUTO_RESIZE_OFF);

% Make table & header visible
awtinvoke(h.STable,'setVisible(Z)',true);
awtinvoke(h.STable.getTableHeader,'setVisible(Z)',true);
