function Data = getzerotimedata(this)
% GETZEROTIMEDATA  Method to gather snapshots

%  Author(s): John Glass
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:03:23 $

Data = getopsnapshot(this,0);