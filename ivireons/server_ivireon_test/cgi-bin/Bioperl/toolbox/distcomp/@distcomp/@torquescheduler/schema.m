function schema
% SCHEMA for distcomp.pbsproscheduler

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:51:18 $

hThisPackage = findpackage('distcomp');
hParentClass = hThisPackage.findclass('pbsscheduler');
schema.class(hThisPackage, 'torquescheduler', hParentClass);
