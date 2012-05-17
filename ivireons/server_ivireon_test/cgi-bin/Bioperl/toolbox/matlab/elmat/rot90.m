function B = rot90(A,k)
%ROT90  Rotate matrix 90 degrees.
%   ROT90(A) is the 90 degree counterclockwise rotation of matrix A.
%   ROT90(A,K) is the K*90 degree rotation of A, K = +-1,+-2,...
%
%   Example,
%       A = [1 2 3      B = rot90(A) = [ 3 6
%            4 5 6 ]                     2 5
%                                        1 4 ]
%
%   Class support for input A:
%      float: double, single
%
%   See also FLIPUD, FLIPLR, FLIPDIM.

%   Thanks to John de Pillis
%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.11.4.4 $  $Date: 2010/03/08 21:40:58 $

if ~ismatrix(A)
    error('MATLAB:rot90:SizeA', 'A must be a 2-D matrix.');
end
if nargin == 1
    k = 1;
else
    if ~isscalar(k)
        error('MATLAB:rot90:kNonScalar', 'k must be a scalar.');
    end
    k = rem(k,4);
    if k < 0
        k = k + 4;
    end
end
if k == 1
    B = A(:,end:-1:1);
    B = B.';
elseif k == 2
    B = A(end:-1:1,end:-1:1);
elseif k == 3
    B = A.';
    B = B(:,end:-1:1);
else
    B = A;
end
