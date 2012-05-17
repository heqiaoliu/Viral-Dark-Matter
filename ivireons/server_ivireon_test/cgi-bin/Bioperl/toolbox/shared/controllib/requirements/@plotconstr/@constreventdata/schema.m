function schema

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:37 $

% Construct class
cEventData = findclass(findpackage('handle'),'EventData');
c = schema.class(findpackage('plotconstr'), 'constreventdata',cEventData);

p = schema.prop(c, 'Data', 'MATLAB array');                       
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.PublicGet = 'on';




