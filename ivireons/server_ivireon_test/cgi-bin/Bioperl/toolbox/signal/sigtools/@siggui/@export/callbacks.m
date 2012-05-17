function cbs = callbacks(hXP)
%CALLBACKS Callbacks for the Export Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/05/04 01:54:13 $

cbs.edit     = @edit_cb;
cbs.popup    = @popup_cb; 
cbs.checkbox = @checkbox_cb;
cbs.exportas = @exportas_cb;

% --------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, hXP)

set(hXP, 'ExportAs', popupstr(hcbo));

% --------------------------------------------------------------------
function edit_cb(hcbo, eventStruct, hXP)

indx        = get(hcbo, 'userdata');

if iscoeffs(hXP),
    targetNames = get(hXP, 'TargetNames');
else
    targetNames = get(hXP, 'ObjectTargetNames');
end

newName     = fixup_uiedit(hcbo);
newName     = newName{1};

% Make sure that the new variable name is valid
if isvarname(newName) & ~isreserved(newName, 'm'),
    targetNames{indx} = newName;
    if iscoeffs(hXP),
        set(hXP, 'TargetNames', targetNames);
    else
        set(hXP, 'ObjectTargetNames', targetNames);
    end
else
    
    % If the new variable name is not valid set it back and error
    set(hcbo, 'String', targetNames{indx});
    
    if isreserved(newName, 'm'),
        endstr = ' is a reserved word in MATLAB.';
    else
        endstr = ' is not a valid variable name.';
    end
    
    senderror(hXP, sprintf('''%s''%s', newName, endstr));
end

% --------------------------------------------------------------------
function popup_cb(hcbo, eventStruct, hXP)

set(hXP, 'ExportTarget', popupstr(hcbo));

% --------------------------------------------------------------------
function checkbox_cb(hcbo, eventStruct, hXP)

set(hXP, 'Overwrite', get(hcbo, 'Value'));

% [EOF]
