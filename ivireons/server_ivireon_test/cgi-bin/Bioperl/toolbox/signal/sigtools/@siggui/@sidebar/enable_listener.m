function enable_listener(this, eventData)
%ENABLE_LISTENER Listener to the Enable Property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2004/04/13 00:25:38 $

sigcontainer_enable_listener(this, eventData);

h     = get(this, 'Handles');
index = get(this, 'CurrentPanel');

% if feature('JavaFigures'),
%     % Do not try to update buttons if they do not exist
%     if h.java.buttoncount,
%         set(h.java.(sprintf('button%d', index)),'Enabled','Off');
%     end
% else
    % Do not try to update buttons if they do not exist
    if ~isempty(h.button) && ~isequal(index, 0) && strcmpi(this.Enable, 'On')
        set(h.button(index), 'Enable', 'Inactive');
    end
% end

% [EOF]
