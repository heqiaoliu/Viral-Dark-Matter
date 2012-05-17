function plugins = vhdlplugin
%VHDLPLUGIN   Plug-in file for the VHDL Filter product.

%   Author(s): J. Schickler
%   Copyright 2003-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10.4.1 $  $Date: 2010/06/17 14:13:39 $

plugins.fdatool = @vhdldlg_plugin;

% -------------------------------------------------------------------------
function vhdldlg_plugin(hFDA)

% Add the VHDL menu item.
addtargetmenu(hFDA,'Generate HDL ...',{@vhdldlg_cb,hFDA},'generatehdl');

% -------------------------------------------------------------------------
function vhdldlg_cb(hcbo, eventStruct, hFDA) %#ok
Hd = getfilter(hFDA);
h = getcomponent(hFDA, '-class', 'hdlgui.fdhdldlg');
[cando, msg] = ishdlable(Hd);

if ~cando
    senderror(hFDA, msg);
    return;
else
    if isempty(h)
        h = hdlgui.fdhdldlg(Hd);
        addcomponent(hFDA, h);
    elseif ishandle(h.hHdlDlg)
        h.hHdlDlg.show; % bring the dialog to front
    else
        h.hHdlDlg =  DAStudio.Dialog(h.hHdl);
    end
end
% Create a listener on FDATool's Filter.
l = [...
    handle.listener(hFDA, 'FilterUpdated', {@lclfilter_listener, h.hHdl, h.hHdlDlg}); ...
    handle.listener(hFDA, 'CloseDialog', {@close_listener, h.hHdlDlg});...
    ];
setappdata(h, 'fdatool_listener', l);

% -------------------------------------------------------------------------
function lclfilter_listener(hFDA, eventData, hHdl, hDlg) %#ok

% Filter is updated
Hd = getfilter(hFDA);
hHdl.setfilter(Hd);

% Don't need to do anything if dialog is not opened.
if isempty(hDlg) || ~ishandle(hDlg)
    return
end

% The FDHDL dialog will handle the warning if filter is not HDLable
hDlg.refresh;

% -------------------------------------------------------------------------
function close_listener(hFDA, eventData, hDlg) %#ok

if ~isempty(hDlg) && ishandle(hDlg)
    delete(hDlg);
end
% [EOF]
