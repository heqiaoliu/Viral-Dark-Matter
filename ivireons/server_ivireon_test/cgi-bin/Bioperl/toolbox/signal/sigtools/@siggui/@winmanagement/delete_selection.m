function delete_selection(hManag)
%DELETE_SELECTION Delete the selected window

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:20:11 $

% Delete selection
winlist = get(hManag, 'Window_list');
select = get(hManag, 'Selection');
if isempty(select),
    error(generatemsgid('InternalError'),'winmanagement internal error : Selection not allowed');
end
delete(winlist(select));
winlist(select) = [];

% Update the properties
set(hManag, 'Window_list', winlist);
if isempty(winlist),
    set(hManag, 'Selection', []);
    % Reset counter
    set(hManag, 'Nbwin', 0);
else,
    set(hManag, 'Selection', 1);
end


% [EOF]
