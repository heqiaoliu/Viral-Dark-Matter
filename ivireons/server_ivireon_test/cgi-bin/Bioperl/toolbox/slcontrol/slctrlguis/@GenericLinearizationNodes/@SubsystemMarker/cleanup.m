function cleanup(this)
% CLEANUP  Clean up the node
 
% Author(s): John W. Glass 19-Mar-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/04/03 03:17:51 $

if isfield(this.Handles,'ShowBlocksFlagListener')
    this.Handles.ShowBlocksFlagListener.Enabled = false;
    delete(this.Handles.ShowBlocksFlagListener);
end