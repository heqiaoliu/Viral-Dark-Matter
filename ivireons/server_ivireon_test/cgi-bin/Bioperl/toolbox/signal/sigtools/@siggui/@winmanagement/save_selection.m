function save_selection(hManag)
%SAVE_SELECTION Save the selected windows to worskspace

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2007/12/14 15:20:12 $

% Get the handles of the selected windows
winlist = get(hManag, 'Window_list');
select = get(hManag, 'Selection');
if isempty(select),
    error(generatemsgid('InternalError'),'winmanagement internal error : Selection not allowed');
end
selectedlist = winlist(select);

for i = 1:length(selectedlist),
    name = get(selectedlist(i), 'Name');
    data = get(selectedlist(i), 'Data');
    if isvarname(name),
        % Assign the Data property to the Name property
        assignin('base', name, data);
		disp(sprintf('%s has been exported to the workspace.', name))
    else
        disp('winmanagement internal error : Invalid variable name.')
    end
end


% [EOF]
