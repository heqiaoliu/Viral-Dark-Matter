function schema
% Defines properties for @pzsettling class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:49 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzsettling',findclass(pk,'designconstr'));

% Editor data
p = schema.prop(c,'SettlingTime','mxArray');   % Specified settling time
p.SetFunction = {@localSet 'SettlingTime'};    % Map frequency to x-axis
p.GetFunction = {@localGet 'SettlingTime'};
schema.prop(c,'Ts','double');             % Current sampling time

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
   case 'settlingtime'
      fld = 'xCoords';
end