function initialize(h)
% INITIALIZE Initializes properties and listeners for an empty @exceltable 

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:44 $

import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.mwswing.*;
import javax.swing.*;

% Create empty 1x1 read only @excel table
h.readonly = 'on';
h.colnames = {' ' ' '};
h.numdata = [];
h.setCells({' '});

h.leadingcolumn = 'on';
h.STable = STable(SheetTableModel(NaN,h));
h.STable.setVisible(0);
h.STable.getTableHeader.setVisible(0);
h.filename = '';
h.sheetname = '';

% Menus are disabled in the base class
%h.menulabels = {'Copy'};
%h.STable.getModel.setMenuStatus(1);

h.addlisteners(handle.listener(h, findprop(h,'filename'),'PropertyPostSet',{@localSheetUpdate h}));
h.addlisteners(handle.listener(h, findprop(h,'sheetname'),'PropertyPostSet',{@localSheetUpdate h}));

%-------------------- Local Functions ---------------------------

function localSheetUpdate(eventSrc, eventData, h)

if strcmp(get(eventSrc,'Name'),'filename') % the filename has been updated - the
                                         % sheetname may no longer be valid 
   if ~isempty(h.filename)
       [status, sheetnames] = xlsfinfo(h.filename);
       if ~isempty(status) && length(sheetnames)>=1
           % disable listeners when updating the sheeet name or they will fire
           % twice
           set(h.listeners,'enabled','off'); 
           h.sheetname = sheetnames{1};
           set(h.listeners,'enabled','on');
       end
   else
       h.sheetname = '';
   end      
end
h.open

