function schema
%SCHEMA defines the distcomp.matlabpoollab class

% Copyright 2007 The MathWorks, Inc.

hThisPackage = findpackage('distcomp');
hThisClass   = schema.class(hThisPackage, 'matlabpoollab');

schema.prop( hThisClass, 'NewWorldComms', 'MATLAB array' );
