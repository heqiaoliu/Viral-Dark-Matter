function thd=d2caux(thc,method,varargin)
%D2CAUX Helper function to IDMODEL/D2C.

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.7 $ $Date: 2009/01/20 15:32:31 $

errm = struct('identifier','Ident:transformation:d2cSyntax',...
    'message','Incorrect property-value specification for the "d2c" command. Type "help idmodel/d2c" for more information.');

nv = length(varargin);
if fix(nv/2)~=nv/2
    error(errm);
end
delays = 1;
%cov = 1;
for kk = 1:2:nv
    if ~ischar(varargin{kk})
        error(errm)
    elseif lower(varargin{kk}(1))=='c'
        if lower(varargin{kk+1}(1))=='n'
            %cov = 0;
            thc = pvset(thc,'CovarianceMatrix','None');
        end
    elseif lower(varargin{kk}(1))=='i'
        if varargin{kk+1}(1)==0
            delays = 0;
        end
    else
        error(errm)
    end
end
%{
P = pvget(thc,'CovarianceMatrix');
if ischar(P) || isempty(P)
    cov = 0;
end
%}

Inpd = pvget(thc,'InputDelay');
Told = pvget(thc.idmodel,'Ts'); 
if Told==0,
    ctrlMsgUtils.error('Ident:transformation:FirstArgDiscreteModel','d2c')
end
utflag = 0;
if  strcmp(thc.SSParameterization,'Free')
    % In this case Pmodel has no value, since it will lose its
    % covariance information. Instead create Idpoly, if necessary,
    % unless covariance = 'none'
    thc = setcov(thc);
    ut = pvget(thc,'Utility');
    utflag = 1;
    if isfield(ut,'Pmodel')
        ut.Pmodel = [];
        thc = pvset(thc,'Utility',ut);
    end
end
lamscale = Told; 
[ny,nu] = size(thc);
%p = pvget(thc.idmodel,'ParameterVector');
%covp = pvget(thc.idmodel,'CovarianceMatrix');
lam = pvget(thc.idmodel,'NoiseVariance');
nk = pvget(thc,'nk');
if isempty(nk)
    delays = 0;
end

if delays && any(nk>1)
    nknew = nk>=1;
    thc = pvset(thc,'nk',nknew);
    adjnk = nk-nknew;
else
    adjnk = zeros(1,nu);
end
[A,B,C,D,K,X0]=ssdata(thc); 
%nx = size(A,1);
%[ny,nu] = size(D);
[A,B,Cc,D,K,Ls] = idsample(A,B,C,D,K,Told,method(1),0);
thd = pvset(thc,'SSParameterization','Free');
if norm(D)>0
    thd=pvset(thd,'Ds',NaN*ones(size(D)));
end
thd = pvset(thd,'A',A,'B',B,'C',C,'D',D,'K',K,'NoiseVariance',lamscale*Ls*lam*Ls',...
    'Ts',0,'CovarianceMatrix',[],...
    'InputDelay',Told*(adjnk+Inpd'));
if utflag
    thd = uset(thd,ut);
end
if strcmp(thc.SSParameterization,'Canonical')
    thd = pvset(thd,'SSParameterization','Canonical');
end

%%%% Now for the hidden models

thd = sethidmo(thd,'d2c',varargin{:});
