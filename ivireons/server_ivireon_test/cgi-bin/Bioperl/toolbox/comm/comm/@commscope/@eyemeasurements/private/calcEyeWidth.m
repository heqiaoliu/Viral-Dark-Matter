function calcEyeWidth(this)
%CALCEYEWIDTH Calculate the eye width
%   Eye width is the three sigma horizontal eye opening.  It is defined as the
%   horizontal distance between two eye crossings that are three standard
%   deviations from the mean crossing times towards the center of the eye. 

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:44 $

% Calculate (mean2-3*std2)-(mean1+3*std1)
std3 = 3*(this.PrivCrossingTimeStd(:, 1:end-1) ...
    + this.PrivCrossingTimeStd(:, 2:end));
this.EyeWidth = diff(this.EyeCrossingTime, [], 2) - std3;

%-------------------------------------------------------------------------------
% [EOF]
