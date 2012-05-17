function y=nndef(x,d)
%NNDEF Replace missing and NaN values with defaults.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.

nnerr.obs_fcn('trainwb','Use TRAINB to train your network.')


% NNDEF(X,D)
%   X - Row vector of proposed values.
%   D - Row vector of default values.
% Returns X with all non-finite and missing values with
%   the corresponding values in D.
%
% EXAMPLE: x = [1 2 NaN 4 5];
%          d = [10 20 30 40 50 60];
%          y = nndef(x,d)

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.14.4.5 $  $Date: 2010/03/22 04:08:05 $

y = d;
i = find(isfinite(x(1:min(length(x),length(y)))));
y(i) = x(i);
