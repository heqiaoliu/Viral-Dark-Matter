function hX = fdatool_xformtool(hSB)
%FDATOOL_XFORMTOOL XFormTool for FDATool

%   Author(s): J. Schickler
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2007/03/13 19:50:51 $

hFig = get(hSB, 'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, 'Loading the Filter Transformation panel');

Hd   = getfilter(hFDA, 'wfs');
hX   = fdtbxgui.xformtool(dfilt.dffir);
sz   = fdatool_gui_sizes(hFDA);

setfs(hX, Hd.Fs);

status(hFDA, 'Loading the Filter Transformation panel ...');

render(hX, hFig, sz.defaultpanel-[-2 -2 4 4]*sz.pixf);
resizefcn(hX, [sz.fig_w sz.fig_h]*sz.pixf);

listener = [handle.listener(hFDA, 'FilterUpdated', {@filterupdated_eventcb, hX}), ...
        handle.listener(hX, 'FilterTransformed', @filtertransformed_eventcb)];
set(listener, 'CallbackTarget', hFDA);

setappdata(hFDA, 'XFormToolListeners', listener);

filterupdated_eventcb(hFDA, [], hX);

status(hFDA, 'Loading the Filter Transformation panel ... done');

% -------------------------------------------------------------
function setfs(hX, fs)

if isempty(fs),
    s.value = [];
    s.units = 'Normalized (0 to 1)';
else
    [s.value, m, s.units] = engunits(fs);
    s.units = [s.units 'Hz'];
end

set(hX, 'CurrentFs', s);

% -------------------------------------------------------------
function filterupdated_eventcb(hFDA, eventData, hX)

Hd   = getfilter(hFDA, 'wfs');

if isa(Hd.Filter, 'dfilt.singleton')
    hX.Filter = Hd.Filter;
    setfs(hX, Hd.Fs);
    enab = 'on';
else
    enab = 'off';
end

set(hX, 'Enable', enab);

% -------------------------------------------------------------
function filtertransformed_eventcb(hFDA, eventData)

filt = get(eventData, 'Data');

opts.fcnhndl = @setexternflag;
opts.source  = 'Transformed';
opts.name    = get(getfilter(hFDA, 'wfs'), 'Name');
opts.mcode   = genmcode(eventData.Source);

hFDA.setfilter(filt, opts);

% [EOF]
