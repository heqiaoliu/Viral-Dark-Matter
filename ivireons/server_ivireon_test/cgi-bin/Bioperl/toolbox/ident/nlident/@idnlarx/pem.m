function sys = pem(sys, data, varargin)
%IDNLARX/PEM computes the prediction error estimate of IDNLARX model.
%
%  M = PEM(DATA, M)
%
%  M: IDNLARX model object, created by IDNLARX constructor or resulting
%  from previous estimation by PEM or NLARX.
%
%  DATA: IDDATA object.
%
%  M = PEM(DATA, M, Property_1, Value_1, Property_2, Value_2,...)
%  allows to specify property values. See idprops('idnlarx') for a list
%  of settable properties. The basic algorithm properties returned by
%  get(idnlarx, 'Algorithm') are also settable.
%
%
%  See also  idnlarx, nlarx, idnlhw, nlhw, idprops, idhelp.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2008/10/02 18:53:16 $

% Author(s): Qinghua Zhang
%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

ni=nargin;
% no=nargout;
error(nargchk(2, inf, ni, 'struct'))

tstart = cputime;

dataargno = 2;
if ~isa(sys,'idnlarx')
    if isa(data,'idnlarx') && (isa(sys,'iddata') || isreal(sys))
        %     sysargno = 2;
        dataargno = 1;
        sys1 = data;
        data = sys;
        sys = sys1;
        clear sys1
    else
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','pem','idnlarx/pem')
    end
end

[ny, nu] = size(sys);

% Data-model consistency check
[data, msg] = datacheck(data, ny, nu);
error(msg);

% Copy iddata properties to model if necessary
sys = datapropcopy(sys, data);

if ~strcmpi(pvget(data, 'Domain'), 'time')
    ctrlMsgUtils.error('Ident:estimation:NLModelRequiresTimeData','IDNLARX')
end

if ni>2
    if rem(ni,2)
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','pem','idnlarx/pem')
    end
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    if ~isempty(fnames)
        algo = pvget(sys, 'Algorithm');
        algo = setmfields(algo, fnames, fvalues);
        sys = pvset(sys, 'Algorithm', algo);
    end
    
    % Set PV-pairs
    if ~isempty(pvlist)
        set(sys,  pvlist{:})
    end
end

algo = pvget(sys, 'Algorithm');

% %Add NoiseVariance to algo for getErrorAndJacobian
% algo.NoiseVariance = pvget(sys, 'NoiseVariance');

traceflag = any(strcmpi(algo.Display, {'on','full'}));

na = sys.na;
nb = sys.nb;
nk = sys.nk;

custregs = pvget(sys, 'CustomRegressors');

nlr = pvget(sys, 'NonlinearRegressors');
if ny>1 && iscellstr(nlr) && all(strcmpi('search', nlr))
    nlr = 'search';
end
if ischar(nlr) && strcmpi(nlr, 'search')
    % disable optimmessenger
    om = pvget(sys,'OptimMessenger');
    if ~isempty(om) && ishandle(om)
        om.Enabled = false;
    end
    nlr = nlregsearch(sys, data);
    % re-enable optimmessenger
    if ~isempty(om) && ishandle(om)
        om.Enabled = true;
    end
    sys.NonlinearRegressors = nlr;
end

[yvec, regmat, msg] = makeregmat(sys, data);
error(msg)

% Make the lengths of yvec and regmat equal for different outputs
[maxidelay, regdim] = reginfo(na, nb, nk, custregs);
maxd = max(maxidelay);
for ky=1:ny
    regmat{ky} = regmat{ky}((maxd-maxidelay(ky)+1):end,:);
    yvec{ky} = yvec{ky}((maxd-maxidelay(ky)+1):end);
end

% Check too few data
if size(yvec{1},1)<=max(regdim)
    ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
end

% Check absence of regressor in a channel
if any(cellfun(@isempty, regmat))
    regs = getreg(sys);
    if any(cellfun(@isempty, regs))
        ctrlMsgUtils.error('Ident:estimation:idnlarxNoRegressors2')
    end
end

% Warning about estimated model with no differentiable component
if isestimated(sys)
    nodiffatall = true;
    nlobj = sys.Nonlinearity;
    for ky=1:ny
        if isdifferentiable(nlobj(ky), true)
            nodiffatall = false;
            break
        end
    end
    if nodiffatall
        ctrlMsgUtils.warning('Ident:estimation:idnlarxNonDiffNL','pem')
        return
    end
end

simfocus = strncmpi(pvget(sys, 'Focus'), 'sim', 3);
if  simfocus && ~isdifferentiable(sys.Nonlinearity)
    ctrlMsgUtils.error('Ident:estimation:focSimNonDiffNL')
end

if ~isestimated(sys) || ~simfocus
    if simfocus && traceflag
        disp('Initialization by one-step prediction error minimization...')
    end
    
    nlr = nlregstr2ind(sys, pvget(sys, 'NonlinearRegressors'));
    sys.NonlinearRegressors = nlr; % Possibly converted from string to indices
    sys.Nonlinearity = setNonlinearRegressors(sys.Nonlinearity, nlregstr2ind(sys, nlr));
    
    %{
  %--- add optim messenger for GUI -----------
  om = pvget(sys,'OptimMessenger');
  if ~isempty(om) && isa(om,'nlutilspack.optimmessenger')
    for i = 1:length(sys.Nonlinearity)
      sys.Nonlinearity(i).OptimMessenger = om;
    end
  end
  %-------------------------------------------
    %}
    
    covmat = pvget(sys, 'CovarianceMatrix');
    algo.NoiseVariance = pvget(sys, 'NoiseVariance'); % Pass NoiseVariance to idminimizer.
    [sys.Nonlinearity, ei, nv, covmat] = estimate(sys.Nonlinearity, yvec, regmat, algo, covmat);
end

if  simfocus
    if algo.MaxIter>0
        if traceflag
            fprintf('\nSimulation error minimization...\n')
        end
        [sys, ei, nv, covmat] = focsimestimate(sys, data);
    else
        ctrlMsgUtils.warning('Ident:estimation:focSimIgnored')
    end
end

if ~isempty(nv) && all(isfinite(nv(:)))
    sys = pvset(sys,'NoiseVariance',nv);
end

syscov = pvget(sys,'CovarianceMatrix');
if (~isnumeric(syscov) && ~strcmpi(syscov,'none'))|| ~isempty(covmat)
    sys = pvset(sys,'CovarianceMatrix',covmat);
end

estinfo = sys.EstimationInfo;
if ~isempty(ei)
    fldn = fieldnames(ei);
    for kf = 1:length(fldn)
        estinfo.(fldn{kf}) = ei.(fldn{kf});
    end
end
estinfo.Status = 'Estimated by PEM';
estinfo.Method = 'PEM';
estinfo.DataName = inputname(dataargno);
estinfo.DataLength = size(data,1);
estinfo.DataTs = data.Ts;
estinfo.EstimationTime = cputime-tstart;
sys = pvset(sys, 'EstimationInfo', estinfo);

sys = timemark(sys,'l');

% This must be at the end of this function, since the other calls to pvset
% may change the value of the Estimated property.
sys.idnlmodel = pvset(sys.idnlmodel, 'Estimated', 1);

% FILE END