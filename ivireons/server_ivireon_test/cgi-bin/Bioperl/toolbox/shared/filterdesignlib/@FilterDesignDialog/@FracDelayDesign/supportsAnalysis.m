function b = supportsAnalysis(this)
%SUPPORTSANALYSIS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/06/13 15:28:20 $

% Only support analysis of frac delay from MATLAB, not simulink.  We do not
% have the fractional delay in simulink yet.
b = strcmp(this.OperatingMode, 'MATLAB');

% [EOF]
