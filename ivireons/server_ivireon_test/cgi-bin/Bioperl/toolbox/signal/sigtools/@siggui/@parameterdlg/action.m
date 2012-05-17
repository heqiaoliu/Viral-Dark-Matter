function aClose = action(hDlg)
%ACTION Perform the action of the parameter dialog

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.8 $  $Date: 2007/12/14 15:19:04 $

aClose = true;

h = get(hDlg, 'Handles');

allPrm = get(hDlg, 'Parameters');

msg = '';
for indx = 1:length(h.controls),
    l{indx} = getappdata(h.controls(indx).edit, 'ParameterListener');
    set(l{indx}, 'Enabled', 'Off');
    
    val{indx} = getvaluesfromgui(hDlg,indx);
end

if length(val) == 1
    val = val{1};
end

msg = setvalue(allPrm, val);

if ~isempty(msg),
    
    for indx = 1:length(allPrm)
        hPrm = allPrm(indx);
        if ~isempty(strfind(msg, hPrm.Tag))
            if iscell(hPrm.ValidValues),
                popindx = find(strcmpi(hPrm.Value, hPrm.ValidValues));
                set(h.controls(indx).specpopup, 'Value', popindx);
            else
                set(h.controls(indx).edit, 'String', hPrm.Value);
            end
        end
    end
end

set([l{:}], 'Enabled', 'On');

% Since we shut off the listeners, there may be updates that need to be
% made.
send(allPrm, 'ForceUpdate');

if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% [EOF]
