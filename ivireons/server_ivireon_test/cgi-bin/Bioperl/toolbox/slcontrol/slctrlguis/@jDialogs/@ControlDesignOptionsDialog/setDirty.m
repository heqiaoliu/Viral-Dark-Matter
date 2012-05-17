function setDirty(this)
% SETDIRTY(this) Set this node's project dirty flag

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:38 $

this.TaskNode.up.Dirty = 1;