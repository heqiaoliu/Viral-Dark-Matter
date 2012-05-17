function destroy(h,ds)
%DESTROY  cleanup this result and remove it from the dataset

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:21 $

h.listeners = [];
h.deletefigures;
ds.clearresults(h);

% [EOF]
