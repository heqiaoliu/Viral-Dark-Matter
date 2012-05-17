function clearresults(h, varargin)
%CLEARRESULTS clear results

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:32 $

ds = h.getdataset;
ds.clearresults(varargin{:});
h.getRoot.firehierarchychanged;
h.updateactions;

% [EOF]
