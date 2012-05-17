function y = maxStepSizeForLinearSliderLength(x)
% Maps maxStepSize value in order to produce an expected active bar length
% within the slider.  Input x ranges from [0,1], which represents the
% desired fractional size of the slider.  Output value is the maxStepSize
% to use with the slider to produce a linear change in its length.
% This is an exponential mapping.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:19 $

% Empirical data for slider:
% Fractional height of active bar in slider
%   x = [0 4/20 1/3 8.5/20 1/2 13.75/20 15.75/20 16.5/20 18/20 19/20 1];
% Value given to minStepSize
%   y = [0 1/4  1/2 3/4 1 2 4 5 10 27 inf];
% These values were determined by setting minStepSize, then measuring the
% slider size in pixels.
%
% The data was fit to an exponential using "cftool",
%      f(x)=a*exp(b*x)+c*exp(d*x)
%
% The values 0 and 1 must be mapped manually.
if x<=0
    y=0;
elseif x>=1
    y=inf;
else
    a = 0.1;
    b = 4.684;
    c = 1e-13;
    d = 34.54;
    y = a*exp(b*x)+c*exp(d*x);
end
