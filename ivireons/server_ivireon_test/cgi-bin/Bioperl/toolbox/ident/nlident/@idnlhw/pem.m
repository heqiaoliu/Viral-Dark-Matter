function sys = pem(sys, data, varargin)
%IDNLHW/PEM computes the prediction error estimate of IDNLHW model.
%
%  M = PEM(DATA, M)
%
%  M: IDNLHW model object, created by IDNLHW constructor or resulting
%  from previous estimation by PEM or NLHW.
%
%  DATA: IDDATA object.
%
%  M = PEM(DATA, M, Property_1, Value_1, Property_2, Value_2,...)
%  allows to specify property values. See idprops('idnlhw') for a
%  list of settable properties. The basic algorithm properties returned
%  by get(idnlhw, 'Algorithm') are also settable.
%
%  See also idnlhw, nlhw, idnlarx, nlarx, idprops, idhelp

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/05/23 08:02:42 $

% Author(s): Qinghua Zhang
%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

ni=nargin;
error(nargchk(2, inf, ni, 'struct'))

tstart = cputime;

dataargno = 2;
if ~isa(sys,'idnlhw')
    if isa(data,'idnlhw') && (isa(sys,'iddata') || isreal(sys))
        dataargno = 1;
        sys1 = data;
        data = sys;
        sys = sys1;
        clear sys1
    else
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','pem','idnlhw/pem')
    end
end

if ni>2
    if rem(ni,2)
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','pem','idnlhw/pem')
    end
    
    % Process InitialState
    [sys, ind] = estimateinitarg(sys, varargin);
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin(ind));
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

[ny, nu] = size(sys);

% Data-model consistency check
[data, msg] = datacheck(data, ny, nu);
error(msg)

if ~strcmpi(pvget(data, 'Domain'), 'time')
    ctrlMsgUtils.error('Ident:estimation:NLModelRequiresTimeData','IDNLHW')
end

% Copy iddata properties to model if necessary
sys = datapropcopy(sys, data);

% Check too few data
[nobs,ny,nu,nex] = size(data);
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');
nk = pvget(sys, 'nk');
if min(nobs)<=(max(sum([nb nf],2))+max(max(max([nb+nk, nf])),max(max([nf+nk, nb]))))
    if nex>1
        ctrlMsgUtils.error('Ident:estimation:tooFewSamplesMultiExp')
    else
        ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
    end
end

algo = pvget(sys, 'Algorithm');
traceflag = any(strcmpi(algo.Display, {'on','full'}));

if ~isestimated(sys)
    % Parameter initialization
    
    if traceflag
        fprintf('Initializing model parameters... \n');
    end
    sys = initnln(sys, data);
    if traceflag
        fprintf('done.\n');
    end
end

% Note: always call IterEstimation, even if algo.MaxIter=0, as
% IterEstimation sets up InitialState and other things.
sys = IterEstimation(sys, data);

estinfo = sys.EstimationInfo;
estinfo.Status = 'Estimated by PEM';
estinfo.Method = 'PEM';
estinfo.DataName = inputname(dataargno);
estinfo.EstimationTime = cputime-tstart;
sys.EstimationInfo = estinfo;

sys=timemark(sys,'l');

% Note: this must be at the end of this function, since the other calls to pvset
% may change the value of the Estimated property.
sys.idnlmodel = pvset(sys.idnlmodel, 'Estimated', 1);

%========================================================
function sys = IterEstimation(sys, data)
% Iterative Estimation

% Setup InitialState
% Note: this cannot be done in initnln, because data nex may change.
init = pvget(sys, 'InitialState');
if (ischar(init) && strcmpi(init, 'e')) ...
        || (~isempty(init) && isnumeric(init)) % previously estimated model.
    nx = size(ssdata(getlinmod(sys)),1);
    if nx>0
        %sys = pvset(sys, 'InitialState', zeros(nx, size(data,'ne')));
        x0lin = findstates(getlinmod(sys), data);
        sys = pvset(sys, 'InitialState', x0lin);
    else
        sys = pvset(sys, 'InitialState', []);
    end
else
    sys = pvset(sys, 'InitialState', []);
end

% Compute DB,DF
ncind = pvget(sys, 'ncind');
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');
nk = pvget(sys, 'nk');
[DB, DF] = diffbf(ncind, nb,nf,nk);
userdata.DB = DB;
userdata.DF = DF;

% Count parameters
[ny, nu] = size(sys);
unlobj = pvget(sys, 'InputNonlinearity');
ynlobj = pvget(sys, 'OutputNonlinearity');
numuparam = zeros(nu,1);
for ku=1:nu
    numuparam(ku) = numel(sogetParameterVector(unlobj(ku)));
end
sumnumuparam = sum(numuparam);
numyparam = zeros(ny,1);
for ky=1:ny
    numyparam(ky) = numel(sogetParameterVector(ynlobj(ky)));
end
sumnumyparam = sum(numyparam);
numlparam = sum(nf+nb-double(ncind~=0), 2); % Note: This does not count x0.
sumnumlparam = sum(numlparam);
allParamNums.sumnumuparam = sumnumuparam;
allParamNums.numyparam = numyparam;
allParamNums.sumnumyparam = sumnumyparam;
allParamNums.numlparam = numlparam;
allParamNums.sumnumlparam = sumnumlparam;
userdata.allParamNums = allParamNums;

data.UserData = userdata; % Pass to data.UserData.

Estimator = createEstimator(sys,data);
OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
sys = updatemodel(sys,OptimInfo,Estimator);

% FILE END
