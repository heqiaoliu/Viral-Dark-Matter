function [q, r] = gfdeconv(b, a, p)
%GFDECONV Divide polynomials over a Galois field.
%   [Q, R] = GFDECONV(B, A) computes the quotient Q and remainder R of the
%   division of B by A in GF(2).
%
%   A, B, Q and R are row vectors that specify the polynomial coefficients in
%   order of ascending powers.
%
%   [Q, R] = GFDECONV(B, A, P) computes the quotient Q and remainder R of the
%   division of B by A in GF(P), where P is a scalar prime number.
%
%   [Q, R] = GFDECONV(B, A, FIELD) computes the quotient Q and remainder R of
%   the division between two GF(P^M) polynomials, where FIELD is a matrix
%   that contains the M-tuple of all elements in GF(P^M).  P is a prime number
%   and M is a positive integer.  To generate the M-tuple of all elements
%   in GF(P^M), use FIELD = GFTUPLE([-1:P^M-2]', M, P).
%
%   In this syntax, each coefficient is specified in exponential format,
%   that is, [-Inf, 0, 1, 2, ...] represent the field elements
%   [0, 1, alpha, alpha^2, ...] in GF(P^M).
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also use the DECONV function with Galois arrays.
%
%   Example 1:
%       % In GF(5): (1+ 3x+ 2x^3+ 4x^4)/(1+ x) = (1+ 2x+ 3x^2+ 4x^3)
%       [q, r] = gfdeconv([1 3 0 2 4], [1 1], 5)
%
%   Example 2:
%       % In GF(2^4):
%       field = gftuple([-1:2^4-2]', 4, 2);
%       [q, r] = gfdeconv([2 6 7 8 9 6],[1 1],field)
%
%   See also GFCONV, GFADD, GFSUB, GFTUPLE, GFDIV.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.4 $Date: 2008/08/01 12:17:36 $