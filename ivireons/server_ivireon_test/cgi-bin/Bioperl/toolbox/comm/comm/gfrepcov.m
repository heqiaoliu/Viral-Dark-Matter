function p2 = gfrepcov(p1)
%GFREPCOV Convert one binary polynomial representation to another.
%   Q = GFREPCOV(P) converts an alternative format for representing a binary
%   polynomial into the more standard ascending-order format.  P is a vector
%   that represents a binary polynomial by listing the exponents that have
%   nonzero coefficients.  Elements of P must be nonnegative integers.  Q is a
%   vector that lists the coefficients in order of ascending exponents.  Each
%   element of Q is either 0 or 1.
% 
%   For example, GFREPCOV([0 3 4]) returns the vector [1 0 0 1 1], where both
%   the input and output vectors represent the polynomial 1 + x^3 + x^4. 
%
%   See also GFPRETTY.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $   $Date: 2007/08/03 21:17:44 $                

% Error checking.
error(nargchk(1,1,nargin,'struct'));

[m n] = size(p1);

% Error checking - P1. 
if ( isempty(p1) || ndims(p1)>2 || m>1 )
    error('comm:gfrepcov:InvalidP','Polynomial must be represented as a row vector.');
elseif ( any( floor(p1)~=p1 | abs(p1)~=p1 ) )
    error('comm:gfrepcov:InvalidElementsInP','Entries in polynomial input must be real positive integers.');
end

% Only perform the conversion if the input is NOT a binary vector.
if max(p1) > 1

    % Error checking - P1. 
    if ( any(any( ( ones(n,1)*p1 == p1'*ones(1,n) ) ~= eye(n) )) )
        error('comm:gfrepcov:SameElementsInP','All entries in polynomial input must be unique.');
    end

    % Allocate space for the result.
    p2 = zeros(1,max(p1)+1);

    % The actual conversion.
    p2(p1+1) = 1;

else
    
    p2 = p1;
    
end

%--end of GFREPCOV--

