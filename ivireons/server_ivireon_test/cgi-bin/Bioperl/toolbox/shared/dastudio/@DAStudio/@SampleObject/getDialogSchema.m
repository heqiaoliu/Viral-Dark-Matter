function dlg = getDialogSchema(h, name)

% Copyright 2004 The MathWorks, Inc.

% ========================================================================= 
% description group box
% =========================================================================

txtDescription.Type = 'text';
txtDescription.Name = sprintf([ 'Represents a user defined rigid body.  Body defined' ...
                              'by mass m, inertial tensor I, and coordinate origins and' ...
                              'axes for center of gravity (CG) and other user-specified' ...
                              'Body coordinate systems.  This dialog sets Body initial' ...
                              'position and orientation, unless Body and/or connected' ...
                              'Joints are actuated separately']);
txtDescription.WordWrap = true;
                          
grpDescription.Name = 'Body';
grpDescription.Type = 'group';
grpDescription.Items = {txtDescription};
grpDescription.RowSpan = [1 1];
grpDescription.ColSpan = [1 1];

% ========================================================================= 
% mass properties group box
% =========================================================================
lblMass.Type = 'text';
lblMass.Name = 'Mass';
lblMass.RowSpan = [1 1];
lblMass.ColSpan = [1 1];

txtMass.Type = 'edit';
txtMass.ObjectProperty = 'mass';
txtMass.RowSpan = [1 1];
txtMass.ColSpan = [2 2];

cmbMUnit.Type = 'combobox';
cmbMUnit.ObjectProperty = 'massUnits';
cmbMUnit.RowSpan = [1 1];
cmbMUnit.ColSpan = [3 3 ];

pnlSpacer.Type = 'panel';
pnlSpacer.RowSpan = [1 1];
pnlSpacer.ColSpan = [4 4];

lblIner.Type = 'text';
lblIner.Name = 'Inertia';
lblIner.RowSpan = [2 2];
lblIner.ColSpan = [1 1];

txtIner.Type = 'edit';
txtIner.ObjectProperty = 'inertia';
txtIner.RowSpan = [2 2];
txtIner.ColSpan = [2 2];

cmbIUnit.Type = 'combobox';
cmbIUnit.ObjectProperty = 'inertiaUnits';
cmbIUnit.RowSpan = [2 2];
cmbIUnit.ColSpan = [3 3];

txtInerDesc.Type = 'text';
txtInerDesc.Name = '* with respect to the Center of Gravity CG Body coordinate system';
txtInerDesc.RowSpan = [2 2];
txtInerDesc.ColSpan = [4 4];

grpMassProp.Name = 'Mass properties';
grpMassProp.Type = 'group';
grpMassProp.LayoutGrid = [2 4];
grpMassProp.ColStretch = [0 0 0 1];
grpMassProp.Items = {lblMass, txtMass, cmbMUnit, pnlSpacer,...
                     lblIner, txtIner,  cmbIUnit, txtInerDesc};
grpMassProp.RowSpan = [2 2];
grpMassProp.ColSpan = [1 1];


% ========================================================================= 
% Body coordinate systems group box
% ========================================================================= 
tblPos.Tag  = 'tablePos';
tblPos.Type = 'table';
tblPos.Size = [length(h.positionSchema) 7];
tblPos.Grid = true;
tblPos.HeaderVisibility = [0 1];
tblPos.RowHeader = {'col 1', 'col 2', 'col 3'};
tblPos.ColHeader =  {sprintf('Show\n port'),...
                     sprintf(' Port\n side'),...
                     sprintf('\nName'),...
                     sprintf('Origin position \n vector [x y z]'),...
                     sprintf('\nUnits'),...
                     sprintf('Translated from\n     origin of'),...
                     sprintf('Components in\n     axes of')}; 


tblPos.ColumnCharacterWidth = [4 5 4 11 4 12 11]; 
tblPos.ColumnHeaderHeight = 2;
tblPos.ReadOnlyColumns = [2];
%tblPos.ReadOnlyRows = [0 1];

tblPos.Editable = true;
tblPos.ValueChangedCallback = @onValueChanged;
%tblPos.CurrentItemChangedCallback = @onCurrentChanged;

data = {};
for i=1:length(h.positionSchema)
    s = h.positionSchema(i);

    % position rows
    chkShowPort.Type = 'checkbox';
    chkShowPort.ObjectProperty = 'showPort';
    chkShowPort.Source = s;
    data{i, 1} = chkShowPort;
    
    % port side
    cmbPortSide.Type = 'combobox';
    cmbPortSide.ObjectProperty = 'portSide';
    cmbPortSide.Source = s;
    data{i, 2} = cmbPortSide;
    
    % name
    strName.Type = 'edit';
    strName.ObjectProperty = 'name';
    strName.Source = s;
    data{i, 3} = strName;
    
    % origin position vector
    strOriginPos.Type = 'edit';
    strOriginPos.ObjectProperty = 'originPosVector';
    strOriginPos.Source = s;
    data{i, 4} = strOriginPos;

    % units
    cmbUnits.Type = 'combobox';
    cmbUnits.ObjectProperty = 'units';
    cmbUnits.Source = s;
    data{i, 5} = cmbUnits;
    
    % origin
    cmbOrigin.Type = 'combobox';
    cmbOrigin.ObjectProperty = 'origin';
    cmbOrigin.Source = s;
    data{i, 6} = cmbOrigin;
    
    % axes
    cmbAxes.Type = 'combobox';
    cmbAxes.ObjectProperty = 'axes';
    cmbAxes.Source = s;
    data{i, 7} = cmbAxes;
end

tblPos.Data = data;
tblPos.SelectedRow = 2;


% ========================================================================= 
% Tab widget example
% ========================================================================= 
pnlPosition.Name  = 'Position';
pnlPosition.Items = {tblPos};

pnlOrientation.Name = 'Orientation';

tabBodyCoord.Type = 'tab';
tabBodyCoord.Tabs = {pnlPosition, pnlOrientation};


grpBodyCoord.Name = 'Body coordinate systems';
grpBodyCoord.Type = 'group';
grpBodyCoord.Items = {tabBodyCoord};
grpBodyCoor.ColSpan = [1 1];
grpBodyCoord.RowSpan = [3 3];

% ========================================================================= 
% Main dialog
% ========================================================================= 
dlg.DialogTitle = 'Block Parameters: Body';
dlg.HelpMethod  = 'doc';
dlg.HelpArgs    = {'simulink'};
dlg.Items       = {grpDescription, grpMassProp, grpBodyCoord};
dlg.LayoutGrid  = [3 1];
dlg.RowStretch  = [0 0 1];

% ========================================================================= 
% value changed callback
% ========================================================================= 
function onValueChanged(d, r, c, val)

if isstr(val) 
  disp(sprintf('item at (%d, %d) changed to ''%s''', r,c,val));
else
  disp(sprintf('item at (%d, %d) changed to %d', r,c,val));
end

% ========================================================================= 
% current changed callback
% =========================================================================
function onCurrentChanged(d, r, c)
  disp(sprintf('selected item at (%d, %d)', r,c));



