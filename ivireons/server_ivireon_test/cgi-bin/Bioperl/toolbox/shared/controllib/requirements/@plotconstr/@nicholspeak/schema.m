function schema
%SCHEMA  Defines properties for @nicholspeak constraint class

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:29 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk, 'nicholspeak', findclass(pk, 'designconstr'));

% Editor data
p = schema.prop(c, 'MagnitudeUnits', 'string'); % Magnitude units
p.FactoryValue = 'dB';
p.SetFunction = {@localSet 'MagnitudeUnits'};      % Map frequency to x-axis
p.GetFunction = {@localGet 'MagnitudeUnits'};

p = schema.prop(c, 'PeakGain',  'mxArray');      % Peak gain (in dB)
p.SetFunction = {@localSet 'PeakGain'};          % Map frequency to x-axis
p.GetFunction = {@localGet 'PeakGain'};

p = schema.prop(c, 'OriginPha', 'mxArray');      % Phase origin (in deg)
p.SetFunction = {@localSet 'OriginPha'};      % Map frequency to x-axis
p.GetFunction = {@localGet 'OriginPha'};

p = schema.prop(c, 'PhaseUnits', 'string');  % Phase units
p.FactoryValue = 'deg';
p.SetFunction = {@localSet 'PhaseUnits'};      % Map frequency to x-axis
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
   case 'originpha'
      fld = 'xCoords';
   case 'phaseunits'
      fld = 'xUnits';
   case 'peakgain'
      fld = 'yCoords';
   case 'magnitudeunits'
      fld = 'yUnits';
end