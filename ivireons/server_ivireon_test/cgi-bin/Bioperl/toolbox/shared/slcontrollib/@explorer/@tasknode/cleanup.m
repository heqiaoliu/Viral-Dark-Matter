function cleanup(this)
% CLEANUP Clean up before this object is destroyed.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 20:00:37 $

if ~isempty(this.MenuBar)
  awtinvoke( this.MenuBar, 'dispose()')
  this.MenuBar = [];
end

if ~isempty(this.ToolBar)
  awtinvoke(this.ToolBar, 'dispose()')
  this.ToolBar = [];
end
