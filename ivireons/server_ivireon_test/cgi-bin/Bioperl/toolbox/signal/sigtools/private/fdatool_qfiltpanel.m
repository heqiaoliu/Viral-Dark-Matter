function hQP = fdatool_qfiltpanel(hSB)
%FDATOOL_QFILTPANEL initializes the QFILTPANEL for FDATOOL.
%   hQP = FDATOOL_QFILTPANEL(hSB) returns a FDTBXGUI.QFILTPANEL object hQP,
%   given SIGGUI.SIDEBAR object hSB.

%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/07/27 20:32:27 $

% Turn warning off so quantizing doesn't throw warnings
wrn = warning('off');
if isa(hSB, 'sigtools.fdatool'),
    hFDA = hSB;
    hFig = get(hFDA, 'FigureHandle');
else
    hFig = get(hSB, 'FigureHandle');
    hFDA = getfdasessionhandle(hFig);
end

% The first time this is called, we haven't established a default filter yet,
% so we use the default here.
if sigisappdata(hFDA, 'qpanel', 'handle'),
    hQP = siggetappdata(hFDA, 'qpanel', 'handle');
else

    status(hFDA, 'Loading the Filter Quantization panel');
    Hd = lclcopy(getfilter(hFDA));
    
    status(hFDA, 'Loading the Filter Quantization panel ...');
    hQP = fdtbxgui.qtool(Hd);
    set(hQP, 'DSPMode', getflags(hFDA, 'calledby', 'dspblks'));
    sigsetappdata(hFDA, 'qpanel', 'handle', hQP);

    sz = fdatool_gui_sizes(hFDA);

    render(hQP, hFig, sz.defaultpanel);
    resizefcn(hQP, [sz.fig_w, sz.fig_h]*sz.pixf);

    attachlisteners(hFDA, hQP);
    status(hFDA, 'Loading the Filter Quantization panel ... done');
end

% Restore warning state.
warning(wrn)

% ------------------------------------------------------------
function attachlisteners(hFDA, hQP)
% Events that update the filter.

listeners = [ ...
    handle.listener(hFDA, hFDA.findprop('Filter'), ...
    'PropertyPostSet', @filter_eventcb); ...
    handle.listener(hQP, 'NewSettings', @newsettings_listener); ...
    ];

set(listeners, 'CallbackTarget', [hQP, hFDA]);

sigsetappdata(hFDA, 'qpanel', 'listeners', listeners);


% ------------------------------------------------------------
function filter_eventcb(callbacktarget, eventData)
% Filter in FDATOOL has been changed.  Now reflect that change in the qpanel. 

hQP = callbacktarget(1);
hFDA = callbacktarget(2);

Hd = getfilter(hFDA);
if ~isempty(strfind(hFDA.filtermadeby, 'converted')) && ...
        ~isa(Hd, 'mfilt.abstractcic') && ...
        ~isa(hQP.Filter, 'mfilt.abstractcic'),
    l = siggetappdata(hFDA, 'qpanel', 'listeners');
    set(l, 'Enabled', 'Off');
    set(hQP, 'Arithmetic', 'double');
    set(l, 'Enabled', 'On');
end
if Hd ~= hQP.Filter,
    Hd = lclcopy(Hd);
    hQP.Filter = Hd;
    HdwFs = getfilter(hFDA, 'wfs');
    HdwFs.Filter = hQP.Filter;
end

% ------------------------------------------------------------
function newsettings_listener(callbacktarget, eventData)

hQP  = callbacktarget(1);
hFDA = callbacktarget(2);

if isquantized(hQP.Filter)
    opts.source = sprintf('%s (quantized)', strrep(hFDA.filterMadeBy, ' (quantized)', ''));
else
    opts.source = strrep(hFDA.filterMadeBy, ' (quantized)', '');
end
opts.source = strrep(opts.source, ' (converted)', ''); % Make sure that converted is gone.
opts.mcode  = genmcode(hQP);

l = siggetappdata(hFDA, 'qpanel','listeners');

set(l, 'Enabled','Off');

setfilter(hFDA, lclcopy(hQP.Filter), opts);

set(l, 'Enabled','On');

% ------------------------------------------------------------
function fmb = rmquantized(hFDA)

fmb = get(hFDA, 'FilterMadeBy');
indx = strfind(lower(fmb), ' (quantized)');
if ~isempty(indx),
    fmb(indx:indx+11) = [];
end

% ------------------------------------------------------------
function Hd = lclcopy(Hd)

mi = [];
if isprop(Hd, 'MaskInfo'),
    mi = get(Hd, 'MaskInfo');
end
Hd = copy(Hd);
if ~(isempty(mi) || isprop(Hd, 'MaskInfo')) 
    p = adddynprop(Hd, 'MaskInfo', 'mxArray');
    set(p, 'Visible', 'Off');
    set(Hd, 'MaskInfo', mi);
end

% [EOF]
