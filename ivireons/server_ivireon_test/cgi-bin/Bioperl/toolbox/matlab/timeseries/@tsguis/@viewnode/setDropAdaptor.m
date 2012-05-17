function setDropAdaptor(h,this)

% Copyright 2004-2007 The MathWorks, Inc.

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;


%% Creates a drop target from supplied drop adaptor 
if isunix % g269682
    jf = tsguis.getJavaFrame(ancestor(h.Plot.AxesGrid.Parent,'figure'));
    if ~isempty(jf)
        h.AxisCanvas = jf.getAxisComponent;
    end
end
h.DropTarget = DropTarget(h.AxisCanvas,this);
awtinvoke(h.AxisCanvas,'setDropTarget',h.DropTarget);
drawnow