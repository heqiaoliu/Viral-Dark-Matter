function sys = updatemodel(sys, data, OptimInfo, Estimator)
%UPDATEMODEL  Update various properties of sys after estimation.
% Update parameters, initial states, noise variance and covariance, as well
% as estimation info.

% todo: move common things into "idmodel/commonupdatemodel" after all
% objects are harmonized.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/08/01 12:22:52 $

option = Estimator.Options;
struc = option.struc;
x = OptimInfo.X;
Estimator.Info.Value = x; %have estimator carry the updated parameters
parinfo = Estimator.Info;
estinfo = pvget(sys,'EstimationInfo');
Misc = estinfo.Misc;
estinfo = rmfield(estinfo,'Misc');

% Update parameter values
if option.ComputeProjFlag 
    par = LocalGetModelPar(struc,Misc);
    %if struc.cov
    %    sys = pvset(sys,'CovarianceMatrix',[]);
    %end
    parinfo.Value = [];
else
    par = var2obj(sys, x, struc); % all par (fixed+free) + estimated states
end
%sys = parset(sys, par(1:struc.Npar));

% parameterization specified by user was Free, but it was changed to
% Structured (when SearchMethod = lsqnonlin etc)
if Misc.wasFree
    sys = pvset(sys,'SSParameterization','Free');
end

% Update NoiseVariance
z = Estimator.Data;

fixp = struc.fixparind;
pestind = setdiff(1:struc.Npar,fixp);
npest = numel(pestind);

% Update EstimationInfo
S = utGetModelQualityInfo(sys,z,struc.Npar,npest,pestind,parinfo,Estimator.Options);

% todo: realflag? see minloop end

% Set EstimationInfo
%algo = pvget(sys, 'Algorithm');
estinfo.Method = sprintf('PEM using SearchMethod = %s',option.SearchMethod);
estinfo.Status = 'Estimated model (PEM)';
estinfo.LossFcn = S.LossFcn;
estinfo.FPE = S.FPE;
estinfo.DataName = data.Name;
estinfo.DataLength = sum(Estimator.Options.DataSize);
estinfo.DataTs = data.Ts;
estinfo.DataDomain = data.Domain;
estinfo.DataInterSample = pvget(data,'InterSample');
estinfo.WhyStop = Estimator.whyStop(OptimInfo.ExitFlag);
estinfo.Iterations = OptimInfo.Output.iterations;
estinfo.InitialState = struc.init;

estinfo.Warning = S.Warning;

if ~strcmpi(pvget(sys,'SearchMethod'), 'lsqnonlin')
    % these quantities are not available when using Optim toolbox (lsqnonlin) 
    estinfo.LastImprovement = OptimInfo.Output.LastImprovement;
    estinfo.UpdateNorm = OptimInfo.Output.UpdateNorm;
end

%todo: if this applies to all CT models (confirm), move the calculation to
%utGetModelQualityInfo
Ts = pvget(sys,'Ts');
Tsdata = pvget(data,'Ts'); 
if Ts==0 && Tsdata{1}>0
    lamscale = Tsdata{1}; 
else
    lamscale = 1;
end

sys.idmodel = pvset(sys.idmodel,'NoiseVariance',lamscale*S.NoiseVariance,...
    'CovarianceMatrix',S.CovarianceMatrix,'ParameterVector',par,...
    'EstimationInfo',estinfo,'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',pvget(data,'InputUnit'),...
    'OutputUnit',pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'));

if option.ComputeProjFlag || Misc.wasFree
    % Restore nk
    if any(Misc.nks>0)
        sys = pvset(sys,'nk',Misc.nk);
    end

    % Estimate Covariance
    if struc.cov
        % since covariance matrix is not well defined for free
        % parameterization, compute one for a canonical form and store it
        % internally for computing confidence intervals etc
        was = warning('off'); [lw,lwid] = lastwarn; %#ok<WNOFF>
        try
            sys = LocalAddCovarianceModel(sys,data);
        catch
            warning(was);
            %clc, disp(lasterr) %todo: remove this
        end
        warning(was); lastwarn(lw,lwid)
    end
end

if Misc.autoflag
    %todo: sys=pvset(sys,'InitialState','Auto'); may reduce the number of
    %parameters! see, e.g., time series estimation
    sys.InitialState = 'Auto';
end

%--------------------------------------------------------------------------
function par = LocalGetModelPar(struc,Misc)
%get full parameter vector for ssfree model

nu = struc.nu;
nk = Misc.nk;

% compose parameter vector
at = struc.a.';
bt = struc.b.';
ct = struc.c.';
dt = struc.d;
kt = struc.k.';
dkx = struc.dkx;
par = [at(:);bt(:);ct(:)];
dtt = [];
for ku = 1:nu
    if nk(ku)==0
        dtt =[dtt,dt(:,ku)];
    end 
end
if ~isempty(dtt)
    dtt = dtt.';
    par = [par;dtt(:)];
end

if  dkx(2)
    par = [par; kt(:)];
end
if dkx(3)
    par = [par;struc.x0]; 
end

%--------------------------------------------------------------------------
function m = LocalAddCovarianceModel(m,data)
% compute a conanoical form so that covariance info is available

m2 = m; 
ut = pvget(m2,'Utility');

if isfield(ut,'Pmodel')
    ut.Pmodel = [];
end
m2 = uset(m2,ut); % all this to really recompute can form
m2 = pvset(m2,'SSParameterization','Canonical','CovarianceMatrix',[]);
idmod = m2.idmodel;
%alg = idmod.Algorithm;
maxi = pvget(idmod,'MaxIter');
tr = pvget(idmod,'Display');
%alg.MaxIter = -1;
%alg.Display = 'Off';
idmod = pvset(idmod,'MaxIter',-1,'Display','Off');
m2.idmodel = idmod;
m2 = pem(data,m2);
m2 = pvset(m2,'MaxIter',maxi,'Display',tr);

utility = pvget(idmod,'Utility');
utility.Pmodel = m2;

idmod = m.idmodel;
idmod = pvset(idmod,'Utility',utility);
m.idmodel = idmod;
