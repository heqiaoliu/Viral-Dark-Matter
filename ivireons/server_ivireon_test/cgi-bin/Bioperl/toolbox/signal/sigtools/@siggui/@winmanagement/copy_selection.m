function copy_selection(hManag)
%COPY_SELECTION Make a copy of the selected windows and add them to the list 

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2007/12/14 15:20:10 $

% Get the selected windows
winlist = get(hManag, 'Window_list');
select = get(hManag, 'Selection');
if isempty(select),
    error(generatemsgid('InternalError'),'winmanagement internal error : Selection not allowed');
end
selectedlist = winlist(select);

for i = 1:length(selectedlist),
    hcopy = copy(selectedlist(i));
    % Change the name of the copy
    name = get(selectedlist(i), 'Name');
    newname = ['copy_of_', name];
    if length(newname) > 63
        newname(64:end) = [];
    end
    hcopy.Name =  newname;
    % Add the copy to the list
    addnewwin(hManag, hcopy);
end

% [EOF]
