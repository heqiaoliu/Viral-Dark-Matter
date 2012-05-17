function h = varbrowser
% varbrowser constructor

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:33:36 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = nlutilspack.varbrowser;
h.javahandle = ImportView(h);

