function h = timeplot(f,nrows,varargin)

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2010/03/04 16:30:46 $


import com.mathworks.toolbox.timeseries.*;
import java.awt.dnd.*

%% Create class instance
h = tsguis.timeplot;
if nargin==0
    return
end


%% Create axes
ax = axes('Parent',double(f),'Units','Normalized','Visible','off','ButtonDownFcn',...
        {@tsWindowButtonDownFcn h});
ax_plotedit = hggetbehavior(ax,'PlotEdit');
ax_plotedit.Enable = false;

%% Set the key press/key release callback
thisfig = ancestor(f,'figure');

%% Generic property init
init_prop(h, ax, [nrows 1]);

%% User-specified initial values (before listeners are installed...)
%% Needed to set styleManager
h.set(varargin{1:end});

%% Initialize the handle graphics objects used in @timeplot class.
h.initialize(ax, [nrows 1]);

%% Customize behavior
h.setbehavior

%% Remove Amplitude from ylabel to improve figure packing and remove Tex
%% interpreters which distort underscore characters
h.Axesgrid.Ylabel = '';
h.Axesgrid.TitleStyle.Interpreter = 'None';
h.Axesgrid.XLabelStyle.Interpreter = 'None';
h.Axesgrid.RowLabelStyle.Interpreter = 'None';

%% Add a listener to create data xticks for absolute times
h.addlisteners(addlistener(h.AxesGrid.Parent,'SizeChange',...
    @(es,ed) localUpdateLims(es,ed,h)));

%% Add a listener to keep the axesgrid units in sync with the @timeplot
%% TimeUnits.
h.addlisteners(handle.listener(h,h.findprop('Startdate'),'PropertyPostSet',...
    {@localClearData h}));
h.addlisteners(handle.listener(h,h.findprop('Timeunits'),'PropertyPostSet',...
    {@localClearData h}));
h.addlisteners(handle.listener(h,h.findprop('TimeFormat'),'PropertyPostSet',...
    {@localClearData h}));

%% Add menus
menus = h.tsplotmenu('TimePlot');

%% Add char menus and set their tag so that findmenu can be used by the
%% char table to keep the menu checked status synched
mean_menu = h.addCharMenu(menus.Characteristics, 'Mean',...
    'tsguis.tsMeanData', 'tsguis.tsMeanView'); 
set(mean_menu,'Tag','Mean')
std_menu = h.addCharMenu(menus.Characteristics, 'STD',...
    'tsguis.tsMeanData', 'tsguis.tsStdView'); 
set(std_menu,'Tag','STD')
median_menu = h.addCharMenu(menus.Characteristics, 'Median',...
    'tsguis.tsMeanData', 'tsguis.tsMedianView'); 
set(median_menu,'Tag','Median')

%--------------------------------------------------------------------------
function localClearAbsTimeResps(es,ed,h)

%% Clear the data from all responses
for k=1:length(h.Waves)        
    h.Waves(k).Data.clear

end

function localClearData(eventSrc,eventData,h)

%% Listener callback which forces a redraw if the plot time parameters
%% change
 
%% Clear the data from all responses
for k=1:length(h.Waves)        
    h.Waves(k).Data.clear
end

function localUpdateLims(es,ed,h)

limState = h.AxesGrid.LimitManager;
h.AxesGrid.LimitManager = 'off';
h.updatelims;
h.AxesGrid.LimitManager = limState;
