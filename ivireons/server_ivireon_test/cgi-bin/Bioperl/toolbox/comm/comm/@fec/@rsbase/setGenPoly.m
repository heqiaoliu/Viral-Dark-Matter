function genpoly = setGenPoly(h,genpoly)
%SETGENPOLY   Sets the GenPoly value of the object.

% @fec\rsenc

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:46:28 $

N = h.N;
K = h.K;

% Check GENPOLY

if ~(isa(genpoly,'gf'))
    error([getErrorId(h) ':genPolyGF'],'The generator polynomial must be a Galois row vector.');
end
if ~commprivate('isgfvector',genpoly)
    error([getErrorId(h) ':genPolyVec'],'The generator polynomial must be a Galois row vector.');
end

if(h.Nset && h.kSet) % only perform these checks if N and K are both set.
    if ~isequal(length(genpoly)-1,N-K)
        error([getErrorId(h) ':genPolyDegee'],'The generator polynomial must be of degree (N-K).');
    end

    [b bEcode] = genpoly2b(genpoly(:)', genpoly.m, genpoly.prim_poly);
    if bEcode
        if isequal(bEcode,2)
            error([getErrorId(h) ':genPolyMonic'],'The generator polynomial must be monic.')

        elseif isequal(bEcode, 3)
            error([getErrorId(h),':genPolyNonZero'],'The generator polynomial must not contain any zeros');

        else
            error( [getErrorId(h) ':genPolyProd'], ['The generator polynomial must be the product\n'...
                '(X+alpha^b)*(X+alpha^(b+1))*...*(X+alpha^(b+N-K-1)), where b is an integer.'])
        end
    end
    % update the primitive polynomial
    h.PrimPoly = genpoly.prim_poly;
end

[GF_TABLE1 GF_TABLE2] = populateTables(h, h.m);
h.PrivGfTable1 = GF_TABLE1;
h.PrivGfTable2 = GF_TABLE2;
