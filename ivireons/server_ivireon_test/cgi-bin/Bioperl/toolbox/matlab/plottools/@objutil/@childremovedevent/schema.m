function schema

% Copyright 2007 The MathWorks, Inc.

hPk = findpackage('objutil');
cls = schema.class(hPk,'childremovedevent');

schema.prop(cls,'Type','string');
schema.prop(cls,'Source','MATLAB array');
schema.prop(cls,'Child','MATLAB array');