function [xdata, ydata] = getanalysisdata(hObj)
%GETDATA Returns the analysis data in cell arrays

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/11/21 15:31:34 $

[xdata, ydata] = getanalysisdata(hObj.CurrentAnalysis);

% [EOF]
