function initialize(h,view)

% Copyright 2004-2008 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import java.awt.*;
import javax.swing.*;

% Create Tabbed panel to host tabs
h.Handles.TabPane = javaObjectEDT('com.mathworks.mwswing.MJTabbedPane');

% Add tabbed pane to uitspanel host panel
javaMethodEDT('add',view.AxesGrid.Parent.jpanel,h.Handles.TabPane);

        