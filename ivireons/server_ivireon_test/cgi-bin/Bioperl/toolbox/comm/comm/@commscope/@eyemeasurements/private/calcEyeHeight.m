function calcEyeHeight(this)
%CALCEYEHEIGHT Calculate the eye height
%   Eye height is the three sigma vertical eye opening.  It is defined as the
%   vertical distance between two amplitude levels that are three standard
%   deviations from the mean eye level towards the center of the eye. 

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:49:05 $

% Calculate (mean2-3*std2)-(mean1+3*std1)
std3 = 3*(this.PrivEyeLevelStd(:, 1:end-1) + this.PrivEyeLevelStd(:, 2:end));

% Calculate 3*std points
eyeLevel = this.EyeLevel;
privEyeHeight(:,:,1) = eyeLevel + 3*this.PrivEyeLevelStd;
privEyeHeight(:,:,2) = eyeLevel - 3*this.PrivEyeLevelStd;
this.PrivEyeHeight = privEyeHeight;

% Calculate eye height
this.EyeHeight = diff(eyeLevel, [], 2) - std3;

%-------------------------------------------------------------------------------
% [EOF]
