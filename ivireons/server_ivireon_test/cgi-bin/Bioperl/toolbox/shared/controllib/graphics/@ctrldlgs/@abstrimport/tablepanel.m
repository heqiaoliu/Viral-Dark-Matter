function panel = tablepanel(this, ~) 
% Create and configure the table and scroll panel.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:28 $

% Create scroll panel with table
TableModel = javaObjectEDT('com.mathworks.toolbox.control.dialogs.ImportDlgTableModel');

Table = javaObjectEDT('com.mathworks.mwswing.MJTable',TableModel);
panel = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',Table);
Table.setPreferredScrollableViewportSize(java.awt.Dimension(450, 100));
% Disable column reordering
Table.getTableHeader.setReorderingAllowed(false); 

% Store Java Handles
this.Handles.Table = Table;
this.Handles.TableModel = TableModel;
