function schema
% Defines properties for @pzdamping class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:33:13 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'pzdamping',findclass(pk,'designconstr'));

% Editor data
p = schema.prop(c,'Format','string');     % [damping|overshoot]
set(p,'AccessFlags.Init','on','FactoryValue','damping');
p = schema.prop(c,'Damping','mxArray');   % Specified damping (in [0,1])
p.SetFunction = {@localSet 'Damping'};    % Map frequency to x-axis
p.GetFunction = {@localGet 'Damping'};
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
   case 'damping'
      fld = 'xCoords';
end
