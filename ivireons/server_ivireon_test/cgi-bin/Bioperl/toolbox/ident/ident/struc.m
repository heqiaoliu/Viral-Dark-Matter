function NN = struc(varargin)
%STRUC  Generate typical structure matrices for ARXSTRUC and IVSTRUC.
%   NN = STRUC(NA,NB,NK)
%   NA, NB and NK are vectors containing the orders na, nb and delays nk
%   to be tested. See help on ARX for an explanation of na, nb and nk.
%   NN is returned as a matrix containing all possible combinations of these
%   orders and delays.
%
%   NN = STRUC(NA, NB_1, NB_2,..., NB_nu, NK_1, NK_2,..., NK_nu)
%   Specify order combinations for a multi-input, single-output ARX model
%   with nu inputs. The function thus takes 1+2*nu input arguments.
%
%   STRUC cannot handle multi-output cases.
%   See also ARXSTRUC, ARX, IVSTRUC and SELSTRUC.

%   L. Ljung 7-8-87
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2008/10/31 06:10:58 $

ni = nargin;
if ni < 3
    disp('Usage: ORDERS = STRUC(NA_RANGE,NB_RANGE,NK_RANGE)')
    %return
end

%NN size: zeros(ni,prod(cellfun('length',varargin)));
NN = varargin{ni}(:);
for k = ni-1:-1:1
    NN = local_aug(varargin{k}(:),NN);
end

%--------------------------------------------------------------------------
function M1 = local_aug(v,M)
% v is a vector
% M is a matrix

[nr,nc] = size(M);
nv = length(v);
M1 = zeros(nr*nv,nc+1);
for k = 1:nv
    M1(nr*(k-1)+1:nr*(k-1)+nr,:) = [v(k)*ones(nr,1),M];
end
