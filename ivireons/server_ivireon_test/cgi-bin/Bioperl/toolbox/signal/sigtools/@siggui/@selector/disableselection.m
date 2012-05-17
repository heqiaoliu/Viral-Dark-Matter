function disableselection(hObj, varargin)
%DISABLESELECTION Disable a selection
%   DISABLESELECTION(hObj, TAG) Disable the top level selection associated
%   with the string TAG.  This will disable the radio button, and the popup
%   if applicable.  This will also prevent the selection from being set at
%   the command line.
%
%   DISABLESELECTION(hObj, TAG1, TAG2, etc) Disable multiple top level
%   selections.
%
%   If SubSelections must be disabled use SETGROUP to remove them from the popup.
%
%   See also ENABLESELECTION, SETGROUP.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2007/12/14 15:19:14 $

error(nargchk(2, inf, nargin,'struct'));

% Get the indexes to disable
[indx, msg] = find_disabled_indexes(hObj, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if ~isempty(indx),

    % Get the enabled selections (which indx refers to)
    eSelects = getenabledselections(hObj);

    % Add the new disabled selections to the list
    dSelects = get(hObj, 'DisabledSelections');
    dSelects = {dSelects{:}, eSelects{indx}};

    % Set the disabled selections
    set(hObj, 'DisabledSelections', dSelects);
    
    % Verify that the current selection is still available
    check_selection(hObj, eSelects{indx});
    
    if isrendered(hObj),
        update(hObj, 'update_popup');
    end
end

% ----------------------------------------------------------------------------
function [indx, msg] = find_disabled_indexes(hObj, varargin)

options = getenabledselections(hObj);
indx    = [];
msg     = '';

for i = 1:length(varargin),
    tag  = varargin{i};
    tempindx = strmatch(tag, options);
    
    switch length(tempindx)
    case 0
        selections = getallselections(hObj);
        if isempty(strmatch(tag, selections)),
            msg = 'That selection is not available.';
            return;
        end
    case 1
        % NO OP
    otherwise
        % Input is too vague
        msg = 'Input selection is not specific.  Found these possible matches:';
        msg = [msg char(10)];
        for i = 1:length(tempindx)
            msg = [msg '  ''' options{tempindx(i)} ''''];
        end
        return;
    end
    
    if ~isempty(tempindx),
        indx(end+1) = tempindx;
    end
end

% ------------------------------------------------------------
function check_selection(hObj, varargin)

selection = get(hObj, 'Selection');

% If the input selection is the current selection, choose a new selection
if ~isempty(strmatch(selection, varargin)),
    eSelects = getenabledselections(hObj);
    
    if isempty(eSelects),
        eSelects = {''};
    end
    
    set(hObj, 'selection', eSelects{1});
end

% [EOF]
