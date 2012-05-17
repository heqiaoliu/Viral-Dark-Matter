function preLoad(this, varargin)
%  PRELOAD
%
%  Save properties to allow later reload.

%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2008/06/13 15:31:12 $

h = this.getChildren;

% Try to open the model.  If this fails then it will not allow the project
% to be opened
try
    open_system(this.model)
catch ME
    ctrlMsgUtils.error('Slcontrol:linutil:CouldNotOpenModel',this.model)
end

for ct = 1:length(h);
   controlnodes.loadDesignNode(h(ct),varargin)
   %% Add the default GUI listeners
   h(ct).createDefaultListeners;
   % Set dirty listeners after loading
   h(ct).setDirtyListener;
end

