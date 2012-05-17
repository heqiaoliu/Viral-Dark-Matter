function [a,b,c,d,e,eStored] = getABCDE(D)
% Returns A,B,C,D,E matrices of zero-order Pade approximation.
% These matrices are computing by setting all internal delays 
% to zero. The E matrix is always of the same size as A, and 
% EE is equal to DSS.e.
%
% GETABCD errors if the zero-order Pade approximation has (exactly) 
% singular algebraic loops. This operation may also result in an 
% ill-conditioned realization so don't use this function for
% critical computations when internal delays may be present. Instead,
% use PADE to zero out the delays and work with the resulting model.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:04 $

% Zero internal delays (may error)
% NOTE: Must be order preserving to avoid puzzling results
D = zeroInternalDelay(D);

% Read data
a = D.a;
d = D.d;
b = D.b;
c = D.c;
eStored = D.e;
if isempty(eStored)
   e = eye(size(a));
else 
   e = eStored;
end
 
