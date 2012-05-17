function initialize(this,manager)
%INITIALIZE
%
%   Authors: James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 21:38:58 $

import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

%% Assign the targets so the import dialogs update the correct table and
%% frame
this.Explorer = manager.Explorer;

%% Show/build import selector
this.edit(manager.Explorer);

%% Show it
rw = MLthread(this.ImportSelector.Importhandles.importDataFrame, ...
    'setVisible',{true});
SwingUtilities.invokeLater(rw);

