function results = getresults(h,varargin)
%GETRESULTS

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:36 $

ds = h.getdataset;
results = ds.getresults(varargin{:});

% [EOF]