function schema
% Defines properties for @designconstr superclass.
%
%   Specifics about @designconstr subclasses:
%     * Changes in data properties have no immediate effect and  
%       require an explicit call to UPDATE to refresh the graphics

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:55 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'designconstr');

% Constraint data
p = schema.prop(c,'Data','handle');                     % Data object used for undo/redo and load/save
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';

% Graphical elements
p = schema.prop(c,'Elements','mxArray');                 % Graphical elements making up constraint
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.SetFunction = {@localSetElements};

schema.prop(c, 'ButtonDownFcn', 'MATLAB callback');        % Button Down on marker/patch
p = schema.prop(c, 'isLocked', 'bool');                    % Can requirement be graphically manipulated?
p.FactoryValue = false;
schema.prop(c, 'LockedButtonDownFcn', 'MATLAB callback');  %Callback to fire when the constraint is locked but clicked
schema.prop(c, 'EventManager','handle');                   % Event coordinator (@eventmgr object)
schema.prop(c, 'TextEditor', 'mxArray');                   % Constraint editor handle
p = schema.prop(c, 'EditDlg', 'mxArray');                  % Handle to edit dialog
p.AccessFlag.AbortSet = 'off';

p = schema.prop(c, 'Selected', 'on/off');               % Selection flag 
p.FactoryValue = 'off';

p = schema.prop(c, 'Type', 'string');                   % Bound type [upper|lower]
p.FactoryValue = '';
p.SetFunction = {@localSet 'Type'};                     % Map to data object
p.GetFunction = {@localGet 'Type'};
p = schema.prop(c, 'Weight', 'mxArray');                % Bound weight [0 1]
p.FactoryValue = 1;
p.SetFunction = {@localSet 'Weight'};                   % Map to data object
p.GetFunction = {@localGet 'Weight'};

p = schema.prop(c, 'Zlevel', 'double');                 % Z coordinate for layering (default=0)
p.FactoryValue = 0;

p = schema.prop(c, 'ConstraintOverlap', 'bool');        % Flag, does constraint create infeasible region
p.FactoryValue = false;

p = schema.prop(c, 'PatchColor', 'mxArray');            % Color of patch
p.FactoryValue = [1 0.5 0.5];

p = schema.prop(c, 'EdgeColor', 'mxArray');             % Color of patch edge
p.FactoryValue = [0 0 0];

p = schema.prop(c, 'AllowContextMenu', 'mxArray');      % Structure with fields indicating which context menus can be shown
p.FactoryValue = [];

p = schema.prop(c, 'HelpData', 'mxArray');              % Help definitions 
p.FactoryValue = struct(...
   'MapFile',  '/mapfiles/control.map',...
   'EditHelp', 'sisoconstraintedit', ...
   'CSHTopic', '');

% Private properties 
schema.prop(c, 'Activated', 'bool');              % Needed to mitigate limitation of undo add
schema.prop(c, 'Listeners', 'mxArray');           % Listeners
schema.prop(c, 'Handles', 'mxArray');             % Structure with various handles
schema.prop(c, 'AppData', 'MATLAB array');        % Storage area
p = schema.prop(c,'xDisplayUnits','mxArray');     % x-coord units used when displaying constraint
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c,'yDisplayUnits','mxArray');     % y-coord units used when displaying constraint
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p = schema.prop(c, 'uID', 'string');               % Unique ID for constraint
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.Visible = 'off';

p = schema.prop(c, 'requirementObj', 'handle');    % parent srorequirement.requirement object
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';

p = schema.prop(c, 'undoDeleteInfo', 'mxArray');
p.AccessFlag.PublicGet = 'on';
p.AccessFlag.PublicSet = 'on';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.Visible = 'off';
p.FactoryValue = struct(...
   'fcnGetData',[],...
   'fcnUndoDelete',[], ...
   'fcnRedoDelete',[]);
 
% Events
% DataChanged: notifies environment that constraint data has changed 
%              (no listeners on individual data properties)
schema.event(c, 'DataChanged');
schema.event(c, 'DataChangeFinished');
%--------------------------------------------------------------------------
function valueStored = localSet(this, Value, fld)

this.setData(fld,Value);
if ischar(Value)
   valueStored = '';
else
   valueStored = [];
end

%--------------------------------------------------------------------------
function valueReturned = localGet(this, Value, fld) %#ok<INUSL>

valueReturned = this.getData(fld);

%--------------------------------------------------------------------------
function valueStored = localSetElements(this, Value) %#ok<INUSL>

valueStored = handle(Value);


