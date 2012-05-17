function ck = gfprimck(a, p)
%GFPRIMCK Check whether a polynomial over a Galois field is primitive.
%   CK = GFPRIMCK(A) checks whether the degree-M GF(2) polynomial A is
%   a primitive polynomial for GF(2^M), where M = length(A)-1.  The
%   output CK is as follows:
%       CK = -1   A is not an irreducible polynomial;
%       CK =  0   A is irreducible but not a primitive polynomial;
%       CK =  1   A is a primitive polynomial.
%
%   CK = GFPRIMCK(A, P) checks whether the degree-M GF(P) polynomial
%   A is a primitive polynomial for GF(P^M).  P is a prime number.
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also use the ISPRIMITIVE function.
%
%   The row vector A represents a polynomial by listing its coefficients
%   in order of ascending exponents.
%   Example:  In GF(5), A = [4 3 0 2] represents 4 + 3x + 2x^3.
%
%   See also GFPRIMFD, GFPRIMDF, GFTUPLE, GFMINPOL, GFADD.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.14.4.5 $   $Date: 2007/08/03 21:17:40 $

% Error checking.
error(nargchk(1,2,nargin,'struct'));

% Error checking - P.
if nargin < 2
    p = 2;
elseif (  numel(p)~=1 || isempty(p) || ~isreal(p) || p<=1 || floor(p)~=p ||~isprime(p) )
    error('comm:gfprimck:InvalidP','The field parameter P must be a positive prime integer.');
end

% Error checking - A.
if ( isempty(a) || ndims(a)>2 || any(any( abs(a)~=a | floor(a)~=a | a>=p )) )
    if (p == 2)
        error('comm:gfprimck:InvalidAForP2','Polynomial coefficients must be either 0 or 1 for P=2.');
    else
        error('comm:gflineq:InvalidAElements','Polynomial coefficients must be real integers between 0 and P-1.');
    end
end
[m_a, n_a] = size(a);
if ( m_a>1 && n_a==1 )
    error('comm:gflineq:ANotRowVector','Polynomial input must be represented as a row vector.');
end

% Allocate space for the result, assume primitive.
ck = ones(m_a,1);

% Each row is interpreted as a separate polynomial.  Cycle through each row.
for k = 1:m_a,

    % First remove high-order zeros.
    at = gftrunc(a(k,:));
    m = length(at) - 1;

    % The polynomial is divisible by x, hence is reducible.
    % The only exception is when the polynomial is x ...
    if (at(1,1) == 0)
        if numel(at)==2
            ck(k) = 0;
        else
            ck(k) = -1;
        end
            

        % This polynomial is actually a constant.
    elseif ( m == 0 )
        ck(k) = 1;

        % The typical case.
    else

        % First test if the current polynomial is irreducible.
        n = p^(floor(m/2)+1)-1;
        % 'test_dec' is a vector containing the decimal(scalar) representations of
        % the polynomials that could be divisors of 'at'.
        test_dec = p+1:n;
        % test_dec's that correspond to polynomials divisible by X can be removed.
        test_dec = test_dec( mod(test_dec,p)~=0 );
        len_t = length(test_dec);
        test_poly = zeros(1,m);
        idx = 1;
        % Loop through all polynomials that could be divisors of 'at'.
        while ( idx <= len_t )
            % Expand the scalar value to a polynomial in GF(P).
            tmp = test_dec(idx);
            for idx2 = 1:m
                test_poly(idx2) = rem(tmp,p);
                tmp = floor(tmp/p);
            end
            [ignored, r] = gfdeconv(at,test_poly,p);
            if ( max(r) == 0 )
                ck(k) = -1;
                break;
            end
            idx = idx + 1;
        end

        if ( ck(k) == 1 )
            % If the current polynomial is irreducible then check if it is primitive.
            % To be primitive, the polynomial must not be a factor of another
            % polynomial of the form X^n + 1 for any value of n in the range
            %    m < n <p^m - 1
            % To check for this we check to see if the polynomial divides X^n
            % with a remainder of 1 for all values of n in this range.
            test_ord = m;
            test_poly = [zeros(1,m) 1];
            while ( test_ord < p^m-1 )
                [ignored, r] = gfdeconv(test_poly, at, p); %calculate the remainder
                if (r(1)==1) && (length(r)==1)
                    % If we find a value of n in this range for which the remainder is
                    % 1, we can then conclude the test and declare that the polynomial
                    % is not primitive.
                    ck(k) = 0;
                    break;
                else
                    % To reduce the computational load, on each successive test we
                    % simply need to test against the remainder of the previous test
                    % multiplied by X (i.e., a shifted version of the previous remainder).
                    test_poly = zeros(1,m+1);
                    for idx = 1:length(r)
                        test_poly(idx+1) = r(idx);
                    end
                end;
                test_ord = test_ord + 1;
            end
        end
    end
end

%--end of gfprimck--