function R=poly2ac(a,efinal)
%POLY2AC  Convert prediction polynomial to autocorrelation sequence.
%   R=POLY2AC(A,Efinal) returns the autocorrelation sequence, R, based on
%   the prediction polynomial, A, and the final prediction error, Efinal. 
%
%   If A(1) is not equal to 1, POLY2AC normalizes the prediction
%   polynomial by A(1).
%
%   See also AC2POLY, POLY2RC, RC2POLY, RC2AC, AC2RC.

%   References: S. Kay, Modern Spectral Estimation,
%               Prentice Hall, N.J., 1987, Chapter 6.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2006/11/19 21:44:08 $

if (size(a,1) > 1) && (size(a,2) > 1)
    error(generatemsgid('inputnotsupported'),'The prediction polynomial must be stored in a vector.');
end

R = rlevinson(a,efinal);

% [EOF] poly2ac.m
