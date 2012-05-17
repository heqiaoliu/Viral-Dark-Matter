function addListeners( this )
% ADDLISTENERS Add UDD related listeners

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/02/06 20:00:20 $

% Add property listeners
L = [ handle.listener(this.Root, 'PropertyChange', @LocalTreeUpdate), ...
      handle.listener(this,'ObjectBeingDestroyed', @LocalObjectBeingDestroyed) ];
set(L, 'CallbackTarget', this);
this.Listeners = L;

% ----------------------------------------------------------------------------
% Clean up @node and java objects
function LocalObjectBeingDestroyed(this, hData)
cleanup(this)

% ----------------------------------------------------------------------------
% Update the Java tree when nodes are added or removed
function LocalTreeUpdate(this, hEvent)
Tree  = this.ExplorerPanel.getSelector.getTree;
Model = Tree.getModel;

switch hEvent.propertyName
case 'NODES_WERE_INSERTED'
  newData = hEvent.newValue;
  Model.insertNodes( newData{1}, newData{2} );
case 'NODES_WERE_REMOVED'
  oldData = hEvent.oldValue;
  Model.removeNodes( oldData{1}, oldData{2}, oldData(3)  );
case 'NODE_CHANGED'
  newData = hEvent.newValue;
  Model.changeNode( newData{1} );
end

% Flush the event queue
drawnow;
