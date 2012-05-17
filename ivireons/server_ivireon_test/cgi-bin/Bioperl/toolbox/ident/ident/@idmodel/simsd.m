function [yout,ysdout] = simsd(th,u,n,noise,ky)
%SIMSD Illustrates the uncertainty in simulated model responses.
%   SIMSD(Model,U)
%
%   U is an IDDATA object or a column vector (matrix) containing the input(s).
%   Model is any IDMODEL object (IDPOLY, IDARX, IDSS, IDGREY or IDPROC).
%   10 random models are created, consistent with the covariance informa-
%   tion in Model, and the responses of each of these models to U are plotted
%   in the same diagram. The nominal model response appears in a different
%   color (black on light-colored axes and red on darker axes) than those
%   of the random models. 
%
%   The number 10 can be changed to N by SIMSD(Model,U,N).
%
%   With SIMSD(Model,U,N,'noise',KY), additive noise (e) is added to the
%   simulation in accordance with the noise model of Model.
%   KY denotes the output numbers to be plotted (default all).
%
%   When called with output arguments
%   [Y,YSD] = SIMSD(Model,U)
%   no plots are created, but Y is returned as a cell array of the
%   simulated outputs and YSD is the estimated standard deviation of the
%   outputs. If U is an IDDATA object, so are Y and YSD, otherwise they are
%   returned as vectors (matrices). In the IDDATA case plot(Y{:}) will thus
%   plot all the responses.
%
%   SIMSD and SIM have similar syntaxes. Note that SIMSD computes the
%   standard deviation by Monte Carlo simulation, while SIM uses
%   differential approximations ('Gauss approximation formula.'). They may
%   give different results.
%
%   Note that the parameter changes in the randomly selected models are
%   scaled to be small (ca 0.1%) compared to the parameter values. The
%   response changes are then scaled up to correspond to one standard
%   deviation.
%
%   See also IDMODEL/SIM.

%   L.Ljung 7-8-87
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.16 $ $Date: 2009/10/16 04:55:26 $

error(nargchk(2,5,nargin,'struct'))

if isa(u,'idmodel')
    th1 = u;
    u = th;
    th = th1;
end
[ny,nu] = size(th);
if nargin<5,ky=[];end
if nargin <4,noise=[];end
if length(noise)<3,noise=[];end
if nargin<3,n=[];end,
if isempty(ky),ky=1:ny;end
if isempty(noise),noise='nonoise';end
if isempty(n),n=10;end
iddataflag = 1;
Tsamp = pvget(th,'Ts');
if ~isa(u,'iddata')
    iddataflag = 0;
    if Tsamp==0
        ctrlMsgUtils.error('Ident:analysis:simCTModelData')
    else
        u = iddata([],u,Tsamp);
    end
end
[N,~,nud]=size(u);
if nu~=nud,
    ctrlMsgUtils.error('Ident:analysis:simsdCheck1')
end
P = pvget(th,'CovarianceMatrix');
if strcmp(P,'None')
    %warning('No covariance information given in the model.')
    d = length(pvget(th,'ParameterVector'));
    P=zeros(d,d);
    n=1;
end
if size(P)==0
    d = length(pvget(th,'ParameterVector'));
    P = zeros(d,d);
    try
        ut = pvget(th,'Utility');
        th1 = ut.Pmodel;
    catch
        th1 = [];
        ctrlMsgUtils.warning('Ident:analysis:simsdCheck2')
    end
    if ~isempty(th1)
        try
            P = pvget(th1,'CovarianceMatrix');
            th = th1;
        catch
            ctrlMsgUtils.warning('Ident:analysis:simsdCheck2')
        end
    end
end

par = pvget(th,'ParameterVector');
%lam = pvget(th,'NoiseVariance');
d = length(par);
if norm(P,1)>0
    try
        P = chol(P+1e4*eps*eye(size(P))*norm(P,'fro'));
    catch
        n=1;
        ctrlMsgUtils.warning('Ident:analysis:simsdCheck3')
    end
else
    n = 1;
    ctrlMsgUtils.warning('Ident:analysis:simsdCheck2')
end
tsd = pvget(u,'Ts');
tsd = tsd{1};
u1  = u;
yna = pvget(th,'OutputName');
%k = 1;
wrn = warning;
warning off Ident:analysis:unstableSim

sc = 1;
if n>1
    try
        %todo: what happens if a certain par's estimated value is 0?
        sc = 0.001/max(diag(P)./par); % Max 1%% variation in pars
    catch
        sc = 1;
    end
end
% Find uncertain time delay parameter (if any) - this should not be scaled
def = 1; % The default run
strtd = '';
if isa(th,'idproc')
    setpname(th);
    strtd = strmatch('Td',pvget(th,'PName'));
    if ~isempty(strtd)
        y = localprocsim(th,sc,P,tsd,u1,strtd,d,n,par,noise);
        def = 0;
    end
end

if ~isempty(strtd)
    scm = sc*ones(d,1);
    scm(strtd)=1;
    scm = diag(scm);
else
    scm = sc*eye(d);
end
if def
    y{1} = sim(u,th);% The basic noise free simulation
    yy0 = pvget(y{1},'OutputData'); yy0 = yy0{1};
    for k = 2:n
        th1 = parset(th,par+scm*P'*randn(d,1));
        if noise(3)=='i',
            e = iddata([],sc*randn(N,ny),tsd);
            u1=[u e];
        end %corr 9007
        try
            z = sim(u1,th1);
            yy = pvget(z,'OutputData');yy=yy{1};
            yy = yy +(yy - yy0)/sc; % Restore to variance 1
            y{k} = pvset(z,'OutputData',{yy});
        end
        %k = k + 1;
    end
end
[~,lastwrnid] = lastwarn;
if strcmp(lastwrnid,'Ident:analysis:unstableSim')
    ctrlMsgUtils.warning('Ident:idmodel:unstableSimulations');
end
warning(wrn);

if nargout
    %if n>1 %then compute ysd
    y0 = pvget(y{1},'OutputData');
    sd = zeros(size(y0{1}));
    for k = 2:n
        y1 = pvget(y{k},'OutputData');
        sd = sd + (y1{1}-y0{1}).^2;
    end

    if iddataflag
        ysdout = y{1};
        if n>1
            ysdout = pvset(ysdout,'OutputData',{sqrt(sd/(n-1))});
        else
            ysdout = [];
        end
        yout = y;
    else
        if n>1
            ysdout = sqrt(sd/(n-1));
        else
            ysdout = [];
        end
        for k=1:n
            yout(k)=pvget(y{k},'OutputData');
        end
    end

else % then plot
    cols = get(0, 'defaultAxesColor');
    if (sum(cols) < 1.5)
        Clr = 'r';
    else
        Clr = 'k';
    end
    for kk = ky
        yh = pvget(y{1},'OutputData');
        tim = pvget(y{1},'SamplingInstants');
        tim = tim{1};
        yh = yh{1};
        yh=yh(:,kk);
        ndu=length(yh);y1=max(yh)+1e8*eps;y2=min(yh);
        y12=y1-y2;y1=y1+0.2*y12;y2=y2-0.2*y12;
        subplot(length(ky),1,kk)
        plotDefH = plot(tim,yh,Clr); %'Linewidth',get(0,'DefaultAxesLineWidth')*3);
        axis([tim(1) tim(end) y2 y1]);hold on;
        title(['Output ',yna{kk}])

        for k=2:n
            yh=pvget(y{k},'OutputData');
            yh = yh{1};
            y1=max([y1;yh(:,kk)]);y2=min([y2;yh(:,kk)]);
            plot(tim,yh(:,kk))
        end
        axis([tim(1) tim(end) y2 y1]);
        hold off
    end
    set(gcf,'NextPlot','replacechildren');
    uistack(plotDefH,'top')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%LOCAL
function y = localprocsim(th,sc,P,tsd,u,strtd,d,n,par,noise)
% Carries out the simulation when there are estimated time delays.
nrtd = length(strtd);
scm = sc*ones(d,1);
scm(strtd)=zeros(nrtd,1);
scm = diag(scm);
scmm = zeros(d,1);
scmm(strtd)=ones(nrtd,1);
scmm = diag(scmm);
y{1} = sim(u,th);% The basic noise free simulation
was = ctrlMsgUtils.SuspendWarnings('MATLAB:divideByZero');
for k = 2:n
    pntd = par + scmm*P'*randn(d,1);
    if any(pntd<0)
        pntd = par + scm*P'*abs(randn(d,1));
    end
    th1 = pvset(th,'ParameterVector',pntd); %Just changing TD
    if noise(3)=='i',
        e = iddata([],sc*randn(N,ny),tsd);
        u1=[u e];
    else
        u1 = u;
    end%corr 9007
    %try
    z1 = sim(u,th1); % Noise-free simulation with nominal parameters and randomized delays
    pn = pntd + scm*P'*randn(d,1); %randomized parameters, same delay
    th2 = parset(th1,pn);
    z2 = sim(u1,th2); %Fully randomized simulation
    y0 = pvget(z1,'OutputData');y0=y0{1};
    yy = pvget(z2,'OutputData');yy=yy{1};
    
    yy = yy +(y0 - yy)/sc; % Restore to variance 1
    
    y{k} = pvset(z1,'OutputData',{yy});
    %end
    %k = k + 1;
end

