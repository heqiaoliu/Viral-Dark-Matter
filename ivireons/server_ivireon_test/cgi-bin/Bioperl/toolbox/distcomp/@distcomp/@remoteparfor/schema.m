function schema
%SCHEMA defines the distcomp.simpletask class
%

%   Copyright 2007-2009 The MathWorks, Inc.

%   $Revision: 1.1.6.3 $  $Date: 2009/04/15 22:58:31 $


hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'remoteparfor');

schema.prop(hThisClass, 'Session', 'com.mathworks.toolbox.distcomp.pmode.Session');

schema.prop(hThisClass, 'ParforController', 'com.mathworks.toolbox.distcomp.pmode.ParforController');

schema.prop(hThisClass, 'IntervalCompleteQueue', 'java.util.concurrent.BlockingQueue');

schema.prop(hThisClass, 'NumWorkers', 'double');

schema.prop(hThisClass, 'SerializedInitData', 'MATLAB array');

schema.prop(hThisClass, 'ObjectBeingDestroyedListener', 'handle.listener');

p = schema.prop(hThisClass, 'CaughtError', 'bool');
p.AccessFlags.Init = 'on';
p.FactoryValue = false;

schema.method(hThisClass, 'tryRemoteParfor', 'static');