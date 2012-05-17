function  [nlobj, ei, nv, covmat] = estimate(nlobj, yvec, regmat, algo, covmat)
%ESTIMATE estimates nonlinearity from data.
%
%  NLFUN = estimate(NLFUN, Y, REGMAT) does the estimation with the regression matrix
%  REGMAT and the desired output Y.
%
% Note: This function handles IDNLFUN object array.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2008/10/02 18:53:26 $

% Author(s): Qinghua Zhang

error(nargchk(5,5,nargin,'struct'))

if ~isa(nlobj,'idnlfun')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','estimate','IDNLFUN')
end

% yvec and regmat should be ny-by-1 cell arrays
if ~iscell(yvec)
    yvec = {yvec};
end
if ~iscell(regmat)
    regmat = {regmat};
end
if ~(all(all(cellfun(@isreal, yvec))) && all(cellfun(@ndims, yvec)==2))
    ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck1')
end
if ~(all(all(cellfun(@isreal, regmat))) && all(cellfun(@ndims, regmat)==2))
    ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck2')
end

ny = numel(nlobj);

% Output dimension check
if ny~=numel(regmat)
    ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck3')
end

% Input dimension check
for ky=1:ny
    nlky = getcomp(nlobj, ky);
    rdim = regdimension(nlky);
    if rdim>0 && rdim~=size(regmat{ky},2)
        % Reset initialization and retry
        nlky = initreset(nlky);
        rdim = regdimension(nlky);
        if rdim>0 && rdim~=size(regmat{ky},2)
            ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck4')
        else
            nlobj = setcomp(nlobj, ky, nlky);
        end
    end
end

if ny>1 && (isany(nlobj, 'treepartition') ||isany(nlobj, 'neuralnet'))
    % Component-wise estimation (nlobj is necessarily idnlfunVector)
    
    Wt = algo.Weighting;
    if ~isequal(Wt,eye(size(Wt)))
        ctrlMsgUtils.warning('Ident:estimation:WeightingNeuralTree')
    end
    
    for ky=1:ny
        nlobj.ObjVector{ky} = estimate(nlobj.ObjVector{ky}, yvec(ky), regmat(ky), algo, 'none');
    end
    [ei, nv, covmat] = modelinfo(nlobj, {yvec, regmat}, algo, covmat);
    return
end

initializedflag = isinitialized(nlobj);
iterativeflag = isdifferentiable(nlobj) && algo.MaxIter>0;

% Initialization.
% Note: each component of the object array nlobj is (re)initialized or not
% depending on its situation.
nlobj = initialize(nlobj,yvec,regmat,algo);

% Process wavenet case
WavenetIterRule = true; % by default
if isall(nlobj, 'wavenet')
    WavenetIterRule = initializedflag;
    switch lower(strtrim(algo.IterWavenet))
        case 'on'
            WavenetIterRule = true;
        case 'off'
            WavenetIterRule = false;
    end
elseif isany(nlobj, 'wavenet')
    % Note: mixture with treepartition or neuralnet cannot arrive here.
    if iterativeflag && strcmpi(strtrim(algo.IterWavenet), 'off')
        ctrlMsgUtils.warning('Ident:estimation:IterWavenetMixedNL')
    end
end

if  iterativeflag && WavenetIterRule
    % Iterative optimization
    
    % Make use of the optim engine
    Estimator = createEstimator(nlobj, {yvec, regmat}, algo);
    OptimInfo = minimize(Estimator);
    
    % update the model with the set of new values for states and parameters
    [nlobj, S, ei] = updatemodel(nlobj ,OptimInfo,Estimator, algo, covmat);
    nv = S.NoiseVariance;
    covmat = S.CovarianceMatrix;
    
elseif nargout>1
    % Absence of iterative optimization
    % Get ei, nv and covmat
    [ei, nv, covmat] = modelinfo(nlobj, {yvec, regmat}, algo, covmat);
end

% FILE END
