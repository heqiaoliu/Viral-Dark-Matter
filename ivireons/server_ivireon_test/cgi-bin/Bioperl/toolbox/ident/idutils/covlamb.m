function P = covlamb(L,N)
% COVLAMB Covariance matrix of Cholesky factor of
%      estimated noise covariance matrix

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2008/12/29 02:07:57 $


%%LL%% note this should ignore zeros in L, i.e.
% treat zeros in L as non-estimated with no covariance %%EJ GJORT%%
if isempty(N)||N==0, N = inf; end
lam = L*L';
ny = size(lam,1);
s1 = 1;
for i1 = 1:ny
    for j1 = 1:i1
        s2 = 1;
        for i2=1:ny
            for j2 = 1:i2
                lamcov(s1,s2) = lam(i1,i2)*lam(j1,j2)+lam(i1,j2)*lam(j1,i2);
                der = 0;
                for k=1:min(i1,j1)
                    if i1==i2 && k==j2
                        der = der+L(j1,k);
                    end
                    if j1==i2 && k==j2
                        der = der+L(i1,k);
                    end
                end
                dlamdL(s1,s2) = der;
                s2 = s2+1;
            end
        end
        s1 = s1+1;
    end
end
%Di = inv(dlamdL);
P = dlamdL\lamcov/dlamdL'/N;

