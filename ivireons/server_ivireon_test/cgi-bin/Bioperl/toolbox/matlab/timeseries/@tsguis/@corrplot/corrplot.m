function h = corrplot(f,nrows,ncols)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.dnd.*

%% Create class instance
h = tsguis.corrplot;
if nargin==0
    return
end

%% Configure figure
ax = axes('Parent',double(f),'Units','Normalized','Visible','off');

%% Set the key press callback
set(ancestor(f,'figure'),'KeyPressFcn',{@tsKeyPressFcn h})

%% Generic property init
init_prop(h, ax, [nrows ncols]);

%% Initialize the handle graphics objects used in @corrplot class. Note there
%% is no base class initialize method
geometry = struct('HeightRatio',[],...
'HorizontalGap', 16, 'VerticalGap', 16, ...
'LeftMargin', 12, 'TopMargin', 20, 'PrintScale', 1);
h.AxesGrid = ctrluis.axesgrid([nrows ncols], ax, ...
'Visible',     'off', ...
'LimitFcn',  {@updatelims h}, ...
'XLabel',   xlate('Lags'),...
'YLabel',   xlate('Correlation'),...
'XUnit',  '');

%% 'Geometry',    geometry, ...
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
h.tsplotmenu('CorrPlot');











