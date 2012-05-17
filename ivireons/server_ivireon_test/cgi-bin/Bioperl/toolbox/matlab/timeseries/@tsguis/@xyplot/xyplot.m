function h = xyplot(f, nrows, ncols)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.dnd.*

% Create class instance
h = tsguis.xyplot;
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
    
% Generic property init
init_prop(h, ax, [nrows ncols]);

% Initialize the handle graphics objects used in @xyplot class. Note there
% is no base class initialize method
geometry = struct('HeightRatio',[],...
'HorizontalGap', 16, 'VerticalGap', 16, ...
'LeftMargin', 12, 'TopMargin', 20, 'PrintScale', 1);
h.AxesGrid = ctrluis.axesgrid([nrows ncols], ax, ...
'Visible',     'off', ...
'Geometry',    geometry, ...
'LimitFcn',  {@updatelims h}, ...
'Title',    xlate('XY Plot'), ...
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
h.Axesgrid.YLabelStyle.Interpreter = 'None';
h.Axesgrid.RowLabelStyle.Interpreter = 'None';
h.Axesgrid.ColumnLabelStyle.Interpreter = 'None';

%% Add menus
menus = h.tsplotmenu('XYPlot');

%% Add char menus
regchar = h.addCharMenu(menus.Characteristics, xlate('Best fit line'),...
    'tsguis.regLineData', 'tsguis.regLineView');  
set(regchar,'Tag','Best fit line')











