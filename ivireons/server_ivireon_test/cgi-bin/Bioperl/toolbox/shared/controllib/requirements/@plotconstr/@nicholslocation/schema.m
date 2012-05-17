function schema

% Defines properties for @nicholslocation class

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:18 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'nicholslocation',findclass(pk,'polygonconstr'));

% Editor data
p = schema.prop(c,'OLPhase','mxArray');         % Phase coordinates
p.SetFunction = {@localSet 'X'};                % Map phase to x-axis
p.GetFunction = {@localGet 'X'};
p = schema.prop(c,'PhaseUnits','string');       % Phase units
p.SetFunction = {@localSetUnits 'X'};           % Map phase to x-axis
p.GetFunction = {@localGetUnits 'X'};
p.FactoryValue = 'deg';
p = schema.prop(c,'OLGain','mxArray');          % Gain coordinates
p.SetFunction = {@localSet 'Y'};                % Map gain to y-axis
p.GetFunction = {@localGet 'Y'};
p = schema.prop(c,'MagnitudeUnits','string');   % Gain units
p.SetFunction = {@localSetUnits 'Y'};           % Map gain to y-axis
p.GetFunction = {@localGetUnits 'Y'};
p.FactoryValue = 'dB';

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