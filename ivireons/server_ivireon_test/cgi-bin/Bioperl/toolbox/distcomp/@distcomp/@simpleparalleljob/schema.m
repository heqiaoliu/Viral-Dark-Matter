function schema
%SCHEMA defines the distcomp.paralleljob class
%

%   Copyright 2005 The MathWorks, Inc.

%   $Revision: 1.1.10.2 $  $Date: 2007/06/18 22:13:57 $


hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('abstractjob');
hThisClass   = schema.class(hThisPackage, 'simpleparalleljob', hParentClass);

p = schema.prop(hThisClass, 'MaximumNumberOfWorkers', 'double');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetMaximumNumberOfWorkers;
p.GetFunction = @pGetMaximumNumberOfWorkers;
p.FactoryValue = Inf;

p = schema.prop(hThisClass, 'MinimumNumberOfWorkers', 'double');
p.AccessFlags.AbortSet  = 'off';
p.SetFunction = @pSetMinimumNumberOfWorkers;
p.GetFunction = @pGetMinimumNumberOfWorkers;
p.FactoryValue = 0;
