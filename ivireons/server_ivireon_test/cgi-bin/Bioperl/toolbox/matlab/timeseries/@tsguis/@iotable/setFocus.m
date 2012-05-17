function setFocus(h)
%SETFOCUS
%
%   Authors: James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:58:14 $

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% Brings the gui to the front - jgo

rw = MLthread(h.Explorer, 'setVisible',{true});
SwingUtilities.invokeLater(rw);