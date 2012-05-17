function [thd,G] = c2daux(thc,T,method,varargin)
%C2DAUX  Converts a continuous time model to discrete time.
%   MD = C2D(MC,T,METHOD)
%
%   MC: The continuous time IDPOLY model
%
%   T: The sampling interval
%   MD: The discrete time model, an IDPOLY model object.
%   METHOD: 'Zoh' (default) or 'Foh', corresponding to the
%      assumptions that the input is Zero-order-hold (piecewise
%      constant) or First-order-hold (piecewise linear).
%
%   Note that the covariance matrix is not translated.
%
%   See also D2C.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.11 $ $Date: 2009/12/05 02:03:20 $

error(nargchk(2,Inf,nargin,'struct'))

if nargin<3
    method = 'z';
end
G = [];
Told = pvget(thc.idmodel,'Ts');
if Told>0
    ctrlMsgUtils.error('Ident:transformation:FirstArgContinuousModel','c2d')
end
if T<=0
    ctrlMsgUtils.error('Ident:transformation:c2dNonPositiveTs')
end

%lamscale=1/T;
[ny,nu] = size(thc);
%p = pvget(thc.idmodel,'ParameterVector');
%covp = pvget(thc.idmodel,'CovarianceMatrix');
%lam = pvget(thc.idmodel,'NoiseVariance');
inpd = pvget(thc.idmodel,'InputDelay');
%dfrac = inpd-floor(inpd/T);
dinpd = floor(inpd/T+1e4*eps);
dfrac = inpd -T*dinpd;
dfrac = dfrac(:).';
dfrac(abs(dfrac)<1e4*eps) = 0;
dfrac(dfrac>T) = 0;
% if abs(dfrac)<1e4*eps
%     dfrac=zeros(1,nu);
% end

dif = [];

th = thc;
na = th.na; nb = th.nb; nc = th.nc; nddd = th.nd; nf = th.nf;
nk = th.nk;

%nnk = zeros(1,nu+1);
ndd = na+sum(nb)+nc+nddd+sum(nf);
par = pvget(th.idmodel,'ParameterVector');
P = pvget(th.idmodel,'CovarianceMatrix');
if ischar(P) || norm(P)==0 || isempty(P)
    nkder = 0;
else
    nkder = 0:ndd;
end
dt = nuderst(par');
th1 = th;
if isempty(th.nb) && th.nd>0 % This is an 'unorthodox' ARMA. Will be converted to a real one.
    th = pvset(th,'a',conv(pvget(th,'a'),pvget(th,'d')),'d',1);
end
armax = (sum(th.nf)+th.nd == 0);
oe = (th.na+th.nc+th.nd ==0);
lam = pvget(th.idmodel,'NoiseVariance');
if isempty(lam) || norm(lam)==0
    lam = 0;
else
    lam = 1;
end
noisenorm =1;
for kder = nkder
    par1 = par;
    if kder>0
        par1(kder) = par(kder)+dt(kder);
        th1 = parset(th1,par1);
    end
    if armax
        [A,B,C,D,K] = ssdata(th1);
        % nx = size(A,1); nu = size(B,2); nz = 1+nu;
        [Ac,Bc,Cc,Dc,Kc,noisenorm] = idsample(A,B,C,D,K,T,method,1,dfrac);
        ff = poly(Ac);
        thb = [];
        if nu==0,nbn = zeros(1,0);end
        for ku=1:nu
            % Transform to i/o form
            bb = poly(Ac-Bc(:,ku)*Cc)+(Dc(1,ku)-1)*ff;
            
            if Dc(1,ku)==0 && dfrac(ku)==0
                bb = bb(2:length(bb));
            else
                nk(ku) = 0;
            end
            nbn(ku) = length(bb);
            thb = [thb bb];
        end
        if lam
            cc = poly(Ac-Kc*Cc); %Normalization done in sample call.
            cc = cc(2:end);
        else
            cc = zeros(1,0);
        end
        thh = [ff(2:end) thb cc];
    else % not armax
        [a,b,c,d,f] = polydata(th1,1);
        ss = 1;
        thb = []; thcc = []; thddd = []; thf = []; ncn = 0; ndn = 0;
        nk(nu+1) = 0; nb(nu+1) = nc+1; nf(nu+1) = nddd;
        if oe
            list = 1:nu;
            ncn = 0; ndn = 0;
        else
            list = [nu+1,1:nu];
        end
        for k = list
            if k == nu+1
                de=conv(d,a);
                num = c;
                dfr = 0;
            else
                num = b(k,end-nb(k)+1:end);
                de=conv(a,f(k,end-nf(k):end));
                dfr = dfrac(k);
            end
            n=length(de); nn=length(num);
            if nn>n
                ctrlMsgUtils.error('Ident:transformation:c2dPureDerivative')
            end
            nume=zeros(1,n); nume(n-nn+1:n)=num;
            if length(de)==1
                A = [];
            else
                A = [-de(2:n);eye(n-2,n-1)]; % Transform to state-space
            end
            B = eye(n-1,1);
            C = nume(2:n)-nume(1)*de(2:n);
            D = nume(1);
            [Ac,Bcc,Cc,D] = idsample(A,B,C,D,zeros(n-1,0),T,method,1,dfr);%LL!!
            ff = poly(Ac);                % Transform to i/o form
            bb = poly(Ac-Bcc*Cc)+(D-1)*ff;
            if D==0
                bb = bb(2:length(bb));
                nkn(ss) = 1;
            else
                if k==nu+1
                    noisenorm = bb(1);
                    bb = bb/bb(1); % noise normalization
                end
                nkn(ss) = 0;
            end
            
            if k<nu+1
                nbn(ss) = length(bb);
                nfn(ss) = length(ff)-1;
                ss = ss+1;
                thb = [thb bb];
                thf = [thf ff(2:length(ff))];
            end
            if k==nu+1
                ncn = length(bb)-1;
                ndn = length(ff)-1;
                thcc = bb(2:length(bb));
                thddd = ff(2:length(ff));
            end
        end
        thh = [thb thcc thddd thf];
    end
    
    if kder==0
        thd = th;
        thd.idmodel = pvset(thd.idmodel,'Ts',T,'InputDelay',dinpd);
        thd.idmodel = pvset(thd.idmodel,'NoiseVariance',pvget(th,'NoiseVariance')/T*noisenorm^2);
        if armax
            thd.na = length(ff)-1;
            thd.nb = nbn;
            thd.nc = length(cc);
            nkn = nk;
        else
            thd.na = 0; thd.nb = nbn; thd.nc = ncn;
            thd.nd = ndn; thd.nf = nfn;
        end
        nknew = double(nkn>0); thd.nk = nknew(1:nu);
        thd = parset(thd,thh.');
        thh0 = thh;
    else
        dif(:,kder) = (thh-thh0)'/dt(kder);
    end
end
if ~isempty(dif)
    Pc = dif*P*dif';
else
    Pc = [];
end
thd.idmodel = pvset(thd.idmodel,'CovarianceMatrix',Pc);
