function configureFolderPanel(this, manager)
% CONFIGUREFOLDERPANEL

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/02/06 20:00:04 $

% Get panel handle
Panel = this.Panel;
Node  = this.Node;

% Add listeners
L = [ handle.listener( Node, 'ObjectChildAdded',   { @LocalListChanged } ); ...
      handle.listener( Node, 'ObjectChildRemoved', { @LocalListChanged } ); ...
      handle.listener( Node, 'ObjectBeingDestroyed', { @LocalDelete } ) ];
set(L, 'CallbackTarget', this);
this.Listeners = [ this.Listeners; L(:)];

% Get the handles
Handles   = this.Handles;
buttons   = Panel.getButtons;
menuitems = Panel.getMenuItems;

% Panel ancestor added callback
h = handle( Panel, 'callbackproperties' );
h.AncestorAddedCallback = { @LocalUpdatePanel, this };

% New button callback
fun = { @LocalNewButton, this, manager };
h = handle( buttons(1),   'callbackproperties' );
h.ActionPerformedCallback = fun;
h = handle( menuitems(1), 'callbackproperties' );
h.ActionPerformedCallback = fun;
h = handle( menuitems(4), 'callbackproperties' ); % Scroll right-click new
h.ActionPerformedCallback = fun;

% Delete button callback
fun = { @LocalDeleteButton, this };
h = handle( buttons(2),   'callbackproperties' );
h.ActionPerformedCallback = fun;
h = handle( menuitems(2), 'callbackproperties' );
h.ActionPerformedCallback = fun;

% Edit button callback
fun = { @LocalEditButton, this, manager };
h = handle( buttons(3), 'callbackproperties' );
h.ActionPerformedCallback = fun;
h = handle( menuitems(3), 'callbackproperties' );
h.ActionPerformedCallback = fun;

% Description field callback
h = handle( Panel.getDescriptionArea, 'callbackproperties' );
h.FocusLostCallback = { @LocalDescriptionUpdate this };

% Table model callback
Handles.TableModel = Panel.getFolderTable.getModel;
h = handle( Handles.TableModel, 'callbackproperties' );
h.TableChangedCallback = { @LocalTableChanged, this };

% Store the handles
this.Handles = Handles;

% ---------------------------------------------------------------------------- %
% Initialize & update components when the panel is shown
function LocalUpdatePanel(hSrc, hData, this)
children = LocalGetAllowedChildren(this);

% Update table
PrivateTableUpdate( this, children, 0, java.lang.Integer.MAX_VALUE );
this.Panel.getDescriptionArea.setText( this.Node.Description );

% ----------------------------------------------------------------------------- %
function LocalNewButton(hSrc, hData, this, manager)
node = this.Node.addNode;

% Expand the tree nodes so the user sees the new node
manager.Explorer.expandNode( this.Node.getTreeNodeInterface );
str = sprintf('- %s node has been added to %s.', node.Label, this.Node.Label );
manager.Explorer.postText( str );

% ---------------------------------------------------------------------------- %
function LocalDeleteButton(hSrc, hData, this)
rows     = this.Panel.getFolderTable.getSelectedRows + 1;
children = LocalGetAllowedChildren(this);

for ct = length(rows):-1:1
  this.Node.removeNode( children( rows(ct) ) );
end

% ---------------------------------------------------------------------------- %
function LocalEditButton(hSrc, hData, this, manager)
row      = this.Panel.getFolderTable.getSelectedRow + 1;
children = LocalGetAllowedChildren(this);

Leaf = children(row).getTreeNodeInterface;
manager.Explorer.setSelected( Leaf );

% ----------------------------------------------------------------------------- %
function LocalDescriptionUpdate(hSrc, hData, this)
this.Node.Description = char( hData.getSource.getText );

% ----------------------------------------------------------------------------- %
% Handle JAVA -> UDD changes
function LocalTableChanged(hSrc, hData, this)
row = hData.getFirstRow;
col = hData.getColumn;

% React only to fireTableCellUpdated(row, col);
if (col < 0)
  return
end

children = LocalGetAllowedChildren(this);
model    = hData.getSource;

switch col
  case 0
    children(row+1).Label = model.getValueAt(row, col);

    % Update the table row in case Label change hasn't been accepted.
    if ~strcmp(model.getValueAt(row,col), children(row+1).Label)
      PrivateTableUpdate( this, children, row, row );
    end
  case 1
    children(row+1).Description = model.getValueAt(row, col);
end

% ---------------------------------------------------------------------------- %
% Handle UDD -> JAVA changes
function LocalListChanged(this, hEvent)
child    = hEvent.Child;
children = LocalGetAllowedChildren(this);

% Do not add excluded types to the list.
if any( strcmp( class(child), this.ExcludeList ) )
  return
end

idx = find( children == child );

if strcmp( hEvent.Type, 'ObjectChildRemoved' )
  children(idx) = [];
else
  % ObjectChildAdded
end
PrivateTableUpdate( this, children, 0, java.lang.Integer.MAX_VALUE )

% ----------------------------------------------------------------------------- %
% Updata JAVA table model data
function PrivateTableUpdate(this, children, firstRow, lastRow)
% firstRow and lastRow are zero-based row numbers.
if ~isempty( children )
  table = javaArray('java.lang.Object', length(children), 2);

  for ct = 1:length(children)
    current = children(ct);
    table(ct,1) = java.lang.String( current.Label );
    table(ct,2) = java.lang.String( current.Description );
  end
else
  table = {};
end
model = this.Handles.TableModel;
model.setData( table, firstRow, lastRow );

% ----------------------------------------------------------------------------- %
% Get all children that are not excluded
function children = LocalGetAllowedChildren(this)
children = this.Node.getChildren;

% Remove excluded children from bottom
for ct = length(children):-1:1
  cls = class( children(ct) );

  if any( strcmp( cls, this.ExcludeList ) )
    children(ct) = [];
  end
end

% --------------------------------------------------------------------------
function LocalDelete(this, hData)
% Delete this object to trigger Java clean up.
delete(this)
