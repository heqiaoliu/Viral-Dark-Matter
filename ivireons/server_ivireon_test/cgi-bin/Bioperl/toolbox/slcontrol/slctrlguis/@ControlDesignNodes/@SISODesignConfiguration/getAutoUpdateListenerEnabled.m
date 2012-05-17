function state = getAutoUpdateListenerEnabled(this)
% GETAUTOUPDATELISTENERENABLED  Return the enable state of the AutoUpdateListener. 
%
 
% Author(s): John W. Glass 17-Nov-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 19:08:07 $

state = this.AutoUpdateListener.Enabled;