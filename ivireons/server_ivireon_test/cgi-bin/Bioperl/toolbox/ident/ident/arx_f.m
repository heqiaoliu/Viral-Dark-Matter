function m = arx_f(varargin)
%IDARX/ARX_F  Estimates (multivariate) ARX-models using frequency domain
%data
%
%   M = ARX_F(Z,Mi)
%
%   Z: The output-input data as an IDDATA object. See HELP IDDATA
%   Mi: an IDARX object defining the orders. See help IDARX.
%
%   Some parameters associated with the algorithm are accessed by
%   MODEL = ARX(DATA,Mi'MaxSize',MAXSIZE)
%   where MAXSIZE controls the memory/speed trade-off. See the manual.
%
%   ARX_F minimizes the norm of E'*inv(LAMBDA)*E, where E are the prediction
%   errors and LAMBDA is Mi.NoiseVariance.
%
%   When property/value pairs are used, they may come in any order.
%   Omitted ones are given default values.
%   The MODEL properties 'FOCUS', 'INPUTDELAY', 'NOISEVARIANCE' and
%   'FIXEDPARAMETER' may be set as Property/Value pairs as in
%   M = ARX(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
%   See IDPROPS ALGORITHM and IDPROPS IDMODEL.

%
%   L. Ljung 10-2-90
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.4.8 $  $Date: 2009/12/22 18:53:34 $

error(nargchk(2,Inf,nargin,'struct'))

[nn,data,p] = arxdecod(varargin{:},inputname(1));
na=nn.na;nb=nn.nb;nk=nn.nk; nu=size(nb,2);ny=size(na,1);
if p==1
    if  ~isa(data,'iddata')
        T=pvget(nn,'Ts');
        data = iddata(data(:,1:ny),data(:,ny+1:end),T);
    end
    Inpd = pvget(nn,'InputDelay');
    foc = pvget(nn,'Focus');
    if ischar(foc) && strcmpi(foc,'Stability')
        ctrlMsgUtils.warning('Ident:estimation:arxStabilityFoc')
    end
    data = nkshift(data,Inpd);
    [ze,Ne,nyd,nud,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
    if ~isempty(errflag.message), error(errflag), end

    if ~isempty(Name), data.Name = Name; end

    if nu == 0 && (~ischar(foc) || (ischar(foc) && ~strcmpi(foc,'Prediction')))
        ctrlMsgUtils.warning('Ident:estimation:timeSeriesFocus')
        %mdum = pvset(mdum,'Focus','Prediction');
        foc = 'Prediction';
    end

    nz = nyd+nud;
else % This is a call from  iv
    ze = data;
    if ~iscell(ze),ze={ze};end
    Ne = length(ze);
    Ncaps =[];
    nz = size(ze{1},2);
    nud =nz -ny;
    nyd = ny;
    foc = 'Prediction';
    for kexp = 1:Ne
        Ncaps = [Ncaps,size(ze{kexp},1)];
    end
end
if (nud~=nu && nu>0) || nyd~=ny
    ctrlMsgUtils.error('Ident:estimation:arxDataOrderMismatch')
end
nma=max(max(na)');nbkm=max(max(nb+nk)')-1;nkm=min(min(nk)');
nd=sum(sum(na)')+sum(sum(nb)');
if nu>0
    n=nma*ny+(nbkm-nkm+1)*nu;
else
    n=nma*ny;
end


% *** Set up default values **
maxsize = pvget(nn,'MaxSize');

if strcmpi(maxsize,'auto')
    maxsize = idmsize(max(Ncaps),nd);
end
if (ischar(foc) && strcmpi(foc,'Simulation')) || ~ischar(foc) %% The focus
    foc0 = foc;
    nn = pvset(nn,'Focus','Prediction','InputDelay',zeros(nu,1));
    m0 = arx(data,nn); % data shifted
    if isa(foc,'idmodel') || isa(foc,'lti') || iscell(foc)
        ts = pvget(data,'Ts');ts=ts{1};[num1,den1]=tfdata(m0);
        foc = foccheck(foc,ts,den1{1,1});

    else
        [num,den]=tfdata(m0);
        foc = {1,fstab(den{1,1})};
    end
    zf = idfilt(data,foc);
    m = arx(zf,nn);
    m = pvset(m,'InputDelay',Inpd,'Focus',foc0);
    return
end
nmax=max([nma nbkm 1]');
M=floor(maxsize/n);
R1 = zeros(0,n+ny);
nz = ny+nu;
parvec = pvget(nn,'ParameterVector');

fixpar = pnam2num(pvget(nn,'FixedParameter'),pvget(nn,'PName'));
if (length(fixpar) == length(parvec)) && ~isempty(parvec)
    ctrlMsgUtils.error('Ident:estimation:AllFixedParameters')
end
index = (1:length(parvec))';
index(fixpar) =[];

if p && ~strcmpi(pvget(nn,'CovarianceMatrix'),'None')
    kloop = 2;
else
    kloop = 1;
end
ni = length(index);
np = sum(sum(na)')+sum(sum(nb)');
w = pvget(data,'SamplingInstants');
Ts = pvget(data,'Ts'); Ts = Ts{1};
for klc = 1:kloop
    if klc ==1  % just to estimate the parameters
        lam = pvget(nn,'NoiseVariance'); % The norm to be used
        e = [];
        R1 = zeros(0,ni+1);
    else
        R1 = zeros(0,ni);
        was = warning('off', 'MATLAB:sqrtm:SingularMatrix'); [lw,lwid] = lastwarn;
        melam = pinv(lam)*sqrtm(lam0);
        warning(was), lastwarn(lw,lwid)
        R1f = zeros(0,ni);
    end
    was = warning('off', 'MATLAB:sqrtm:SingularMatrix'); [lw,lwid] = lastwarn;
    sqrlam = sqrtm(pinv(lam));
    warning(was), lastwarn(lw,lwid)
    oeflag = 0;
    if sum(sum(na)')==0 && klc==2 % To compute the true variance in the OE case
        oeflag = 1;
        %dat = iddata(e,[],1);
        try
            me = n4sid(e,ny*4,'cov','none');
            me = pvset(me,'A',oestab(pvget(me,'A'),0.99,1));
            [av,bv,cv,dv,kv] = ssdata(me);
            cv1=cv;av=av';cv=kv';kv=cv1';
            melam = pinv(lam)*sqrtm(pvget(me,'NoiseVariance'));
        catch
            av = zeros(1,1);cv = zeros(ny,1);kv=zeros(1,ny);
        end
    end

    for kexp = 1:Ne
        W = w{kexp};
        z=ze{kexp};
        Ncap = Ncaps(kexp);
        M = floor(maxsize/n/ny);
        for k=nmax:M:Ncap-1
            if min(Ncap,k+M)<k+1,break,end
            jj=1:Ncap;
            %jj=(k+1:min(Ncap,k+M));
            phi=zeros(length(jj)*ny,np);
            OM = exp(-i*[0:3]'*W(jj)'*Ts);
            if klc == 2 psi = phi;end
            sp = 1;
            for ky=1:ny
                %phitemp=zeros(length(jj),ny);
                for ydel = 1:max(na(ky,:))
                    for ky2 = 1:ny
                        phitemp=zeros(length(jj),ny);
                        if na(ky,ky2)>=ydel
                            phitemp(:,ky) = z(jj,ky2).*OM(ydel+1,:).';%z(jj-ydel,ky2);
                            if oeflag
                                psitemp1=ltitr(av,kv,phitemp(end:-1:1,:));
                                psitemp = (psitemp1*cv.'+phitemp(end:-1:1,:))*melam;
                                psi(:,sp) = psitemp(:);
                            elseif klc == 2
                                psitemp = phitemp*melam;
                                psi(:,sp) = psitemp(:);
                            end
                            phitemp= phitemp*sqrlam;
                            phi(:,sp)=phitemp(:);
                            sp = sp+1;
                        end
                    end
                end
                if ~isempty(nb)
                    for udel = max(1,min(nk(ky,:))):max(nk(ky,:)+nb(ky,:))
                        for ku2 = 1:nu
                            phitemp=zeros(length(jj),ny);
                            if (nk(ky,ku2)<=udel) &&  (nk(ky,ku2)+nb(ky,ku2)-1>=udel)
                                phitemp(:,ky) = z(jj,ny+ku2).*OM(udel+1,:).';%z(jj-udel,ny+ku2);
                                if oeflag
                                    psitemp1=ltitr(av,kv,phitemp(end:-1:1,:));
                                    psitemp = (psitemp1*cv.'+phitemp(end:-1:1,:))*melam;
                                    psi(:,sp) = psitemp(:);
                                elseif klc == 2
                                    psitemp = phitemp*melam;
                                    psi(:,sp) = psitemp(:);
                                end
                                phitemp=phitemp*sqrlam;
                                phi(:,sp)=phitemp(:);
                                sp = sp+1;
                            end
                        end
                    end
                end
            end
            if ~isempty(nk) && any(any(nk==0)')
                for ky = 1:ny
                    %phitemp=zeros(length(jj),ny);
                    for ku=1:nu
                        phitemp=zeros(length(jj),ny);
                        if nk(ky,ku)==0 && nb(ky,ku)>0
                            phitemp(:,ky) = z(jj,ny+ku);
                            if oeflag
                                psitemp1=ltitr(av,kv,phitemp(end:-1:1,:));
                                psitemp = (psitemp1*cv.'+phitemp(end:-1:1,:))*melam;
                                psi(:,sp) = psitemp(:);
                            elseif klc == 2
                                psitemp = phitemp*melam;
                                psi(:,sp) = psitemp(:);
                            end

                            phitemp=phitemp*sqrlam;
                            phi(:,sp)=phitemp(:);
                            sp = sp+1;
                        end
                    end
                end
            end
            if klc == 1
                yy = z(jj,1:ny)*sqrlam; yvec = yy(:);
                evec = yvec - phi*parvec;

            else
                evec = zeros(size(phi,1),0);
            end
            phi = phi(:,index);
            R1 = triu(qr([R1;phi,evec]));[nRr,nRc]=size(R1);
            R1 = R1(1:min(nRr,nRc),:);
            if klc ==2
                psi = psi(:,index);
                R1f = triu(qr([R1f;psi]));[nRrf,nRcf]=size(R1f);
                R1f = R1f(1:min(nRrf,nRcf),:);
            end
        end
    end

    if klc == 1 % estimate
        if size(R1,1)<ni+1
            ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
        end
        parvec(index) = parvec(index) + pinv(R1(1:ni,1:ni))*R1(1:ni,ni+1);
        m = nn;
        m =parset(m,parvec);
        if p
            if norm(m.nb)==0
                data = data(:,:,[]);
            end
            e = pe(data,m);
            ee = pvget(e,'OutputData');
            lamhat = zeros(ny,ny); Nc = 0;
            for kexp = 1:Ne
                e1 = ee{kexp}(nmax:end,:);
                lamhat = lamhat + e1'*e1;
                Nc = Nc + length(e1);
            end

            lam0 = lamhat/(Nc-length(parvec)/ny); % Exact interpretation:
            % Same parameterization in each output channel.
            V = det(lam0);
        end
    else
        cov = zeros(length(parvec),length(parvec));
        cov1 = pinv(R1'*R1);
        cov1 = cov1*R1f'*R1f*cov1;
        cov(index,index) = cov1;
        try
            norm(cov);
        catch
            ctrlMsgUtils.warning('Ident:estimation:illConditionedCovar2')
            cov = [];
        end
    end % klc
end
if strcmp(pvget(m,'CovarianceMatrix'),'None')
    cov = 'None';
end
if p
    idm = pvget(m,'idmodel');
    it_inf = pvget(idm,'EstimationInfo');
    it_inf.Method = 'ARX';
    it_inf.DataLength=sum(Ncaps);
    it_inf.DataTs=Ts;
    it_inf.DataInterSample=pvget(data,'InterSample');
    it_inf.Status='Estimated model (ARX)';
    it_inf.DataName=Name;
    it_inf.LossFcn = V;
    it_inf.FPE = V*(1+2*length(parvec)/sum(Ncaps));
    idm = pvset(idm,'ParameterVector',parvec,'CovarianceMatrix',cov,...
        'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',lam0);
    idm = idmname(idm,data);
    m = pvset(m,'idmodel',idm);
    m = timemark(m);
end
%if ~strcmp(cov,'None')
%setcov(m)
%end
