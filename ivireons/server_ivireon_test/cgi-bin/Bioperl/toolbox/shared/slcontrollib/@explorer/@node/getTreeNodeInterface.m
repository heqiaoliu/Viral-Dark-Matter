function node = getTreeNodeInterface(this)
% GETTREENODEINTERFACE Returns handle to Java Tree Node associated with this
% object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2007/12/14 15:01:21 $

if isempty( this.TreeNode )
  import com.mathworks.toolbox.control.explorer.ExplorerTreeNode;
  this.TreeNode = ExplorerTreeNode( this.Label, this.AllowsChildren, ...
                                    this.Editable, this.Icon, this );

  % Add property change callbacks
  h = handle( this.TreeNode, 'callbackproperties' );
  h.PropertyChangeCallback = { @LocalJavaPropertyChange, this };

  % Add property listeners
  L = handle.listener( this, findprop(this, 'Label'), ...
                       'PropertyPostSet', { @LocalUDDPropertyChange, this } );
  this.TreeListeners = [ this.TreeListeners; L(:) ];
end

node = this.TreeNode;

% -----------------------------------------------------------------------------
% Update UDD object when a property changes on the java side
function LocalJavaPropertyChange(hSrc, hData, this)
import com.mathworks.toolbox.control.explorer.ExplorerTreeNode;

name  = char( hData.getPropertyName );
value = hData.getNewValue;
Node  = hData.getSource;

switch name
  case char( ExplorerTreeNode.LABEL_CHANGED_PROPERTY )
    currentname  = this.Label;
    proposedname = value;

    if isUniqueName(this, currentname, proposedname)
      this.Label = proposedname;
    else
      Node.setLabel( currentname );

      % Get top node and fire event.
      newData = { Node };
      wksp = handle( Node.getRoot.getObject );
      wksp.firePropertyChange('NODE_CHANGED', [], newData);
    end
end

% -----------------------------------------------------------------------------
% Update Java objects when a UDD property changes.
function LocalUDDPropertyChange(hSrc, hData, this)
name  = hData.Source.Name;
value = hData.NewValue;
Node  = this.TreeNode;

switch name
  case 'Label'
    % Fire event only if Java label has really changed.
    if ~strcmp(Node.getLabel, this.Label)
      currentname  = char( Node.getLabel );
      proposedname = this.Label;

      if isUniqueName(this, currentname, proposedname)
        Node.setLabel( proposedname );

        % Get top node and fire event.
        newData = { Node };
        wksp = handle( Node.getRoot.getObject );
        wksp.firePropertyChange('NODE_CHANGED', [], newData);
      else
        this.Label = currentname;
      end
    end
end

% -----------------------------------------------------------------------------
function flag = isUniqueName(this, currentname, proposedname)
flag = true;

% If no parent, name doesn't matter
parent = this.up;
if isempty(parent)
  return
end

nodes = this.up.getChildren;
peers = nodes( nodes ~= this);
names = get( peers, {'Label'});

if any( strcmp( proposedname, names) )
  errmsg = sprintf( ['Cannot rename %s to %s: A node with the name you ' ...
                     'specified already exists. Specify a different name.'], ...
                    currentname, proposedname );
  dlg = errordlg( errmsg, 'Error Renaming Node', 'modal');
  % In case the dialog is closed before uiwait blocks MATLAB.
  if ishandle(dlg)
    uiwait(dlg)
  end
  flag = false;
elseif isempty( strtrim(proposedname) )
  errmsg = sprintf( 'Cannot rename %s: New name should not be empty.', ...
                    currentname );
  dlg = errordlg( errmsg, 'Error Renaming Node', 'modal');
  % In case the dialog is closed before uiwait blocks MATLAB.
  if ishandle(dlg)
    uiwait(dlg)
  end
  flag = false;
end
