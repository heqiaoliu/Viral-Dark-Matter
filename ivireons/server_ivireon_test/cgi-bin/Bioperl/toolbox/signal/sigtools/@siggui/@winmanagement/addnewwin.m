function addnewwin(hManag, newwin)
%ADDNEWWIN Add a new window to the list
%   ADDNEWWIN(HMANAG, NEWWIN) adds a new siggui.winspecs object NEWWIN 
%   into the winmanagement component HMANAG.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2007/12/14 15:20:09 $ 

% Error checking
if ~isa(newwin, 'siggui.winspecs'),
    error(generatemsgid('InternalError'),'winmanagement internal error: siggui.winspecs object expected');
end

% Add the new window on top of the list
winlist = get(hManag,'Window_list');
set(hManag, 'Window_list', [newwin; winlist]);

% Add the new window to selection
select = get(hManag, 'Selection');
set(hManag, 'Selection', 1);

% Make the new window the current one
set(hManag, 'Currentwin', 1);

% Increase counter
nb_win = get(hManag, 'Nbwin');
set(hManag, 'Nbwin', nb_win+1);

% [EOF]
