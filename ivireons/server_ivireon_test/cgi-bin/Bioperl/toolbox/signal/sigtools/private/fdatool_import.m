function hIT = fdatool_import(hSB)
%FDATOOL_IMPORT Add the import panel to FDATool
%   FDATOOL_IMPORT(hSB) Interface function between FDATool and the import panel.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.11 $  $Date: 2008/04/21 16:32:02 $

hFig = get(hSB,'FigureHandle');
hFDA = getfdasessionhandle(hFig);

status(hFDA, 'Loading the Filter Import panel');

hIT  = siggui.import;

status(hFDA, 'Loading the Filter Import panel ...');

sz = fdatool_gui_sizes(hFDA);
render(hIT, hFig, sz.panel);

% resizefcn(hIT, [sz.fig_w sz.fig_h]*sz.pixf);

l = handle.listener(hIT, 'FilterGenerated', {@filtergenerated_eventcb, hFDA});
setappdata(hFig, 'ImportFilterGeneratedListener', l);

setunits(hIT, 'Normalized');

status(hFDA, 'Loading the Filter Import panel ... done');

% ------------------------------------------------------------------
function filtergenerated_eventcb(hIT, eventData, hFDA)

data = get(eventData, 'Data');
filtobj = data.filter;

options.fs         = data.fs;
options.source     = 'Imported'; 
options.fcnhndl    = @setimportedflag; % This line will be eliminated when all panels are objects 
options.update     = 1;
options.mcode      = genmcode(hIT);
options.resetmcode = true;
if isprop(filtobj, 'FilterStructure')
    options.name   = xlate(get(filtobj, 'FilterStructure'));
elseif isprop(filtobj, 'Algorithm')
    options.name   = xlate(get(filtobj, 'Algorithm'));
else
    options.name   = '';
end

try
    hFDA.setfilter(filtobj,options);
catch ME
    senderror(hFDA, ME.identifier, ME.message);
end

% [EOF]
