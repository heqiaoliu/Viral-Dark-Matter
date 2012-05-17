function [A,B,C,D,K,L,Gs] = idsample(a,b,c,d,k,T,inters,sample,dfract)
%IDSAMPLE  Sample/unsample linear systems
%
%   [As,Bs,Cs,Ds,Ks,Ls,G] = IDSAMPLE(A,B,C,D,K,T,InterSample,Mode,Delay)
%
%   A,B,C,D,K are the matrices of the system to be sampled/unsampled.
%   T is the sampling interval.
%   InterSample is 'zoh' or 'foh'.
%   Mode = 1 (default) means sampling and Mode = 0 means unsample.
%   Delay is the input delay in time units. This does not have to be
%       an integer multiple of T. Delay is only applicable for the
%       sampling case.
%
%   As,Bs,Cs,Ds,Ks are the resulting system matrices.
%   Ls is the adjustment of the covariance matrix in case of 'foh'
%   sampling, so that the covariance of the new innovations is
%   Ls*Lambda*Ls' where Lambda is the T-adjusted covariance of the
%   noise of the original system.
%   G is the matrix that transforms the initial state X0 according to
%   X0d = G * [X0c;u(0)], where u(0) is the input at time 0 and X0c
%   is the continuous time state at time 0.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.3.6.15 $ $Date: 2009/10/16 04:56:41 $

[nxr,nxc] = size(a);
if nxr~=nxc
    ctrlMsgUtils.error('Ident:transformation:idsample1')
end
Gs = [];
[nx,nu] = size(b);
if nxr~=nx
    ctrlMsgUtils.error('Ident:transformation:idsample2')
end
ny=size(d,1);
[nxy,nyk]=size(k);
if nxy~=nx
    ctrlMsgUtils.error('Ident:transformation:idsample6')
end
b = [b k];
d = [d eye(nyk)];
L = eye(nyk);
if nargin < 9
    dfract = 0;
end
if nargin <8
    sample = 1;
end
try
    [a,b,c,~,dTi] = abcbalance(a,b,c,[],Inf,'noperm','scale');
catch
    dTi = ones(length(a),1);
end
if dfract==0
    if sample == 1
        switch lower(inters(1))
            case 'z'
                s = expm([[a b]*T; zeros(nu+nyk,nx+nu+nyk)]);
                A = s(1:nx,1:nx);
                B = s(1:nx,nx+1:nx+nu);
                K = s(1:nx,nx+nu+1:nx+nu+nyk);
                C = c;
                D = d(:,1:nu);
                Gs = [eye(nx) zeros(nx,nu)];
            case 'f'
                nuy = nu+nyk;
                s = expm([[a b zeros(nx,nuy)]*T;[zeros(nuy,nx+nuy),T*eye(nuy)];...
                    zeros(nuy,nx+2*nuy)]);
                if any(any(isnan(s)))
                    A = NaN;B=NaN;C=NaN;D=NaN;K=NaN;L=NaN;
                    return
                end
                A = s(1:nx,1:nx);
                gtil = s(1:nx,nx+nuy+1:nx+2*nuy);
                BK = s(1:nx,nx+1:nx+nuy)+(A-eye(nx))*gtil/T;
                B = BK(:,1:nu); K = BK(:,nu+1:nuy);
                C = c;
                D = d(:,1:nu)+c*gtil(:,1:nu)/T;
                Gs = [eye(nx) -gtil(:,1:nu)/T];
                if nyk>0
                    L = eye(nyk) + c*gtil(:,nu+1:nuy)/T;
                    K = K*pinv(L);
                end
            otherwise
                ctrlMsgUtils.error('Ident:transformation:idsample3')
        end
        
    else %Unsample
        switch lower(inters(1))
            case 'z'
                erm = 0;
                try
                    was = ctrlMsgUtils.SuspendWarnings('MATLAB:funm:nonPosRealEig');
                    s = logm([[a b]; [zeros(nu+nyk,nx) eye(nu+nyk,nu+nyk)]])/T;
                    delete(was)
                catch
                    erm = 1;
                end
                if erm || any(any(isnan(s)))
                    ctrlMsgUtils.error('Ident:transformation:idsample4')
                end
                if isreal([a b]), s = real(s); end
                A = s(1:nx,1:nx);
                B = s(1:nx,nx+1:nx+nu);
                K = s(1:nx,nx+nu+1:nx+nu+nyk);
                C = c;
                D = d(:,1:nu);
            case 'f'
                %nuy = nu+nyk;
                erm = 0;
                try
                    was = ctrlMsgUtils.SuspendWarnings('MATLAB:funm:nonPosRealEig');
                    Ac = logm(a)/T;
                    delete(was)
                catch
                    erm = 1;
                end
                if erm || any(any(isnan(Ac)))
                    ctrlMsgUtils.error('Ident:transformation:idsample4')
                end
                if isreal(a), Ac = real(Ac); end
                s = expm([[Ac eye(nx) zeros(nx,nx)]*T;[zeros(nx,2*nx),T*eye(nx)];...
                    zeros(nx,3*nx)]);
                Gt = s(1:nx,2*nx+1:3*nx);
                Bgen = pinv(s(1:nx,nx+1:2*nx)+(a-eye(nx))*Gt/T);
                
                BK = Bgen*b;
                B = BK(:,1:nu);
                K = BK(:,nu+1:nu+nyk);
                D = d(:,1:nu) - c*Gt*B/T;
                A = Ac;
                C = c;
                if nyk>0
                    L = eye(nyk) - c*Gt*K/T;
                    K = K*pinv(L);
                end
            otherwise
                ctrlMsgUtils.error('Ident:transformation:idsample3')
        end
    end
    % Undo the balancing:
    dT = 1./dTi;
    nxaug = size(A,1);
    A(1:nx,:) = repmat(dTi,[1 nxaug]) .* A(1:nx,:);
    try
        B(1:nx,:) = repmat(dTi,[1 nu]) .* B(1:nx,:);
    end
    K(1:nx,:) = repmat(dTi,[1 nyk]) .* K(1:nx,:);
    if ~isempty(Gs)
        Gs(1:nx,nx+1:nx+nu)=repmat(dTi,[1 nu]).*Gs(1:nx,nx+1:nx+nu);
    end
    A(:,1:nx) = A(:,1:nx) .* repmat(dT.',[nxaug 1]);
    try
        C(:,1:nx) = C(:,1:nx) .* repmat(dT.',[ny 1]);
    end
    
else % fractional delay
    if sample==0
        ctrlMsgUtils.error('Ident:transformation:idsample5')
    end
    if length(dfract)==nu
        dfract = [dfract,zeros(1,nyk)];
    end
    nuk = nu + nyk;
    tolint = 1e4*eps;
    Ts = T;
    dfract = dfract/T;
    nk = floor(dfract);
    dfract = dfract - nk; %%%
    zid = (dfract<=tolint);
    chdel = find(~zid);
    nid = length(chdel);
    switch lower(inters(1))
        case 'z'
            Tmat = [a , b ; zeros(nuk,nx+nuk)];  % transition mat.
            %cd = [c , d];
            
            E = blkdiag(eye(nx),zeros(nuk,nid));
            E(nx+chdel,nx+1:nx+nid) = eye(nid);
            F = [zeros(nx,nuk) ; double(diag(zid))];
            G = [c d(:,~zid)];
            H = zeros(ny,nuk);
            H(:,zid) = d(:,zid);
            
            Events = sort([0 dfract 1]);
            Events(:,diff([-1,Events])<=tolint) = [];
            
            for j=1:length(Events)-1,
                t0 = Events(j);
                t1 = Events(j+1);
                
                h = (t1-t0)*T;
                ehTmat = expm(h*Tmat);
                E(1:nx,:) = ehTmat(1:nx,:) * E;
                F(1:nx,:) = ehTmat(1:nx,:) * F;
                iu = find(abs(dfract-t1)<=tolint);
                E(nx+iu,:) = 0;
                F(nx+iu,iu) = eye(length(iu));
            end
            xkeep = [1:nx , nx+chdel];
            E = E(xkeep,:);
            F = F(xkeep,:);
            Gs = [[eye(nx,nx),zeros(nx,nu)];zeros(size(E,1)-nx,nx+nu)];
        case 'f'
            Tmat = [a , b , zeros(nx,nuk)  ; ...
                zeros(nuk,nx+nuk)  eye(nuk)/Ts ; ...
                zeros(nuk,nx+2*nuk)];      % transition matrix
            %cd = [c , d];
            
            nxaug = nx+nid;
            E = blkdiag(eye(nx),zeros(2*nuk,nid));
            E(nx+chdel,nx+1:nxaug) = diag(dfract(~zid));
            E(nx+nuk+chdel,nx+1:nxaug) = -eye(nid);
            F1 = [zeros(nx,nuk) ; diag(1-dfract) ; diag(~zid)];
            F2 = [zeros(nx+nuk,nuk) ; diag(zid)];
            %H2 = zeros(ny,nuk);
            G = [c , d*E(nx+1:nx+nuk,nx+1:nxaug)];
            H1 = d * F1(nx+1:nx+nuk,:);
            Events = sort([0 dfract 1]);
            Events(:,diff([-1,Events])<=tolint) = [];
            
            for j=1:length(Events)-1,
                t0 = Events(j);
                t1 = Events(j+1);
                h = (t1-t0)*T;
                ehTmat = expm(h*Tmat);
                ehTmat = ehTmat(1:nx+nuk,:);
                E(1:nx+nuk,:) = ehTmat * E;
                F1(1:nx+nuk,:) = ehTmat * F1;
                F2(1:nx+nuk,:) = ehTmat * F2;
                iu = find(abs(dfract-t1)<=tolint);
                liu = length(iu);
                E([nx+iu,nx+nuk+iu],:) = 0;
                F1([nx+iu,nx+nuk+iu],iu) = [eye(liu) ; zeros(liu)];
                F2(nx+nuk+iu,iu) = eye(liu);
            end
            
            E = E([1:nx , nx+chdel],:);
            F1 = [F1(1:nx,:) ; zeros(nid,nuk)];
            F1(nx+1:nxaug,~zid) = eye(nid);
            F2 = [F2(1:nx,:) ; zeros(nid,nuk)];
            F = F1 + E*F2 - F2;
            H = G*F2 + H1;
            Gs = [[eye(nxaug,nx) -F2(:,1:nu)];zeros(size(E,1)-nxaug,nx+nu)];
    end
    
    % Undo the balancing:
    dT = 1./dTi;
    nxaug = size(E,1);
    E(1:nx,:) = repmat(dTi,[1 nxaug]) .* E(1:nx,:);
    F(1:nx,:) = repmat(dTi,[1 nuk]) .* F(1:nx,:);
    Gs(1:nx,nx+1:nx+nu) = repmat(dTi,[1 nu]) .* Gs(1:nx,nx+1:nx+nu);
    E(:,1:nx) = E(:,1:nx) .* repmat(dT.',[nxaug 1]);
    try
        G(:,1:nx) = G(:,1:nx) .* repmat(dT.',[ny 1]);
    end
    ms.a=E; ms.b = F(:,1:nu);ms.k=F(:,nu+1:nu+nyk); ms.c = G; ms.d = H(:,1:nu);
    ms.x0 = zeros(length(E),1);
    ms = addnk(ms,nk(1:nu) +1,'par');
    A = ms.a;B=ms.b;C=ms.c;D=ms.d;K = ms.k;
    
    %A = E; B = F(:,1:nu); K = F(:,nu+1:nu+nyk); C = G; D = H(:,1:nu);
    
end
%Check stability: %%%LL%%%
ctrlMsgUtils.SuspendWarnings;
if ~isempty(K) && ~isempty(C)  && norm(K,1)>0
    if sample==0
        if max(real(eig(A-K*C)))>0
            try
                [~,~,Kn] = care(A',C',K*K',eye(size(K,2)),K);
                K = Kn';
            end
        end
    else
        if max(abs(eig(A-K*C)))>1
            try
                K = ssssaux('kric',A,C,K*K',eye(size(K,2)),K);
            end
        end
    end
end
