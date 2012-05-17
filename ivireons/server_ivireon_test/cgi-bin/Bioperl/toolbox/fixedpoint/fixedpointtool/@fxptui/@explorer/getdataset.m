function [dataset, run] = getdataset(h)
%GETDATASET Get the dataset.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/15 22:50:35 $

mdlname = h.getRoot.daobject.getFullName;
autoscalesupport = SimulinkFixedPoint.getApplicationData(mdlname);
dataset = autoscalesupport.dataset;
run = autoscalesupport.ResultsLocation;

% [EOF]