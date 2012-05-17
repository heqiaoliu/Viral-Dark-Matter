function schema
% SCHEMA for distcomp.pbsproscheduler

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:48 $

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('pbsscheduler');
schema.class(hThisPackage, 'pbsproscheduler', hParentClass);
