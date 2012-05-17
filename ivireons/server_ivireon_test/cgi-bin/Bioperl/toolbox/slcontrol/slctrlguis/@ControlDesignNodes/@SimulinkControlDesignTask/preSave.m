function preSave(this, varargin)
%  PRESAVE
%
%  Save properties to allow later reload.

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:08:27 $


h = this.getChildren;
for ct = 1:numel(h);
    controlnodes.saveDesignNode(h(ct),varargin)
end
