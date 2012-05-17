function initialize(h,nrows,colnames,name)

% INITIALIZE   Initializes properties & listeners for an empty
% @siminputtable

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:38:58 $

import javax.swing.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.ide.workspace.*;

% table must have a minimum of 5 rows
h.reset(nrows,colnames,name,max(5-nrows,0))
h.menulabels = {xlate('Cut signal'),xlate('Copy signal'),xlate('Paste signal'),xlate('Insert signal'),xlate('Delete signal')};
h.visible = 'on';
h.readonlycols = [1 3];
h.STable = STable(STableModel(h));

% add listeners
h.addlisteners([handle.listener(h,'rightmenuclick',{@localRightClick h})
handle.listener(h,'rightmenuselect',{@localRightSelect h})]);


% Install a listener to redraw the simtable if the number of simulation
% samples change
h.addlisteners(handle.listener(h,findprop(h,'simsamples'),'PropertyPostSet',...
    {@localUpdate h}));

% When the copied data buffer is empty the paste and insert menus are
% disabled
h.STable.getModel.setMenuStatus([1 1 0 0 1]);

%-------------------- Local Functions ---------------------------

function localRightClick(eventSrc, eventData, h)

if strcmp(eventData.Type,'rightmenuclick')   
    h.menuoptions(h.STable.getContextMenus);
end    

function localRightSelect(eventSrc, eventData, h)

h.menuselect(eventData.Data)



function localUpdate(eventSrc, eventData, h)

h.update



