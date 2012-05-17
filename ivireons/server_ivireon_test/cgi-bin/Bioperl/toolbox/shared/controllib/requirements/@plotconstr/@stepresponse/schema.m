function schema

% Defines properties for @stepresponse class

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:04 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'stepresponse',findclass(pk,'polygonconstr'));

% Step response characteristics
p = schema.prop(c,'StepChar','mxArray');        % Structure with characteristics
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Editor data
p = schema.prop(c,'Time','mxArray');            % Time coordinates
p.SetFunction = {@localSet 'X'};                % Map time to x-axis
p.GetFunction = {@localGet 'X'};
p = schema.prop(c,'TimeUnits','string');        % Time units
p.SetFunction = {@localSetUnits 'X'};           % Map time to x-axis
p.GetFunction = {@localGetUnits 'X'};
p.FactoryValue = 'sec';
p = schema.prop(c,'Magnitude','mxArray');       % Magnitude coordinates
p.SetFunction = {@localSet 'Y'};                % Map magnitude to y-axis
p.GetFunction = {@localGet 'Y'};
p = schema.prop(c,'MagnitudeUnits','string');   % Magnitude units
p.SetFunction = {@localSetUnits 'Y'};           % Map time to y-axis
p.GetFunction = {@localGetUnits 'Y'};
p.FactoryValue = 'abs';

%--------------------------------------------------------------------------
function valueStored = localSet(this, Value, Coord)

if ~all(size(Value)==size(this.(['get',Coord])))
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errChangeVertices');
end
valueStored = [];
this.(['set',Coord])(Value);

%--------------------------------------------------------------------------
function valueReturned = localGet(this, Value, Coord)

valueReturned = this.(['get',Coord]);

%--------------------------------------------------------------------------
function valueStored = localSetUnits(this, Value, Coord)

valueStored = '';
this.(['set',Coord,'Units'])(Value);

%--------------------------------------------------------------------------
function valueReturned = localGetUnits(this, Value, Coord)

valueReturned = this.(['get',Coord,'Units']);
