function disabledparameters_listener(hDlg, eventData)
%DISABLEDPARAMETERS_LISTENER Listener to the disabledparameters property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/08/26 19:36:45 $

if isempty(hDlg.Parameters), return; end

hPrm    = get(hDlg, 'Parameters');
dparams = get(hDlg, 'DisabledParameters');
h       = get(hDlg, 'Handles');
tags    = get(hPrm, 'Tag');

dindx = [];

% Find the indices of the parameters to disable.
for i = 1:length(dparams),
    dindx = [dindx find(strcmpi(dparams{i}, tags))];
end

eindx = setdiff(1:length(h.controls), dindx);

if ~isempty(dindx),
    setenableprop(convert2vector(h.controls(dindx)), 'Off');
end
if ~isempty(eindx),
    setenableprop(convert2vector(h.controls(eindx)), hDlg.Enable);
end
    

for indx = 1:length(hPrm),
    vv = get(hPrm(indx), 'ValidValues');
    if iscell(vv) & length(vv) == 1,
        setenableprop(convert2vector(h.controls(indx)), 'Off');
    end
end
    
% [EOF]
