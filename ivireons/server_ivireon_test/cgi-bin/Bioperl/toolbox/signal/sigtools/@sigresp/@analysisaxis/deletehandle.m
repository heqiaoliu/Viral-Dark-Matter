function deletehandle(this, field)
%DELETEHANDLE   Delete the handle

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/05 18:01:45 $

h = get(this, 'Handles');

% If the field is not valid, do nothing.
if isfield(h, field),

    % Make sure we don't fire any of the listeners.
    if isa(this.OBDListener, 'handle.listener'), l = get(this, 'OBDListener');
    else                                         l = []; end

    set(l, 'Enabled', 'Off');
    
    % If the field contains a valid handle delete it.
    if ishghandle(h.(field))
        if strcmpi(field, 'legend')
            delete(getappdata(h.legend, 'OBD_Listener'));
        end
            
        delete(h.(field));
    end
    
    % Remove the field from the object's handle structure.
    h = rmfield(h, field);

    set(this, 'Handles', h);
    set(l, 'Enabled', 'On');
end


% [EOF]
