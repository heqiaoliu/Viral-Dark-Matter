function schema
%
% $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:22:19 $

% Copyright 2003-2004 The MathWorks, Inc.

pk = findpackage('stats');

% Create a new class

c = schema.class(pk, 'outlierdb');

schema.prop(c, 'current', 'string');
p=schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
