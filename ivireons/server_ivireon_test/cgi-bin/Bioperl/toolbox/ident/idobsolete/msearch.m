function [Vnew,parnew,stop,delta,lambda,tlam,gamma,nbis,gnnorm,kdirout]=...
    msearch(V,z,par,struc,psi,e,delta,algorithm,lambdaold,tlamold,dispmode,gamma)
%MSEARCH   Searches for a lower value of the criterion function
%
%	[TH,ST] = msearch(Z,TH,G,LIM)
%
%	TH : New parameter giving a lower value of the criterion
%	ST=1 : No lower value of the criterion could be found.
%
%	The routine evaluates the prediction error criterion at values
%	along the G-direction, starting at TH. It is primarily intended
%	as a subroutine to MINLOOP. See PEM for an explanation of the
%	arguments.

%	L. Ljung 10-1-86,9-25-93
%	Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $ $Date: 2008/04/28 03:21:19 $

% *** Set up the model orders ***

try
    dflag = struc.dflag;
catch
    dflag = 0;
end
npar=length(par);
update=zeros(npar,1);
ind3 = algorithm.estindex;
% *** Looping, attempting to find a lower value of V along
%     the G-direction ***

pinvtol = algorithm.Advanced.Search.GnsPinvTol;
maxbis = algorithm.Advanced.Search.MaxBisections;
lmstep = algorithm.Advanced.Search.LmStep;
stepred = algorithm.Advanced.Search.StepReduction;
relimp = algorithm.Advanced.Search.RelImprovement;
direc = lower(algorithm.SearchDirection);
if strcmp(direc,'auto')
    direc = {'gns','lm','gna','gn','grad'};
elseif any(strcmp(direc,{'gns','gn','gna'}))
    direc = {direc,'grad'};
else
    direc = {direc};
end
stop = 1;
for kdir = direc
    if ~stop,break,end
    kdir = kdir{1};
    l=0;
    stop = 0;
    if dispmode==2,disp(['   Search direction: ',kdir]),end
    switch kdir
        case 'lm' % levenberg-marquard
            gdir = pinv(psi,pinvtol)*e;
            delta = delta/lmstep/2;
        case 'gns'
            gdir = pinv(psi,pinvtol)*e;
            
        case 'gna'% Ninness-Wills adaptive gns
            [u,s,v]=svd(psi);s = diag(s);
            
            rbn=sum(s>gamma*max(s));
            gdir = (v(:,1:rbn)*((u(:,1:rbn)'*e)./s(1:rbn)));
        case 'gn'
            gdir = psi\e;
        case 'grad'
            gdir = psi'*e*npar/norm(psi);
    end
    gnnorm=norm(gdir);
    if strcmp(struc.type,'ssfree')
        update=gdir;par=zeros(size(gdir));npar=length(par);
    else
        update(ind3) = gdir;
    end
    parnew = par+update;
    if isfield(struc,'bounds')
        bounds = struc.bounds;
        parnew(bounds(:,1)) = min(max(parnew(bounds(:,1)),bounds(:,2)),bounds(:,3));
    end
   
    [lambda,tlam] = gnnew(z,parnew,struc,algorithm);

    Vnew=real(det(lambda));
    if Vnew<0,Vnew=inf;end
    while ((Vnew - V) >= -V*relimp)& l<maxbis
        switch kdir
            case 'lm'
                if l>0
                    delta = delta*lmstep;
                end

                if strcmp(struc.type,'ssfree')
                    update = pinv([psi;delta*eye(npar)])*[e;zeros(npar,1)];
                else
                    update(ind3) = pinv([psi;delta*eye(length(ind3))])*[e;zeros(length(ind3),1)];
                end
            case {'gna','gns','gn','grad'}
                update = update/stepred;
        end
        parnew = par+update;
        if isfield(struc,'bounds')
            bounds = struc.bounds;
            parnew(bounds(:,1)) = min(max(parnew(bounds(:,1)),bounds(:,2)),bounds(:,3));
        end
        
        [lambda,tlam] = gnnew(z,parnew,struc,algorithm);
        Vnew=real(det(lambda));
        if Vnew<=0,Vnew=inf;end
        l = l+1;
        if l==maxbis, stop = 1;end
    end
    kdirout =kdir;
end % kdir
if l == 0,
    gamma = max(gamma/(2*lmstep),sqrt(eps));
elseif l>5
    gamma = min(lmstep*gamma,1);
end

if dispmode==2  % Give status information to the screen
    disp(['   Bisected search vector ',int2str(l),' times']),
end
nbis = l;
if stop,parnew=par;Vnew=V;lambda=lambdaold;tlam=tlamold;end






