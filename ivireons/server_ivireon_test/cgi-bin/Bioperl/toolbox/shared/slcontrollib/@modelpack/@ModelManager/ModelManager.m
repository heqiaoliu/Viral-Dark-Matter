function this = ModelManager()
% MODELMANAGER Constructor for the singleton Model Manager class.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2005/11/15 01:38:23 $

% Singleton object
persistent h;

% Create singleton class instance
if isempty(h) || ~ishandle(h)
  h = modelpack.ModelManager;

  L = handle.listener( h, 'ObjectBeingDestroyed', @(x,y) LocalDelete(h) );
  h.Listeners = [h.Listeners; L];
end

% Language workaround
this = h;

% ----------------------------------------------------------------------------
function LocalDelete(this)
% Manager is being destroyed.
