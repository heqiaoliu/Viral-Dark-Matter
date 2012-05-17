function schema
% Defines properties for @bodegain class

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:24 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'bodegain',findclass(pk,'polygonconstr'));

% Editor data
p =schema.prop(c,'Frequency','mxArray');        % Start and end frequency (in rad/sec)
p.SetFunction = {@localSet 'X'};                % Map frequency to x-axis
p.GetFunction = {@localGet 'X'};
p = schema.prop(c,'FrequencyUnits','string');   % Frequency units
p.FactoryValue = 'rad/sec';
p.SetFunction = {@localSetUnits 'X'};           % Map frequency to x-axis
p.GetFunction = {@localGetUnits 'X'};
p = schema.prop(c,'Magnitude','mxArray');       % Corresponding gains (in dB)
p.SetFunction = {@localSet 'Y'};                % Map magnitude to y-axis
p.GetFunction = {@localGet 'Y'};
p = schema.prop(c,'MagnitudeUnits','string');   % Magnitude units
p.FactoryValue = 'dB';
p.SetFunction = {@localSetUnits 'Y'};           % Map magnitude to y-axis
p.GetFunction = {@localGetUnits 'Y'};

schema.prop(c,'Ts','double');                   % Current sampling time (conditions visibility)

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
