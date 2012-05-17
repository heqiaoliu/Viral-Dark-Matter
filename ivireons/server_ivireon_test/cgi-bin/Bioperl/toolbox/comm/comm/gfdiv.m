function quot = gfdiv(b, a, field)
%GFDIV Divide elements of a Galois field.
%   Q = GFDIV(B, A) divides B by A in GF(2) element-by-element.  A and B are
%   scalars, vectors or matrices of the same size.  Each entry in A and B
%   represents an element of GF(2).  The entries of A and B are either 0 or 1.
%
%   Q = GFDIV(B, A, P) divides B by A in GF(P) element-by-element, where P is
%   a prime number.  Each entry in A and B represents an element of GF(P).
%   The entries of A and B are integers between 0 and P-1.
%
%   Q = GFDIV(B, A, FIELD) divides B by A in GF(P^M) element-by-element where
%   P is a prime number and M is a positive integer.  Each entry in A and B 
%   represents an element of GF(P^M) in exponential format.  The entries of A
%   and B are integers between -Inf and P^M-2.  FIELD is a matrix listing all
%   the elements in GF(P^M), arranged relative to the same primitive element.
%   FIELD can be generated using FIELD = GFTUPLE([-1:P^M-2]', M, P);
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also apply the ./ operator to Galois arrays.
%
%   For polynomial division in GF(P) or GF(P^M), use GFDECONV.
%   See also GFMUL, GFCONV, GFTUPLE.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.15.4.7 $   $Date: 2007/10/05 18:33:05 $

% Error checking.
error(nargchk(2,3,nargin,'struct'));

% Default field.
if nargin < 3
    field = 2;
end

[m_a, n_a] = size(a);
[m_b, n_b] = size(b);
[m_field, n_field] = size(field);

% Error checking - A & B.
if ( (m_a ~= m_b) || (n_a ~= n_b) )
    error('comm:gfdiv:InvalidInputSize','Inputs must have the same size and orientation.');
end

% Error checking - A & B.
if ( isempty(a) || isempty(b) || any(any( a~=floor(a) | real(a)~=a | b~=floor(b) | real(b)~=b )) )
    error('comm:gfdiv:InvalidInputElements','Input elements must be real integers.')
end


if m_field*n_field == 1
    % Division over a prime field.
    p = field;

    % Error checking - P.    
    if ( isempty(p) || ~isreal(p) || p<=1 || numel(p)~=1 || floor(p)~=p || ~isprime(p) )
        error('comm:gfdiv:InvalidP','The field parameter P must be a positive prime integer.')
    end
    
    % Error checking - A & B.
    if ( ndims(a)>2 || ndims(b)>2 )
        error('comm:gfdiv:InvalidInputDims','Inputs must not have more than two dimensions.');
    end
    if any(any( a<0 | b<0 | a>=p | b>=p ))
        if ( p == 2 )
            error('comm:gfdiv:InvalidInputElements','Input elements must be either 0 or 1 for division over GF(2).')
        else
            error('comm:gfdiv:InvalidInputElements','Input elements must be between 0 and P-1 for division over a prime field.')
        end            
    end

    % Find the multiplicative inverse of the elements in A.
    [field_inv ignored] = find( mod( (1:(p-1)).' * (1:(p-1)) , p ) == 1 );  %#ok
    field_inv = [0; field_inv];
    a_inv = field_inv(a+1);
    a_inv = reshape(a_inv,m_a,n_a);

    % The actual division.
    quot = mod(b .* a_inv, p);

    % Assign NaN to the special case of x/0
    quot(a==0) = NaN;

else
    % Division over an extension field.

    % Error checking - FIELD.    
    if ( ndims(a)>2 || ndims(b)>2 || ndims(field)>2 )
        error('comm:gfdiv:InvalidInputDims','Inputs must not have more than two dimensions.');
    end
    if ( isempty(field) || ndims(field)>2 || any(any( floor(field)~=field | abs(field)~=field )) )
        error('comm:gfdiv:InvalidFieldParameterVal','Field parameter values must be real nonnegative integers.')
    end

    % Determine the characteristic of this field.
    p = max(max(field)) + 1;
    m = round( log(m_field)/log(p) );
    q = p^m;

    % Error checking - FIELD.    
    if ( ~isprime(p) || (m_field ~= q) || (n_field ~= m) )
        error('comm:gfdiv:InvalidFieldParameter','Field parameter is not valid. See GFTUPLE.');
    end

    % More thorough error checking of FIELD matrix.
    if ~( ( m == 1 ) && ( p == 2 ) )
        alpha_m = field(m+2,:);
    else
        alpha_m = 1;
    end
    prim_poly = [ mod( -1*alpha_m , p ) 1];
    % Verify that FIELD is derived from a valid primitive polynomial.
    if gfprimck(prim_poly,p) ~= 1
        error('comm:gfdiv:InvalidFieldParameterVal','Field parameter is not valid. See GFTUPLE.');
    end
    % Verify that top row is all zero and next m rows form an identity matrix.
    if ( sum( field(1,:) ~= 0 ) || sum(sum( field(2:m+1,:) ~= eye(m) )) )
        error('comm:gfdiv:InvalidFieldParameterVal','Field parameter is not valid. See GFTUPLE.');
    end
    % Verify that all subsequent rows are formed from the primitive polynomial and the previous row.
    if ( p>2 || m>1 )
        should_be = mod( field(m+2:q-1,m)*field(m+2,:) + [zeros(q-m-2,1) field(m+2:q-1,1:m-1)] , p );
        if any(any( should_be ~= field(m+3:q,:) ))
               error('comm:gfdiv:InvalidFieldParameterVal','Field parameter is not valid. See GFTUPLE.');
        end            
    end
    
    % Error checking - A & B.
    if any(any( ( a > (p^m)-2 ) | ( b > (p^m)-2 ) ))
        error('comm:gfdiv:InvalidInputElements','Input elements must be between -Inf and P^M-2 for division over an extension field.')
    end;
          
    % The actual division.
    quot = mod(b - a, q - 1);

    % Assign special values:  0/x = -Inf (representing zero) and x/0 = NaN.
    quot(b<0) = - Inf;
    quot(a<0) = NaN;
end;
%--end of GFDIV--
