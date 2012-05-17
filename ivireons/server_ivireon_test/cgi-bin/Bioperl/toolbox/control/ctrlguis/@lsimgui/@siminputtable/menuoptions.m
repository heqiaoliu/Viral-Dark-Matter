function menuoptions(h, menus)

% MENUOPTIONS Enables/disbales the menus based on the state of copied/cut
% data

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2006/12/27 20:33:46 $

% display "insert" only if there is something to paste/insert
awtinvoke(menus(4),'setEnabled(Z)',~isempty(h.copieddatabuffer));
awtinvoke(menus(3),'setEnabled(Z)',~isempty(h.copieddatabuffer));
% display "cut","copy","delete" only if one or more rows are selected
awtinvoke(menus(1),'setEnabled(Z)',h.STable.getSelectedRowCount>0);
awtinvoke(menus(2),'setEnabled(Z)',h.STable.getSelectedRowCount>0);
awtinvoke(menus(5),'setEnabled(Z)',h.STable.getSelectedRowCount>0);