function plot(this, t, data, f, fresp)
%PLOT Plot datas in the Time and Frequency domains.

%   Author(s): V.Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2008/09/13 07:15:04 $ 

if ~isrendered(this),
    return;
end

hFig  = get(this, 'FigureHandle');
hndls = get(this, 'Handles');
haxtd = hndls.axes.td;
haxfd = hndls.axes.fd;

% Clean the axes
clean_axes(haxtd, haxfd, hndls);

if ~isempty(data),
    % xlabels
    [xtstr, xfstr, tmultiplier, fmultiplier] = define_xlabel(this);
    t = t*tmultiplier;
    f = f*fmultiplier;
    
    % ylabels
    [ytstr, yfstr] = define_ylabel(this);
    
    % Turn HandleVisibility 'on' (because the 'line' function use gca)
    hvisibility = get(hFig, 'HandleVisibility');
    set(hFig, 'HandleVisibility', 'on');
    
    % Time domain
    set(hFig, 'CurrentAxes', haxtd);
    htline = line(t, data, 'Tag', 'tline', 'Parent', haxtd);
    set(hndls.axes.tdxlabel, 'String', xlate(xtstr));
    set(hndls.axes.tdylabel, 'String', xlate(ytstr));
    
    % Freq domain
    set(hFig, 'CurrentAxes', haxfd);
    hfline = line(f, fresp, 'Tag', 'fline', 'Parent', haxfd);
    set(hndls.axes.fdxlabel, 'String', xlate(xfstr));
    set(hndls.axes.fdylabel, 'String', xlate(yfstr));
    
    % Restore HandleVisibility
    set(hFig, 'HandleVisibility', hvisibility);
    
    % Axes limits
    if strncmpi(siggetappdata(hFig, 'siggui', 'ZoomState'), 'zoom', 4),
        % Restore the zoom state of the figure
        setzoomstate(hFig);
    end
    if length(t) == 1 || isequal(diff(t), 0)
        t = [t(1)-1 t(1)+1];
    end
    set(haxtd, 'XLim', [t(1) t(end)], 'YLim', [0 1.1]);
    % This is for user-defined windows
    if max(max(data))>1 | min(min(data))<0,
        set(haxtd, 'YLimMode', 'auto');
    end
    set(haxfd, 'XLim', [f(1) f(end)], 'YLimMode', 'auto');
    
    % X Scale
    set(haxfd, 'XScale', get(getparameter(this, 'freqscale'), 'Value'));

    % Install the Data Markers
    set([htline hfline], 'ButtonDownFcn', @setdatamarkers);
    
    % Refresh legend
    set(this, 'Legend', get(this, 'Legend'));
    
    % Enable state of the "Frequency Specifications"
    enabState = 'on';
    
    figure(hFig);
    
else
    
    % Enable state of the "Frequency Specifications" 
    enabState = 'off';
    
end

% Enable/Disable the "Frequency Specifications" item of 
% the contextmenu and the "view" menu 
hmenus = findobj([hndls.contextmenu hndls.menu], 'Tag', 'frequnits');
set(hmenus, 'Enable', enabState);

% Enable/Disable the dialog box
analysisdialog = get(this, 'ParameterDlg');
if ~isempty(analysisdialog) & isrendered(analysisdialog),
    set(analysisdialog, 'Enable', enabState);
end

% Fire timefreq_listener
set(this, 'Timedomain', get(this, 'Timedomain'));



%---------------------------------------------------------------------
function clean_axes(haxtd, haxfd, hndls)
%CLEAN_AXES Delete the lines and remove xlabels and ylabels 

delete(findall(allchild(haxtd), 'Tag', 'tline'));
delete(findall(allchild(haxfd), 'Tag', 'fline'));
set(hndls.axes.tdxlabel, 'String', '');
set(hndls.axes.tdylabel, 'String', '');
set(hndls.axes.fdxlabel, 'String', '');
set(hndls.axes.fdylabel, 'String', '');


%---------------------------------------------------------------------
function [xtstr, xfstr, tmultiplier, fmultiplier] = define_xlabel(this)
%DEFINE_XLABEL Define the xlabel strings

frequnits = getfrequnitstrs;
[fs, xfunits, fmultiplier] = getfs(this, 'freq');
[tfs, xtunits, tmultiplier] = getfs(this, 'time');
if strcmpi(get(getparameter(this, 'freqmode'), 'Value'), 'normalized');
    xtstr = xlate('Samples');
    xfstr = xlate(frequnits{1});
else
    xtstr = sprintf('Time (%s)', xtunits);
    xfstr = sprintf('Frequency (%s)', xfunits);
end


%---------------------------------------------------------------------
function [ytstr, yfstr] = define_ylabel(this)
%DEFINE_YLABEL Define the ylabel strings

ytstr = xlate('Amplitude');
p  = getparameter(this, 'magnitude');
yfstr = p.Value;

if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
    yfstr = sprintf('Normalized %s', yfstr);
end

% [EOF]

