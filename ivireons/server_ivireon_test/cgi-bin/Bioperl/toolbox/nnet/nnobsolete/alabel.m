function alabel(x,y,t,z)
%ALABEL Set axis labels and title.
%
% Obsoleted in R2006a NNET 5.0.  Last used in R2005b NNET 4.0.6.
%  
%  This function is obselete.
%  Use XLABEL, YLABEL, TITLE, and AXIS.

nnerr.obs_fcn('alabel','Use XLABEL, YLABEL, TITLE, and AXIS.')

%  
%  *WARNING*: ALABEL is undocumented as it may be altered
%  at any time in the future without warning.

% ALABEL(X,Y,T,Z)
%   X - X axis label (string).
%   Y - Y axis label (string).
%   T - Title of axis (string).
%   Z - Z axis label (string).
% Labels current axis with xlabel X, ylabel Y and title T.
%
% ALABEL may be called with from 0 to 3 arguments.

% Mark Beale, 12-15-93
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.11.4.1 $  $Date: 2010/03/22 04:06:18 $

n = nargin;
if n == 0
  x = 'Wavelength';
  y = 'Decay rate';
  t = 'Foobar Decay Rates';
  n = 3;
end

xlabel(x)
if n >= 2, ylabel(y), end
if n >= 3, title(t), end
if n == 4, zlabel(z), end
