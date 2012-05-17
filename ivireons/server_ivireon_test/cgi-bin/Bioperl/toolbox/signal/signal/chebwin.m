function w = chebwin(n_est, r)
%CHEBWIN Chebyshev window.
%   CHEBWIN(N) returns an N-point Chebyshev window in a column vector.
% 
%   CHEBWIN(N,R) returns the N-point Chebyshev window with R decibels of
%   relative sidelobe attenuation. If omitted, R is set to 100 decibels.
%
%   See also TAYLORWIN, GAUSSWIN, KAISER, TUKEYWIN, WINDOW.

%   Author: James Montanaro
%   Reference: E. Brigham, "The Fast Fourier Transform and its Applications" 

%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.19.4.4 $  $Date: 2007/12/14 15:04:02 $

error(nargchk(1,2,nargin,'struct'));

% Default value for R parameter.
if nargin < 2 || isempty(r), 
    r = 100.0;
end

[n,w,trivialwin] = check_order(n_est);
if trivialwin, return, end;

if r < 0,
    error(generatemsgid('MustBePositive'),'Attenuation must be specified as a positive number.');
end

w = chebwinx(n,r);


% [EOF] chebwin.m
