function copynode(this,manager)
%copynode callback

%   Copyright 2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2005/06/27 22:59:18 $


%% Copy context menu/ctrl-c callback
manager.Root.Tsviewer.Clipboard = this;