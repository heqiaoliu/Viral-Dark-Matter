function schema
% Defines properties for @tsnode class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2008/12/29 02:10:57 $


% Register class (subclass)
p = findpackage('tsexplorer');
pparent = findpackage('explorer');
%c = schema.class(p, 'node',findclass(pparent,'node'));
c = schema.class(p, 'node');


%% Property definitions copied from explore.node. Cannot subclass
%% bacause of restrictive typing, e.g. Dialog must be a JComponent
p = schema.prop(c,'Dialog','MATLAB array');
%p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the Java dialog associated with this node';
p = schema.prop(c,'HelpFile','string');
p.FactoryValue = fullfile(matlabroot, 'toolbox', 'matlab', 'timeseries', ...
                         '@tsexplorer', '@node','tshelp.htm');
schema.prop(c,'HelpDialog','MATLAB array');
p = schema.prop( c, 'Label', 'string' );
p.AccessFlags.PublicSet = 'on';
p.Description = 'Name of the node to be shown in the tree.';
p = schema.prop( c, 'AllowsChildren', 'bool' );
p.FactoryValue = false;
p.AccessFlags.PublicSet = 'off';
p.Description =  'Specifies whether the node is a leaf or folder.';
p = schema.prop( c, 'Editable', 'bool' );
p.FactoryValue = true;
p.AccessFlags.PublicSet = 'off';
p.Description = 'Specifies whether the node name is editable in the tree.';
p = schema.prop( c, 'Description', 'string' );
p.FactoryValue = '';
p.AccessFlags.PublicSet = 'on';
p.Description = 'Description of the node.';
p = schema.prop( c, 'Fields', 'MATLAB array' );
p.FactoryValue = [];
p.AccessFlags.PublicSet = 'on';
p.Description = 'User structure for storing node specific data.';
p = schema.prop( c, 'Icon', 'string' );
p.AccessFlags.PublicSet = 'off';
p.Description = 'Name of the image file containing the node icon.';
p = schema.prop( c, 'Status', 'string' );
p.FactoryValue =  '';
p.AccessFlags.PublicSet = 'on';
p.Description = 'Status string shown when this node is selected in the tree.';

% ---------------------------------------------------------------------------- %
p = schema.prop( c, 'Handles', 'MATLAB array' );
%p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Structure for storing node specific Java handles.';

p = schema.prop(c, 'ListenersData', 'MATLAB array'); % ListenerManager Class
p.AccessFlags.Serialize = 'off';

p = schema.prop( c, 'Listeners', 'MATLAB array' );
%p.AccessFlags.PublicGet = 'off';
%p.AccessFlags.PublicSet = 'off';
p.GetFunction = @LocalGetListenersValue;
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off',...
    'AccessFlags.PrivateSet', 'off','AccessFlags.Serialize','off');
p.Description = 'Handles of general purpose listeners.';

p = schema.prop( c, 'TreeListeners', 'handle vector' );
%p.AccessFlags.PublicGet = 'off';
%p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handles of tree node related listeners.';

% Listener to the data name change
p = schema.prop( c, 'DataNameChangeListener', 'handle');
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle to the listener for data object name change.';

p = schema.prop( c, 'PopupMenu', 'com.mathworks.mwswing.MJPopupMenu');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the popup menu associated with this node.';
p = schema.prop( c, 'TreeNode', 'MATLAB array' );
%p.AccessFlags.PublicSet = 'off';
%p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the Java tree node';

p = schema.prop(c,'isRoot','MATLAB array');
p.FactoryValue = false;

function StoredValue = LocalGetListenersValue(this,StoredValue)
if isempty(this.ListenersData)
    this.ListenersData = controllibutils.ListenerManager;
end
StoredValue = this.ListenersData;

