function [a,e]=lpc(x,N)
%LPC  Linear Predictor Coefficients.
%   A = LPC(X,N) finds the coefficients, A=[ 1 A(2) ... A(N+1) ], of an Nth
%   order forward linear predictor.
%
%      Xp(n) = -A(2)*X(n-1) - A(3)*X(n-2) - ... - A(N+1)*X(n-N)
%
%   such that the sum of the squares of the errors
%
%      err(n) = X(n) - Xp(n)
%
%   is minimized.  X can be a vector or a matrix.  If X is a matrix
%   containing a separate signal in each column, LPC returns a model
%   estimate for each column in the rows of A.  N specifies the order of
%   the polynomial A(z) which must be a positive integer.  N must be less
%   or equal to the length of X.  If X is a matrix, N must be less or equal
%   to the length of each column of X.
%
%   If you do not specify a value for N, LPC uses a default N =
%   length(X)-1.
%
%   [A,E] = LPC(X,N) returns the variance (power) of the prediction error.
%
%   LPC uses the Levinson-Durbin recursion to solve the normal equations
%   that arise from the least-squares formulation.  This computation of the
%   linear prediction coefficients is often referred to as the
%   autocorrelation method.
%
%   See also LEVINSON, ARYULE, PRONY, STMCB.

%   Author(s): T. Krauss, 9-21-93
%   Modified:  T. Bryan 11-14-97
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2009/08/11 15:47:46 $

error(nargchk(1,2,nargin,'struct'))

if isempty(x)
    error(generatemsgid('Empty'),'Input vector X should not be empty');
end

[m,n] = size(x);
if (n>1) && (m==1)
	x = x(:);
	[m,n] = size(x);
end

if nargin < 2,
    N = m-1; 
elseif N < 0,
    % Check for N positive
    error(generatemsgid('negativeOrder'), ...
        'Order of the predictor should be a positive integer.');
end

% Check the input data type. Single precision is not supported.
try
    chkinputdatatype(x,N);
catch ME
    throwAsCaller(ME);
end

if (N > m),
    error(generatemsgid('orderTooLarge'), '%s\n%s\n%s', ...
        'X must be a vector with length greater or equal to the prediction order.', ...
        'If X is a matrix, the length of each column must be greater or equal to', ...
        'the prediction order.');
end

% Compute autocorrelation vector or matrix
X = fft(x,2^nextpow2(2*size(x,1)-1));
R = ifft(abs(X).^2);
R = R./m; % Biased autocorrelation estimate

[a,e] = levinson(R,N);

% Return only real coefficients for the predictor if the input is real
for k = 1:n,
    if isreal(x(:,k))
        a(k,:) = real(a(k,:));
    end
end
