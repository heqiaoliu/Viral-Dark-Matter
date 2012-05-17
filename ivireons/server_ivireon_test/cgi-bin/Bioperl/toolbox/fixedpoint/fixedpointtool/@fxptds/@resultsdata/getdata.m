function d = getdata(h)
%GETDATA gets results stored in resultsdata
%   D = GETDATA(H) returns a struct array with fields ID and Signal
%   containing the path and Simulink.Timeseries for each signal stored in
%   tsdata

%   Author(s): G. Taillefer
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:05 $

d = h.results;

% [EOF]
