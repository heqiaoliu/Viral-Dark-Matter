function schema
% Defines properties for @pzfrequency class
%      Natural frequency constraint in pole/zero plots

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:28 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzfrequency',findclass(pk,'designconstr'));

% Editor data
p = schema.prop(c,'Frequency','mxArray');     % Specified natural frequency (rad/sec)
p.SetFunction = {@localSet 'Frequency'};      % Map frequency to x-axis
p.GetFunction = {@localGet 'Frequency'};
p = schema.prop(c,'FrequencyUnits','String'); % Frequency units currently in use
p.SetFunction = {@localSet 'FrequencyUnits'}; % Map frequency to x-axis
p.GetFunction = {@localGet 'FrequencyUnits'};
schema.prop(c,'Ts','double');                 % Current sampling time

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
   case 'frequency'
      fld = 'xCoords';
   case 'frequencyunits'
      fld = 'xUnits';
end