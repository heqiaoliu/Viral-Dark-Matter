function KCell = state2stdreg(sys,Nx,CumInd)
% Compute the std regressor selector matrix that selects a subset of model
% states and inputs ([X;U]) for each output.
%
% CumInd: cumulative delay (on output and input variables vertically
% stacked) indices

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:47:31 $

[ny,nu] = size(sys);
na = sys.na; nb = sys.nb; nk = sys.nk;
KCell = cell(ny,1);

if nargin<2
    Delays = getDelayInfo(sys);
    Nx = sum(Delays);
    CumInd = [1,cumsum(Delays(1:end-1))+1];
end

for ky = 1:ny
    len = sum(na(ky,:))+sum(nb(ky,:)); % number of std reg
    K = zeros(len,Nx+nu);
    rowoffset = 0;

    % select standard regressors of output variables
    for k = 1:ny
        delk = na(ky,k);
        if delk>0
            coloffset = CumInd(k);
            K(rowoffset+1:rowoffset+delk,...
                coloffset:coloffset+delk-1) = eye(delk);
            rowoffset = rowoffset+delk;
        end
    end

    % select standard regressors of input variables
    % these could be states (x(t) = u(t-k)) or inputs (u(t))
    for k = 1:nu
        nbk = nb(ky,k);
        nkk = nk(ky,k);
        if nbk>0
            if nkk==0
                % insert direct feedback regressor
                K(rowoffset+1,Nx+k) = 1;
                rowoffset = rowoffset+1;
                nbk = nbk - 1;
                nkk = 1;
            end

            if nbk>0
                coloffset = CumInd(k+ny);
                K(rowoffset+1:rowoffset+nbk,...
                    coloffset+nkk-1:coloffset+nkk+nbk-2) = eye(nbk);
                rowoffset = rowoffset+nbk;
            end
        end
    end
    KCell{ky} = K;
end
