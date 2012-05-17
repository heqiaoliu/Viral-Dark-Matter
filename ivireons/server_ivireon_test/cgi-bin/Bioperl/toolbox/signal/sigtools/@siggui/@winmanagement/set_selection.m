function set_selection(hManag, selection)
%SET_SELECTION Set the Selection property

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:20:14 $

% Error checking
winlist = get(hManag, 'Window_list');
N = length(winlist);
if any(selection<0) | any(selection>N) | ~isequal(selection, floor(selection)),
    error(generatemsgid('InternalError'),'winmanagement internal error : Selection not allowed.')
end

% Set the Selection property
set(hManag, 'Selection', selection);


% [EOF]
