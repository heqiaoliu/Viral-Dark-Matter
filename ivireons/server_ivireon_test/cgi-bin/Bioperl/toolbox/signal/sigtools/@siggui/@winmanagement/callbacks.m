function cbs = callbacks(hManag)
%CALLBACKS Callbacks for the window management component

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:34:31 $

% This can be a private method

cbs.set_selection    = {@listbox_cbs, hManag};
cbs.addnewwin        = {@addnewwin_cbs, hManag};
cbs.copywindow       = {@copywindow_cbs, hManag};
cbs.save_selection   = {@save_cbs, hManag};
cbs.delete_selection = {@delete_cbs, hManag};

%-------------------------------------------------------------------------
function listbox_cbs(hcbo, eventstruct, hManag)

select = get(hcbo, 'Value');
set_selection(hManag, select);

%-------------------------------------------------------------------------
function addnewwin_cbs(hcbo, eventstruct, hManag)

newwin = defaultwindow(hManag);
addnewwin(hManag, newwin);

%-------------------------------------------------------------------------
function copywindow_cbs(hcbo, eventstruct, hManag)

copy_selection(hManag);

%-------------------------------------------------------------------------
function save_cbs(hcbo, eventstruct, hManag)

save_selection(hManag);

%-------------------------------------------------------------------------
function delete_cbs(hcbo, eventstruct, hManag)

delete_selection(hManag);

% [EOF]
