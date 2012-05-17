function h = histplot(f,nrows,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.dnd.*

% Create class instance
h = tsguis.histplot;
if nargin==0
    return
end

%% Configure figure
ax = axes('Parent',double(f),'Units','Normalized','Visible','off','ButtonDownFcn',...
    {@tsWindowButtonDownFcn h});
ax_plotedit = hggetbehavior(ax,'PlotEdit');
ax_plotedit.Enable = false;

%% Set the key press callback
set(ancestor(f,'figure'),'KeyPressFcn',{@tsKeyPressFcn h})
    
%% Generic property init
init_prop(h, ax, [nrows 1]);

%% User-specified initial values (before listeners are installed...)
%% Needed to set styleManager
h.set(varargin{1:end});

%% Initialize the handle graphics objects used in @specplot class.
%% Note there is no base class initialize method 
geometry = struct('HeightRatio',[],...
'HorizontalGap', 16, 'VerticalGap', 16, ...
'LeftMargin', 12, 'TopMargin', 20, 'PrintScale', 1);
h.AxesGrid = ctrluis.axesgrid([nrows 1], ax, ...
'Visible',     'off', ...
'Geometry',    geometry, ...
'LimitFcn',  {@updatelims h}, ...
'Title',    'Histogram', ...
'XLabel',   '',...
'YLabel',  '',...
'XUnit',  '');
init_graphics(h)
addlisteners(h)

%% Customize behavior
h.setbehavior

%% Remove Amplitude from ylabel to improve figure packing and remove Tex
%% interpreters which distort underscore characters
h.Axesgrid.Ylabel = '';
h.Axesgrid.TitleStyle.Interpreter = 'None';
h.Axesgrid.XLabelStyle.Interpreter = 'None';
h.Axesgrid.RowLabelStyle.Interpreter = 'None';

%% Add menus
menus = h.tsplotmenu('HistPlot');

%% Add char menus and set their tag so that findmenu can be used by the
%% char table to keep the menu checked status synched
mean_menu = h.addCharMenu(menus.Characteristics, 'Mean',...
    'tsguis.histMeanData', 'tsguis.histMeanView'); 
set(mean_menu,'Tag','Mean')
ctrl_menu = h.addCharMenu(menus.Characteristics, 'Median',...
    'tsguis.histMedianData', 'tsguis.histMeanView'); 
set(ctrl_menu,'Tag','Median')













