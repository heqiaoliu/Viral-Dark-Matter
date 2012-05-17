function sys = updatemodel(sys, data, OptimInfo, Estimator)
%UPDATEMODEL  Update various properties of sys after estimation.
% Update parameters, initial states, noise variance and covariance, as well
% as estimation info.

% todo: move common things into "idmodel/commonupdatemodel" after all
% objects are harmonized.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:49:05 $

option = Estimator.Options;
struc = option.struc;
x = OptimInfo.X;
Estimator.Info.Value = x; %have estimator carry the updated parameters
parinfo = Estimator.Info;

% Update parameter values
par = var2obj(sys, x, struc); % all par (fixed+free) + estimated states
sys = parset(sys, par(1:struc.Npar));

if strncmpi(struc.init,'e',1)
    % never true for frequency domain data
    if strncmpi(data.Domain,'f',1)
        ctrlMsgUtils.warning('Ident:estimation:invalidInitialState3')
    end
    
    % update "Utility" (copied from idpoly/pem)
    ut = pvget(sys.idmodel,'Utility');
    ut.x0 = par(struc.Npar+1:end);
    sys.idmodel = pvset(sys.idmodel,'Utility',ut);
end


% Update NoiseVariance
z = Estimator.Data; %call array format (nkshifted data)

fixp = struc.fixparind;
pestind = setdiff(1:struc.Npar,fixp);
npest = numel(pestind);

% Get EstimationInfo
estinfo = pvget(sys,'EstimationInfo');
if ~isstruct(estinfo)
    estinfo = struct('Method','','Status','','LossFcn',[],'FPE',[],...
        'DataName','','DataLength',[],'DataTs',[],'DataDomain','',...
        'DataInterSample','','WhyStop','','Iterations',[],...
        'InitialState','','Warning','');
end
S = utGetModelQualityInfo(sys,z,struc.Npar,npest,pestind,parinfo,Estimator.Options);

% normalize covariance if ~oeflag
if ~struc.oeflag && struc.cov
    V = real(abs(det(S.TrueLam)));
    S.CovarianceMatrix = V*S.CovarianceMatrix;
end

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
if strncmpi(data.Domain,'f',1)
    Misc = estinfo.Misc;
    estinfo = rmfield(estinfo,'Misc');
    estinfo.InitialState = Misc.init;
else
    estinfo.InitialState = struc.init;
end
estinfo.Warning = S.Warning;

if ~strcmpi(pvget(sys,'SearchMethod'), 'lsqnonlin')
    % these quantities are not available when using Optim toolbox (lsqnonlin) 
    estinfo.LastImprovement = OptimInfo.Output.LastImprovement;
    estinfo.UpdateNorm = OptimInfo.Output.UpdateNorm;
end

%sys = pvset(sys,'EstimationInfo',estinfo);
sys.idmodel = pvset(sys.idmodel,'NoiseVariance',S.NoiseVariance,...
    'CovarianceMatrix',S.CovarianceMatrix,...
    'EstimationInfo',estinfo,'InputName',pvget(data,'InputName'),...
    'OutputName',pvget(data,'OutputName'),'InputUnit',pvget(data,'InputUnit'),...
    'OutputUnit',pvget(data,'OutputUnit'),'TimeUnit',pvget(data,'TimeUnit'));


% remove extra input from model is eflag=1 (initial states were estimated)
if strncmpi(data.Domain,'f',1)
    if Misc.eflag
        nu = size(sys,'nu');
        lsub.type = '()';
        lsub.subs = {1,1:nu-1};
        sys = subsref(sys,lsub);
        sys = pvset(sys,'InitialState',Misc.init);
    end
end
