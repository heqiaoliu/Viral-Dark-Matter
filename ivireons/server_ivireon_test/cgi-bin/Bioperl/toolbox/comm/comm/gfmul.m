function c = gfmul(a, b, p)
%GFMUL Multiply elements of a Galois field.
%   C = GFMUL(A, B) multiplies A by B in GF(2) element-by-element.  A and B
%   are scalars, vectors or matrices of the same size.  Each entry in A and B
%   represents an element of GF(2).  The entries of A and B are either 0 or 1.
%
%   C = GFMUL(A, B, P) multiplies A by B in GF(P) element-by-element, where
%   P is a prime number scalar.  Each entry in A and B represents an element 
%   of GF(P).  The entries of A and B are integers between 0 and P-1.
%
%   C = GFMUL(A, B, FIELD) multiplies A by B in GF(P^M) element-by-element
%   where P is a prime number and M is a positive integer.  Each entry in A 
%   and B represents an element of GF(P^M) in exponential format.  The entries
%   of A and B are integers between -Inf and P^M-2.  FIELD is a matrix listing
%   all the elements in GF(P^M), arranged relative to the same primitive
%   element.  FIELD can be generated using FIELD = GFTUPLE([-1:P^M-2]', M, P);
%
%   For polynomial multiplication in GF(P) or GF(P^M), use GFCONV.
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also apply the .* operator to Galois arrays.
%
%   See also GFDIV, GFDECONV, GFADD, GFSUB, GFTUPLE.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $   $Date: 2007/02/18 01:28:53 $
