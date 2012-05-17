function schema

% Defines properties for @pzlocation class

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:36 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzlocation',findclass(pk,'polygonconstr'));

% Editor data
p = schema.prop(c,'Sigma','mxArray');           % sigma coordinates
p.SetFunction = {@localSet 'X'};                % Map time to x-axis
p.GetFunction = {@localGet 'X'};
p = schema.prop(c,'SigmaUnits','string');       % sigma units
p.SetFunction = {@localSetUnits 'X'};           % Map time to x-axis
p.GetFunction = {@localGetUnits 'X'};
p.FactoryValue = 'abs';
p = schema.prop(c,'Omega','mxArray');           % omega coordinates
p.SetFunction = {@localSet 'Y'};                % Map magnitude to y-axis
p.GetFunction = {@localGet 'Y'};
p = schema.prop(c,'OmegaUnits','string');       % omega units
p.SetFunction = {@localSetUnits 'Y'};           % Map time to y-axis
p.GetFunction = {@localGetUnits 'Y'}; 
p.FactoryValue = 'abs';

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
