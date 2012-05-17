function genpoly = setGenPoly(h,genpoly)
%SETGENPOLY   Sets the genpoly value of the object.

% @fec\@bchbase

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/05 01:58:19 $

N = h.N;
K = h.K;
%m = log2(N+1); % for now...
m = h.m;
% Check genpoly
if ~commprivate('isgfvector',genpoly)
    error([getErrorId(h), ':genPolyGF'],'The generator polynomial must be a Galois row vector.');
end

if ~isa(genpoly,'gf')
    error([getErrorId(h),':genPolyGfObj'],'The generator polynomial must be a Galois row vector.');
end

if(h.Nset && h.kSet) % only perform these checks if N and K are both set.

    %Check the size of the generator polynomial
    if ~isequal(length(genpoly)-1,N-K)
        error([getErrorId(h) ':genPolyDegree'],'The generator polynomial must be of degree (N-K).');
    end
    
    % Ensure that genpoly has only binary values
    if any(genpoly.*genpoly ~= genpoly) % - covers both double and gf genpoly

        error([getErrorId(h),':genPolyBin'], ['The coefficients of the generator polynomial ' ...
            'must be binary']);
    end

    % Ensure that if genpoly is a gf array, it must be in gf(2)
    if strcmpi(class(genpoly), 'gf')
        if genpoly.m ~= 1
            error([getErrorId(h) ':genPolyGF'],['The BCH Encoder block must use a generator ' ...
                'polynomial defined over GF(2)']);
        end
    end

    % Ensure that the generator polynomial evenly divides x^n+1
    num = [1 zeros(1, 2^m-2) 1];  % x^n+1
    if strcmpi(class(genpoly), 'gf')
        % Extract the value of the genpoly gf object,then use the fast function
        % gfdeconv to perform the division.  Flip the vector, since gfdeconv
        % expects its inputs to have ascending powers.
        den = fliplr(double(genpoly.x));  % gfdeconv requires doubles

    elseif strcmpi(class(genpoly), 'double')
        den = fliplr(genpoly);
    end

    [~, r] = gfdeconv(num, den);  

    if any(r~=0)

        error([getErrorId(h) ':genPolyDiv'], ['The generator polynomial must evenly divide X^n+1, where ' ...
            'n is the length of a full length code']);
    end

    % update the primitive polynomial
    h.PrimPoly = genpoly.prim_poly;
end

if (h.Nset)
    updateTables(h, log2(N+1))    
end
