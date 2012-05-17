function destroy(h,ds)
%DESTROY  cleanup this result and remove it from the dataset

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/13 17:57:06 $

h.listeners = [];
h.deletefigures;
ds.removeblklist4src(h.daobject);
ds.clearresults(h.daobject);

% [EOF]
