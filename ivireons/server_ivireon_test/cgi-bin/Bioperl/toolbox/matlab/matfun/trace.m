function t = trace(A)
%TRACE  Sum of diagonal elements.
%   TRACE(A) is the sum of the diagonal elements of A, which is
%   also the sum of the eigenvalues of A.
%
%   Class support for input A:
%      float: double, single

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.8.4.4 $  $Date: 2010/04/21 21:32:27 $

if ~ismatrix(A) || size(A,1)~=size(A,2)
  error('MATLAB:square','Matrix must be square.');
end
t = full(sum(diag(A)));
