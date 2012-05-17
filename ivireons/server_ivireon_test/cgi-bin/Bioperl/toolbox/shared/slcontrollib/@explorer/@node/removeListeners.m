function removeListeners(this)
% REMOVELISTENERS Remove all listeners

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 20:00:34 $

% Remove all listeners
delete( this.TreeListeners( ishandle(this.TreeListeners) ) )
this.TreeListeners = [];

delete( this.Listeners( ishandle(this.Listeners) ) )
this.Listeners = [];
