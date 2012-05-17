function preLoad(this, varargin)
%  PRELOAD
%
%  Save properties to allow later reload.

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:13:56 $

controlnodes.loadDesignNode(this,varargin)

% Set dirty listeners after loading
this.setDirtyListener;
