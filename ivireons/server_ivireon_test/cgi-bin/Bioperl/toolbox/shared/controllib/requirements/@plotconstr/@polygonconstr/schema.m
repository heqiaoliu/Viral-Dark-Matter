function schema
% Defines properties for @rectconstr superclass

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:53 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'polygonconstr',findclass(pk,'designconstr'));

% Data
p = schema.prop(c,'Orientation','string');     % Enumerated type [{horizontal}|vertical]
p.FactoryValue = 'horizontal';
p.SetFunction = @localSetOrientation;

% Virtual  Data
p = schema.prop(c,'xCoords','mxArray');   % x-Axis Start and end coordinates
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.SetFunction = {@localSet 'xCoords'};    % Map to data object
p.GetFunction = {@localGet 'xCoords'};

p = schema.prop(c,'xUnits','string');     % x-Axis units
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.FactoryValue = 'none';
p.SetFunction = {@localSet 'xUnits'};    % Map to data object
p.GetFunction = {@localGet 'xUnits'};

p = schema.prop(c,'yCoords','mxArray');   % y-Axis Start and end coordinates
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.SetFunction = {@localSet 'yCoords'};    % Map to data object
p.GetFunction = {@localGet 'yCoords'};

p = schema.prop(c,'yUnits','string');     % y-Axis units
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.FactoryValue = 'none';
p.SetFunction = {@localSet 'yUnits'};    % Map to data object
p.GetFunction = {@localGet 'yUnits'};

p = schema.prop(c,'Linked','mxArray');    % Flags indicating how neighbours are joined in x & y axis
p.AccessFlag.PublicGet = 'off';
p.AccessFlag.PublicSet = 'off';
p.AccessFlag.PrivateGet = 'on';
p.AccessFlag.PrivateSet = 'on';
p.SetFunction = {@localSet 'Linked'};    % Map to data object
p.GetFunction = {@localGet 'Linked'};

p = schema.prop(c,'SelectedEdge','mxArray');   %Edge closest to last button down
p.FactoryValue = 1;
p.SetFunction = {@localSet 'SelectedEdge'};    % Map to data object
p.GetFunction = {@localGet 'SelectedEdge'};

%--------------------------------------------------------------------------
function valueStored = localSetOrientation(this, Value)

validValues = {'horizontal','vertical','both'};

if ~ismember(Value,validValues);
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errPolygonOrientation');
end

valueStored = Value;

%--------------------------------------------------------------------------
function valueStored = localSet(this, Value, fld)

this.setData(fld,Value);
if ischar(Value)
   valueStored = '';
else
   valueStored = [];
end

%--------------------------------------------------------------------------
function valueReturned = localGet(this, Value, fld)

valueReturned = this.getData(fld);


