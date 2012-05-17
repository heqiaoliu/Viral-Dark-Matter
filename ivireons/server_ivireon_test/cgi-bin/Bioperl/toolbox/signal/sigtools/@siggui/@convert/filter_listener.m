function filter_listener(hObj, eventData)
%FILTER_LISTENER The listener on the ReferenceFilter property

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/13 00:22:12 $

if ~isempty(hObj.ReferenceFilter) & ismethod(hObj.ReferenceFilter, 'convert'),
    set(hObj, 'Enable', 'On');
    h = get(hObj,'Handles');
    
    newstrs = getconvertstructchoices(hObj);
    
    set(h.listbox,'String',newstrs);
    
    % Make sure that the selected structure is still available
    update_listbox(hObj);
    
    filtobj = get(hObj, 'Filter');
    fstruct = get(filtobj, 'FilterStructure');
    
    if ~strcmpi(fstruct, get(hObj, 'TargetStructure')), isA = 0;
    else,                                               isA = 1; end
    
    set(hObj, 'isApplied', isA);

else
    set(hObj, 'Enable', 'Off');
end

% [EOF]
