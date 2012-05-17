function deleteWindow(h)
%  deleteWindow
%
%  Closes the DV's window. Note this method is intended
%  to be invoked by tests that open and close the DV programmatically.
%  It should not be invoked in contexts where a user needs to interact
%  with the DV.
%
%  Copyright 2008 The MathWorks, Inc.

    h.Visible = false;

end