function enableselection(hObj, varargin)
%ENABLESELECTION Enable a selection
%   ENABLESELECTION(hObj, TAG) Enable the disabled selection associated with TAG.
%
%   ENABLESELECTION(hObj, TAG1, TAG2, etc) Enable the disabled selections.
%
%   ENABLESELECTION(hObj) Enable all disabled selections.
%
%   See also DISABLESELECTION, SETGROUP.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2007/12/14 15:19:15 $

error(nargchk(1, inf, nargin,'struct'));

if nargin == 1,
    dSelects = {};
    set(hObj, 'DisabledSelections', dSelects);

    % Verify that a selection is made
    check_selection(hObj);
    if isrendered(hObj),
        update(hObj, 'update_popup');
    end
else
    
    % Get the indexes to enable.
    [indx, msg] = find_enabled_indexes(hObj, varargin{:});
    if ~isempty(msg), error(generatemsgid('SigErr'),msg); end
    
    % Update the disabledselections
    dSelects = get(hObj, 'DisabledSelections');
    
    if ~isempty(indx),
        dSelects(indx) = [];
    
        set(hObj, 'DisabledSelections', dSelects);

        % Verify that a selection is made
        check_selection(hObj);
        if isrendered(hObj),
            update(hObj, 'update_popup');
        end
    end
end


% -------------------------------------------------------------------
function [indx, msg] = find_enabled_indexes(hObj, varargin)

% Get the currently disabled selections.
dSelects = get(hObj, 'DisabledSelections');
indx     = [];
msg      = '';

for i = 1:length(varargin)
    
    % Verify that the input is a disabled selection
    tag      = varargin{i};
    tempindx = strmatch(tag, dSelects);
    
    switch length(tempindx)
    case 0
        selections = getallselections(hObj);
        
        % Check against all the selections to create a good message.
        if isempty(strmatch(tag, selections)),
            msg = 'That selection is not available.';
            return;
        else
            tempindx = [];
        end
    case 1
        % NO OP
    otherwise
        
        % Input is too vague
        msg = 'Input selection is not specific.  Found these possible matches:';
        msg = [msg char(10)];
        for i = 1:length(tempindx)
            msg = [msg '  ''' dSelects{tempindx(i)} ''''];
        end
        return
    end
    
    if ~isempty(tempindx),
        indx(end+1) = tempindx;
    end
end

% ---------------------------------------------------------------------------
function check_selection(hObj)

% If there is no selection (because they were all disabled), select the first
if isempty(hObj.Selection),
    eSelects = getenabledselections(hObj);
    set(hObj, 'selection', eSelects{1});
end

% [EOF]
