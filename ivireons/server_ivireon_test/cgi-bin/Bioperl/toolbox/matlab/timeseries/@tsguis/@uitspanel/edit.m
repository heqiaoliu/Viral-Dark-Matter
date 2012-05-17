function edit(h,pnl)

% Copyright 2005 The MathWorks, Inc.

import com.mathworks.mwswing.*;

% Set the FigureHandleProxy for the figure PlotTool SelectionManager. This
% substitues the uitspanel for the figure as the default selelection
f = ancestor(h,'figure');
sm = getplottool(f,'SelectionManager');
sm.setFigureHandleProxy(h);

%% Build property editor, but cache it first so that callbacks don't
%% assume it fully exists until the edit method has returned
h.jpanel = pnl;
thisEditor = tsguis.propeditor;
h.Plot.edit(thisEditor);
h.Plot.PropEditor = thisEditor;
h.Plot.Axesgrid.send('viewchange'); % Refresh the now complete propeprty editor

%% Reset drop adaptor which may have been overwrittehn when the property
%% editor was created
h.Plot.Parent.setDropAdaptor(h.Plot.Parent.DropAdaptor);