function hF = fdatool_dspfwiz(hSB)
%FDATOOL_DSPFWIZ   FDATool to DSPFWIZ link.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/11/19 21:46:44 $

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, 'Loading the Filter Realization panel');

hF   = siggui.dspfwiz(getfilter(hFDA));
sz   = fdatool_gui_sizes(hFDA);

status(hFDA, 'Loading the Filter Realization panel ...');

render(hF, hFig, sz.defaultpanel-[-5 -5 10 10]*sz.pixf);
resizefcn(hF, [sz.fig_w sz.fig_h] * sz.pixf);

addlistener(hFDA, 'FilterUpdated', {@filter_listener, hF});
l = handle.listener(hF, hF.findprop('Filter'), 'PropertyPostSet', ...
    {@fwiz_filter_listener, hF});
set(l, 'CallbackTarget', hFDA);
sigsetappdata(hFDA, 'plugins', 'dspfwiz', 'listeners', l);

status(hFDA, 'Loading the Filter Realization panel ... done');

% --------------------------------------------------------------------
function filter_listener(hFDA, eventData, hF)

% Sync the filter wizard with FDATool.
hF.Filter = getfilter(hFDA);

% --------------------------------------------------------------------
function fwiz_filter_listener(hFDA, eventData, hF)

% If the filterwizard filter changed underneath FDATool, we need to reverse
% sync it.  This can happen when loading an old dspfwiz session.
dspfilt = get(hF, 'Filter');
fdafilt = getfilter(hFDA);
opts.update = 0;

if ~isequal(dspfilt, fdafilt),
    hFDA.setfilter(dspfilt, opts);
end

% [EOF]
