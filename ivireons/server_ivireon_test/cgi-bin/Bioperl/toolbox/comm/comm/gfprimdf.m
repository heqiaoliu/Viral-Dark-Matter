function pol = gfprimdf(m, p)
%GFPRIMDF Provide default primitive polynomials for a Galois field.
%   POL = GFPRIMDF(M) outputs the default primitive polynomial POL in
%   GF(2^M). 
%
%   POL = GFPRIMDF(M, P) outputs the default primitive polynomial POL
%   in GF(P^M).
%
%   Note: This function performs computations in GF(P^M) where P is prime. To
%   work in GF(2^M), you can also use the PRIMPOLY function.
%
%   The default primitive polynomials are monic polynomials.
%
%   See also GFPRIMCK, GFPRIMFD, GFTUPLE, GFMINPOL.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $   $Date: 2009/03/30 23:24:09 $

% Error checking.
error(nargchk(1,2,nargin,'struct'));

% Error checking - M.
if ( numel(m)~=1 || isempty(m) || ~isreal(m) || m<1 || floor(m)~=m )
    error('comm:gfprimdf:InvalidM','M must be a real positive scalar.');
end

% Error checking - P.
if nargin < 2
   p = 2;
elseif ( isempty(p) || ~isreal(p) || p<2 || floor(p)~=p || numel(p)~=1 || ~isprime(p) )
    error('comm:gfprimdf:InvalidP','The field parameter P must be a positive prime integer.');
end

% The polynomials that are stored in the database over GF(2).
if ( (p == 2) && (m <= 26) )
    switch m
        case 1
            pol = [1 1];
        case 2
            pol = [1 1 1];
        case 3
            pol = [1 1 0 1];
        case 4
            pol = [1 1 0 0 1];
        case 5
            pol = [1 0 1 0 0 1];
        case 6
            pol = [1 1 0 0 0 0 1];
        case 7
            pol = [1 0 0 1 0 0 0 1];
        case 8
            pol = [1 0 1 1 1 0 0 0 1];
        case 9
            pol = [1 0 0 0 1 0 0 0 0 1];
        case 10
            pol = [1 0 0 1 0 0 0 0 0 0 1];
        case 11
            pol = [1 0 1 0 0 0 0 0 0 0 0 1];
        case 12
            pol = [1 1 0 0 1 0 1 0 0 0 0 0 1];
        case 13
            pol = [1 1 0 1 1 0 0 0 0 0 0 0 0 1];
        case 14
            pol = [1 1 0 0 0 0 1 0 0 0 1 0 0 0 1];
        case 15
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 16
            pol = [1 1 0 1 0 0 0 0 0 0 0 0 1 0 0 0 1];
        case 17
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 18
            pol = [1 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1];
        case 19
            pol = [1 1 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 20
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 21
            pol = [1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 22
            pol = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 23
            pol = [1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 24
            pol = [1 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 25
            pol = [1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
        case 26
            pol = [1 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
    end

% The polynomials that are stored in the database over GF(3).
elseif (p == 3) && (m <= 12)
    switch m
        case 1
            pol = [1 1];
        case 2
            pol = [2 1 1];
        case 3
            pol = [1 2 0 1];
        case 4
            pol = [2 1 0 0 1];
        case 5
            pol = [1 2 0 0 0 1];
        case 6
            pol = [2 1 0 0 0 0 1];
        case 7
            pol = [1 0 2 0 0 0 0 1];
        case 8
            pol = [2 0 0 1 0 0 0 0 1];
        case 9
            pol = [1 0 0 0 2 0 0 0 0 1];
        case 10
            pol = [2 1 0 1 0 0 0 0 0 0 1];
        case 11
            pol = [1 0 2 0 0 0 0 0 0 0 0 1];
        case 12
            pol = [2 1 0 0 0 1 0 0 0 0 0 0 1];
    end


% The polynomials that are stored in the database over GF(5).
elseif (p == 5) && (m <= 9)
    switch m
        case 1
            pol = [2 1];
        case 2
            pol = [2 1 1];
        case 3
            pol = [2 3 0 1];
        case 4
            pol = [2 2 1 0 1];
        case 5
            pol = [2 4 0 0 0 1];
        case 6
            pol = [2 1 0 0 0 0 1];
        case 7
            pol = [2 3 0 0 0 0 0 1];
        case 8
            pol = [3 2 1 0 0 0 0 0 1];
        case 9
            pol = [3 0 0 0 2 0 0 0 0 1];
    end

% The polynomials that are stored in the database over GF(7).
elseif (p == 7) && (m <= 7)
    switch m
        case 1
            pol = [2 1];
        case 2
            pol = [3 1 1];
        case 3
            pol = [2 3 0 1];
        case 4
            pol = [5 3 1 0 1];
        case 5
            pol = [4 1 0 0 0 1];
        case 6
            pol = [5 1 3 0 0 0 1];
        case 7
            pol = [2 6 0 0 0 0 0 1];
    end

elseif (p == 11) && (m <= 5)
    switch m
        case 1
            pol = [3 1];
        case 2
            pol = [7 1 1];
        case 3
            pol = [4 1 0 1];
        case 4
            pol = [2 1 0 0 1];
        case 5
            pol = [9 0 2 0 0 1];
    end

elseif (p == 13) && (m <= 5)
    switch m
        case 1
            pol = [2 1];
        case 2
            pol = [2 1 1];
        case 3
            pol = [6 1 0 1];
        case 4
            pol = [2 1 1 0 1];
        case 5
            pol = [2 4 0 0 0 1];
    end

elseif (p == 17) && (m <= 5)
    switch m
        case 1
            pol = [3 1];
        case 2
            pol = [3 1 1];
        case 3
            pol = [3 1 0 1];
        case 4
            pol = [11 1 0 0 1];
        case 5
            pol = [3 1 0 0 0 1];
    end

else
    % Call GFPRIMFD for polynomials that are not stored in the database over GF(P>2).
    warning(generatemsgid('OutsideDatabase'),...
        ['You have requested a polynomial of degree %d over GF(%d). ',...
        'This polynomial is outside the range of values stored in GFPRIMDF. ', ...
        'GFPRIMFD is being called to compute the primitive polynomial.'], m, p);
    pol = gfprimfd(m,'min',p);
end

% -- end of gfprimdf--
