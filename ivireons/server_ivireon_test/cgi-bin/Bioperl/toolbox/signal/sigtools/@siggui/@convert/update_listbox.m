function update_listbox(hConvert)
%UPDATE_LISTBOX Update the popup of the Convert Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/13 00:22:16 $

struct  = lower(get(hConvert,'TargetStructure'));
h       = get(hConvert,'Handles');
strings = lower(get(h.listbox,'String'));
index   = strmatch(struct, strings,'exact');

% If the selected structure is no longer available, use the current structure
if isempty(index),
    filt = get(hConvert, 'Filter');
    
    % We cannot convert to a cascade or parallel so we just default to the
    % first choice in the listbox.
    if isa(filt, 'dfilt.cascade') | isa(filt, 'dfilt.parallel'),
        index = 1;
    else,
        fstruct = get(filt, 'FilterStructure');
        
        indx = strfind(fstruct, ', second-order-sections');
        fstruct(indx:end) = [];
        
        if isempty(fstruct),
            index = 1;
        else,
            index = strmatch(lower(fstruct), strings,'exact');
            if isempty(index), index = 1; end
        end
    end
    set(hConvert, 'TargetStructure', strings{index});
end

set(h.listbox, 'Value', index);
set(hConvert, 'isApplied', 0);

% [EOF]
