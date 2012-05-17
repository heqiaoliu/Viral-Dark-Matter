function cleanup(this)
% cleanup Clean up function for @plot class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:17 $

delete(this.AxesGrid(ishandle(this.AxesGrid)))  
wfs = allwaves(this);
delete(wfs(ishandle(wfs))) 
this.Listeners.deleteListeners;