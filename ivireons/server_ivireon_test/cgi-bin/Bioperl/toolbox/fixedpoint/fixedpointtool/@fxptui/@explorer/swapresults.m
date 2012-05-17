function swapresults(h)
%SWAPRESULTS swap Active and Reference results 

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:55 $

ds = h.getdataset;
if(isempty(ds))
  return;
end
h.sleep;
ds.swap;
h.getRoot.firehierarchychanged;
h.updatedata;
h.updateactions;
h.wake;
% [EOF]
