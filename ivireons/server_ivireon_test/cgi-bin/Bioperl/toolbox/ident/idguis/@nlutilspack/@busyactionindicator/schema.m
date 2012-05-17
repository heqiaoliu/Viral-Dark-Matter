function schema
%SCHEMA  Define properties for busyactionindicator class.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:45:48 $

c = schema.class(findpackage('nlutilspack'),'busyactionindicator');

p = schema.prop(c,'Busy','bool');
p.FactoryValue = false;
