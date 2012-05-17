function schema
%SCHEMA  Defines properties for @bodepm margin class

%   Author(s): A. Stothert
%   Revised:
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:33 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'bodegpm', findclass(pk, 'annotatedconstr'));

% Editor data
p = schema.prop(c, 'MarginPha', 'mxArray');   % Phase margin (in deg)
p.SetFunction = {@localSet 'MarginPha'};      % Map phase to y-axis
p.GetFunction = {@localGet 'MarginPha'};

p = schema.prop(c, 'PhaseEnabled', 'bool');   % Phase margin enabled
p.FactoryValue = false;

p = schema.prop(c, 'MarginGain', 'mxArray');  % Gain margin (in db)
p.SetFunction = {@localSet 'MarginGain'};     % Map gain to x-axis
p.GetFunction = {@localGet 'marginGain'};

p = schema.prop(c, 'GainEnabled', 'bool');    % Gain margin enabled
p.FactoryValue = false;

p = schema.prop(c, 'MagnitudeUnits', 'string'); % Magnitude units
p.FactoryValue = 'dB';
p.SetFunction = {@localSet 'MagnitudeUnits'};      
p.GetFunction = {@localGet 'MagnitudeUnits'};

p = schema.prop(c, 'PhaseUnits', 'string');   % Phase units
p.FactoryValue = 'deg';
p.SetFunction = {@localSet 'PhaseUnits'};      
p.GetFunction = {@localGet 'PhaseUnits'};

%--------------------------------------------------------------------------
function valueStored = localSet(this, Value, fld)

fld = localFieldMapping(fld);

this.setData(fld,Value);
if ischar(Value)
   valueStored = '';
else
   valueStored = [];
end

%--------------------------------------------------------------------------
function valueReturned = localGet(this, Value, fld)

fld = localFieldMapping(fld);
valueReturned = this.getData(fld);

%--------------------------------------------------------------------------
function fld = localFieldMapping(fld)

switch lower(fld)
   case 'margingain'
      fld = 'xCoords';
   case 'phaseunits'
      fld = 'xUnits';
   case 'marginpha'
      fld = 'yCoords';
   case 'magnitudeunits'
      fld = 'yUnits';
end