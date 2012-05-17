function H = hankel(c,r)
%HANKEL Hankel matrix.
%   HANKEL(C) is a square Hankel matrix whose first column is C and
%   whose elements are zero below the first anti-diagonal.
%
%   HANKEL(C,R) is a Hankel matrix whose first column is C and whose
%   last row is R.
%
%   Hankel matrices are symmetric, constant across the anti-diagonals,
%   and have elements H(i,j) = P(i+j-1) where P = [C R(2:END)]
%   completely determines the Hankel matrix.
%
%   Class support for inputs C,R:
%      double, single, int8, int16, int32, uint8, uint16, uint32
%
%   See also TOEPLITZ.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2010/02/01 03:13:02 $

c = c(:);
nc = length(c);

if nargin < 2,
   r = zeros(size(c),class(c));   %-- will need zeros below main diagonal
elseif c(nc) ~= r(1)
   warning('MATLAB:hankel:AntiDiagonalConflict',['Last element of ' ...
           'input column does not match first element of input row. ' ...
           '\n         Column wins anti-diagonal conflict.'])
end

r = r(:);                       %-- force column structure
nr = length(r);

x = [ c; r((2:nr)') ];          %-- build vector of user data

cidx = (ones(class(c)):nc)';
ridx = zeros(class(r)):(nr-1);
H = cidx(:,ones(nr,1)) + ridx(ones(nc,1),:);  % Hankel subscripts
H(:) = x(H);                            % actual data

