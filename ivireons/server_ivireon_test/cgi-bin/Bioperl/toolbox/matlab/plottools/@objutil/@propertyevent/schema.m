function schema

% Copyright 2007-2009 The MathWorks, Inc.

hPk = findpackage('objutil');
cls = schema.class(hPk,'propertyevent');

schema.prop(cls,'Type','string');
% The following 2 properties must be typed to MATLAB array since they
% may contain either UDD or MCOS listeners during the hg2 migration.
schema.prop(cls,'Source','MATLAB array');
schema.prop(cls,'AffectedObject','MATLAB array');
schema.prop(cls,'NewValue','MATLAB array');