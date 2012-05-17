function cleanupmodel(this,initdata)
% INITMODEL Clean up the model for the snapshot

% Author(s): John Glass
% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/30 00:43:41 $

% Restore sparse math and block diagram settings
spparms('autommd', initdata.autommd_orig);
this.ModelParameterMgr.restoreModels;
