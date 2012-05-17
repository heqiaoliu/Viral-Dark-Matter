function D = dftmtx(alfa)
%DFTMTX  Discrete Fourier transform matrix in a Galois Field.
%   DFTMTX(ALPH) is the N-by-N matrix whose product with a column vector
%   yields the discrete Fourier transform of the vector with respect 
%   to GF scalar ALPH.  N is the DFT size, given by 2^m-1 where m is the
%   number of bits in the GF object ALPH.
%   ALPH is assumed to have order N, that is, it is an N-th root of 
%   unity so that ALPH^N = 1 and ALPH^K ~= 1 for all K 1,2 ... ,N-1.
%   The i,j element of the DFTMTX is ALPH^((i-1)*(j-1)).
%
%   The inverse discrete Fourier transform matrix is DFTMTX(1/ALPH).
%
%   See also FFT.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2007/09/14 15:58:45 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if numel(alfa.x)~=1
  error('comm:gf_dftmtx:ScalarAlphRqd','DFTMTX requires a scalar from the desired field.')
end

if(alfa.m > 8)
    error('comm:gf_dftmtx:MGreaterThan8','DFTMTX is not supported for M greater than 8.')
end

if ~isequal(alfa.m,GF_TABLE_M) || ~isequal(alfa.prim_poly,GF_TABLE_PRIM_POLY)
   [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(alfa);
end

N = (2^alfa.m)-1;
i = uint32((0:N-1)');
alfa.x = alfa.x(ones(N,1));
D2 = gf_mex(alfa.x,i,alfa.m,'power',alfa.prim_poly,GF_TABLE1,GF_TABLE2);
D = uint32(zeros(N,N));
D(:,1) = uint32(ones(N,1));
D(1,:) = uint32(ones(1,N));
D(:,2) = D2;
for k=3:N
    D(2:N,k) = gf_mex(D(2:N,2),D(2:N,k-1),alfa.m,'times',...
                        alfa.prim_poly,GF_TABLE1,GF_TABLE2);
end
D = gf(D,alfa.m,alfa.prim_poly);
