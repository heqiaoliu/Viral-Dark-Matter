function sys = updatemodel(sys, data, OptimInfo, Estimator)
%UPDATEMODEL  Update various properties of sys after estimation.
% Update parameters, initial states, noise variance and covariance, as well
% as estimation info.

% todo: move common things into "idmodel/commonupdatemodel" after all
% objects are harmonized.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:02:57 $

option = Estimator.Options;
struc = option.struc;
x = OptimInfo.X;
Estimator.Info.Value = x; %have estimator carry the updated parameters
parinfo = Estimator.Info;

estinfo = pvget(sys,'EstimationInfo');
Misc = estinfo.Misc;
estinfo = rmfield(estinfo,'Misc');

% Update parameter values
par = var2obj(sys, x, struc); % all par (fixed+free) + estimated states

ut = pvget(sys,'Utility');
nx = Misc.nx;
z = Estimator.Data;
fixp = struc.fixparind;
pestind = setdiff(1:struc.Npar,fixp);
Npar = struc.Npar;
[ny,nu] = size(sys);

% account for initial state estimation
if strcmp(sys.InitialState,'x0')
    ut.X0 = par(end-nx+1:end,1);
    par = par(1:end-nx,1);
    pestind = pestind(1:end-nx);
    sys.InitialState = 'Estimate';
    Npar = Npar-nx;
end

% account for disturbance model parameters
if strcmp(sys.DisturbanceModel,'K')
    Kvec  = par(end-nx*ny+1:end,1);
    ut.K = reshape(Kvec,nx,ny);
    par = par(1:end-nx*ny,1);
    pestind = pestind(1:end-nx*ny);
    Npar = Npar-nx*ny;
    sys.DisturbanceModel = 'Estimate';
end

npest = numel(pestind);
%sys = parset(sys, par(1:struc.Npar));

% Update EstimationInfo
S = utGetModelQualityInfo(sys,z,Npar,npest,pestind,parinfo,Estimator.Options);

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

if strcmpi(struc.init,'Model') && strcmpi(sys.MfileName,'procmod')
    estinfo.InitialState = 'Zero';
else
    estinfo.InitialState = struc.init;
end

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
    'OutputUnit',pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'),...
    'Utility',ut);

if pvget(sys,'Ts')==0 && strcmpi(sys.CDmfile,'cd') &&...
        strcmpi(pvget(sys,'DisturbanceModel'),'Estimate') % make K continuous time
    A = pvget(sys,'A');
    tsd = pvget(data,'Ts');
    tsd = tsd{1};

    Kd = ut.K;
    [nx, ny] = size(Kd);
    Ad = sample(A,zeros(nx,0),zeros(0,nx),zeros(0,0),zeros(nx,0),tsd,'zoh',1);
    [Ac, Kc] = sample(Ad,Kd,zeros(ny,nx),zeros(ny,ny),zeros(nx,0),tsd,'zoh',0);
    ut.K = Kc;
    sys = uset(sys,ut);
end
