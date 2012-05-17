function [th,ref]=ar(data,n,varargin)
%AR   Computes AR-models of signals using various approaches.
%   
%   Model = AR(Y,N)
%   Model = AR(Y,N,Approach)  
%   Model = AR(Y,N,Approach,Win)
%
%   Model: An IDPOLY object with the estimated parameters of
%   the auto-regressive model. The property "a" stores the estimated
%   coefficients. Type "help idpoly" for more information. 
%
%   Y: The time series to be modeled, an IDDATA object. The data object
%      should contain data for one output signal and no input signals. The
%      data must be uniformly sampled. Type "help iddata" for more
%      information. 
%   N: The order of the AR-model
%   Approach: The method used, one of the following ones:
%      'fb' : The forward-backward approach (default)
%      'ls' : The Least Squares method
%      'yw' : The Yule-Walker method
%      'burg': Burg's method
%      'gl' : A geometric lattice method
%   
%      For the two latter approaches, reflection coefficients and loss
%      functions may be fetched as a second output argument (REFL):
%      [Model, REFL] = AR(y, n, approach), where approach is 'burg' or 'gl'.
%
%   Win: Windows employed, one of the following ones:
%      'now' : No windowing (default, except when approach='yw')
%      'prw' : Prewindowing
%      'pow' : Postwindowing
%      'ppw' : pre- and post-windowing
%
%   Model = AR(Y,N,...,'Property1', Value1, 'Property2', Value2,...)
%   Property/Value pairs can be specified to change the default values of
%   of pertinent properties such as sampling interval. The following
%   properties may be set:
%   (a) Algorithm property 'MaxSize': Determines the size of the largest
%       matrix to be formed during estimation. Example: 
%       Model = AR(Y,N,'ls','MaxSize',500). 
%   (b) Sampling interval 'Ts': Set Ts to override the sampling interval of
%       the data.
%   (c) The 'CovarianceMatrix' flag: Use 'CovarianceMatrix'/'none' to
%       suppress the calculation of the covariance matrix. 
%
%   See also ARX, N4SID, ARMAX, IVAR.

%   L. Ljung 10-7-87
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.14 $  $Date: 2009/12/22 18:53:31 $

error(nargchk(2,Inf,nargin,'struct'))
ref = [];
maxsize = 'auto';
T = 1;
approach = 'fb';
win = 'now';
pt = 1;
Tflag = 0;
% Some initial tests on the input arguments
indc = 1;
list = {'Maxsize','Ts','fb','ls','yw','burg','gl','now',...
    'prw','pow','ppw','CovarianceMatrix','None','Estimate'};
while indc<=length(varargin)
    arg = varargin{indc};
    if ischar(arg)
        if arg(end)=='0'
            pt = 0;
            arg=arg(1:end-1);
        end
        try
            [prop,im] = pnmatchd(arg,list,7,0);
        catch E
            throw(E)
        end
        if im==1
            maxsize = varargin{indc+1};
            indc = indc+1;
        elseif im==2
            T = varargin{indc+1};
            indc=indc+1;
            Tflag = 1;
        elseif im<8
            approach = prop;
        elseif im < 12
            win = prop;
        elseif im == 13
            pt = 0;
        end

    elseif indc == 3
        maxsize = varargin{indc};
    elseif indc==4
        T = varargin{indc};
        Tflag = 1;
    end
    indc=indc+1;
end
pt1 = pt;
errn=0;
if ~isa(n,'double')
    errn=1;
elseif n~=fix(n) || n<=0 || ~isreal(n)
    errn=1;
end

if errn
    ctrlMsgUtils.error('Ident:estimation:arInvalidOrder')
end

if isa(data,'frd') || isa(data,'idfrd') || (isa(data,'iddata') ...
        && strcmp(pvget(data,'Domain'),'Frequency'))
    ctrlMsgUtils.error('Ident:estimation:estUsingFrequencyData','ar')
end

if ~isa(data,'iddata')
    [N,ny] = size(data);
    if min(N,ny)~=1
        ctrlMsgUtils.error('Ident:estimation:arMultiOutput')
    end
    if N<ny
        data = data';
    end
    data = iddata(data,[],T);
end
if Tflag, data = pvset(data,'Ts',T);end
[yor,Ne,ny,nu,T,Name,Ncaps,errflag] = idprep(data,0,inputname(1));
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name) && isempty(pvget(data,'Name'))
   data = pvset(data,'Name',Name); 
end

y = yor; % Keep the original y for later computation of e
if ny>1
    ctrlMsgUtils.error('Ident:estimation:multiOutputNotAllowed','ar')
end
if nu>0
    ctrlMsgUtils.error('Ident:estimation:IODataNotAllowed','ar')
end

maxsdef=idmsize(max(Ncaps),n);
if isempty(maxsize) || ischar(maxsize)
    maxsize=maxsdef;
    maxs = 1;
else
    maxs = 0;
end

if strcmp(approach,'yw')
    win='ppw';
end
if strcmp(win,'prw') || strcmp(win,'ppw')
    for kexp = 1:Ne
        y{kexp}=[zeros(n,1);y{kexp}];
    end
    Ncaps = Ncaps+n;
end
if strcmp(win,'pow') ||  strcmp(win,'ppw')
    for kexp =1:Ne
        y{kexp} = [y{kexp};zeros(n,1)];
    end
    Ncaps = Ncaps+n;

end
th = idpoly;
if maxs
    Max = 'auto';
else
    Max = maxsize;
end
%th = pvset(th,'MaxSize',Max);
% First the lattice based algorithms

if any(strcmp(approach,{'burg','gl'}))
    ef=y;eb=y;
    rho = zeros(1,n+1);
    r = zeros(1,n);
    A = r;
    [ss,l] = sumcell(y,1,Ncaps);
    rho(1) = ss/l;
    for p=1:n
        nef = sumcell(ef,p+1,Ncaps);
        neb=sumcell(eb,p,Ncaps-1);
        if strcmp(approach,'gl')
            den=sqrt(nef*neb);
        else
            den=(nef+neb)/2;
        end
        ss=0;
        for kexp=1:Ne
            ss=ss+(-eb{kexp}(p:Ncaps(kexp)-1)'*ef{kexp}(p+1:Ncaps(kexp)));
        end

        r(p)=ss/den;
        A(p)=r(p);
        A(1:p-1)=A(1:p-1)+r(p)*conj(A(p-1:-1:1));
        rho(p+1)=rho(p)*(1-r(p)*r(p));
        efold=ef;
        for kexp = 1:Ne
            Ncap = Ncaps(kexp);
            ef{kexp}(2:Ncap)=ef{kexp}(2:Ncap)+r(p)*eb{kexp}(1:Ncap-1);
            eb{kexp}(2:Ncap)=eb{kexp}(1:Ncap-1)+conj(r(p))*efold{kexp}(2:Ncap);
        end
    end
    th = pvset(th,'a',[1 A]);
    ref=[0 r;rho];
else
    pt1 = 1; %override pt for the other approaches

end
% Now compute the regression matrix
if pt1
    nmax=n;
    M=floor(maxsize/n);
    R1 = zeros(0,n+1);
    fb=strcmp(approach,'fb');
    if strcmp(approach,'fb')
        R2 = zeros(0,n+1);
        yb = cell(1,Ne);
        for kexp = 1:Ne
            yb{kexp}=conj(y{kexp}(Ncaps(kexp):-1:1));
        end
    end
    for kexp = 1:Ne
        Ncap = Ncaps(kexp);
        yy = y{kexp};
        for k=nmax:M:Ncap-1
            jj=(k+1:min(Ncap,k+M));
            phi=zeros(length(jj),n);
            if fb,
                phib=zeros(length(jj),n);
            end
            for k1=1:n,
                phi(:,k1)=-yy(jj-k1);
            end
            if fb
                for k2=1:n,
                    phib(:,k2)=-yb{kexp}(jj-k2);
                end
            end
            if fb,
                R2 = triu(qr([R2;[[phi;phib],[yy(jj);yb{kexp}(jj)]]]));
                [nRr,nRc] =size(R2);
                R2 = R2(1:min(nRr,nRc),:);
            end
            R1 = triu(qr([R1;[phi,yy(jj)]]));
            [nRr,nRc] =size(R1);
            R1 = R1(1:min(nRr,nRc),:);
            %end
        end
    end
    P = pinv(R1(1:n,1:n));

    if ~any(strcmp(approach,{'burg','gl'}))
        if ~fb
            A = (P * R1(1:n,n+1)).';
        else
            A = (pinv(R2(1:n,1:n)) * R2(1:n,n+1)).';
        end
        th = pvset(th,'a',[1 A]);
    end
    P = P*P';
else
    P = [];
end
if ~pt
    P = [];
end
e = [];
for kexp = 1:length(yor);
    tt=filter([1 A],1,yor{kexp});
    tt(1:n)=zeros(n,1);
    e = [e;tt];
end

lam = e'*e/(length(e)-n);
es = pvget(th,'EstimationInfo');
es.FPE = lam*(1+2*n/sum(Ncaps));
es.Status = 'Estimated Model (AR)';
es.Method = ['AR (''',approach,'''/''',win,''')'];
es.DataLength = sum(Ncaps);
es.LossFcn = lam;
es.DataTs = T;
es.DataName = data.Name;
es.DataInterSample = 'Not Applicable';
idm = pvget(th,'idmodel');
idm = pvset(idm,'Ts',T,'CovarianceMatrix',lam*P,'NoiseVariance',lam,...
    'EstimationInfo',es,'MaxSize',Max,...
    'OutputName',pvget(data,'OutputName'),'OutputUnit',pvget(data,'OutputUnit'));
th = pvset(th,'idmodel',idm);
th = timemark(th);

%--------------------------------------------------------------------------
function [s,ln] = sumcell(y,p,N)

ln = 0;
s = 0;
for kexp = 1:length(y)
    y1 = y{kexp};
    s = s+y1(p:N(kexp))'*y1(p:N(kexp));
    ln = ln + length(y1);
end
