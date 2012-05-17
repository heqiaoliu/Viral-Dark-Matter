function nlsys = updatemodel(nlsys, optiminfo, estimator)
%UPDATEMODEL  Update various properties of nlsys after estimation. PRIVATE
%   FUNCTION.
%
%   NLSYS = UPDATEMODEL(NLSYS, OPTIMINFO, ESTIMATOR);
%
%   NLSYS is the IDNLGREY model.
%
%   OPTIMINFO contains information about the minimization run.
%
%   ESTIMATOR holds information about the estimation algorithm used.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $ $Date: 2008/01/15 18:52:54 $

% Check that the function is called with three arguments.
error(nargchk(3, 3, nargin, 'struct'));

% Get initial parameters and states values.
parinit = {nlsys.Parameters.Value};
x0init = cat(1, nlsys.InitialStates.Value);

% Get estimated parameters and initial states.
[x0, par] = var2obj(nlsys, optiminfo.X);

% Update parameter values and initial states.
if ~isempty(par)
    [nlsys.Parameters.Value] = par{:};
end
if ~isempty(x0)
    x0tmp = mat2cell(x0, ones(size(x0, 1), 1), size(x0, 2));
    [nlsys.InitialStates.Value] = x0tmp{:};
end

% Determine NoiseVariance, CovarianceMatrix, LossFcn, FPE and Warning
% information.
np = size(nlsys, 'Np');
npest = np - size(nlsys, 'Npf');
pestind = [];
for k = 1:length(nlsys.Parameters)
    idx = ~nlsys.Parameters(k).Fixed;
    pestind = [pestind; idx(:)];
end
pestind = find(pestind);
S = utGetModelQualityInfo(nlsys, estimator.Data, np, npest, pestind, ...
                          estimator.info, estimator.Options);
                      
% Update NoiseVariance and if so specified CovarianceMatrix.
nlsys = pvset(nlsys, 'NoiseVariance', S.NoiseVariance);
if isnumeric(S.CovarianceMatrix)
    nlsys = pvset(nlsys, 'CovarianceMatrix', S.CovarianceMatrix);
end

% Get and set EstimationInfo.
EstimationInfo = nlsys.EstimationInfo;
EstimationInfo.Status = 'Estimated model (PEM)';
if strcmpi(nlsys.Algorithm.SimulationOptions.Solver, 'Auto')
    if ((pvget(nlsys, 'Ts') > 0) || (nlsys.Order.nx == 0))
        Solver = 'FixedStepDiscrete';
    else
        Solver = 'ode45';
    end
else
    Solver = nlsys.Algorithm.SimulationOptions.Solver;
end
if strcmpi(nlsys.Algorithm.SearchMethod, 'Auto')
    if isoptiminstalled
        SearchMethod = 'lsqnonlin';
    else
        SearchMethod = 'gn, lm, gna, grad';
    end
else
    SearchMethod = nlsys.Algorithm.SearchMethod;
end
EstimationInfo.Method = ['Solver: ' Solver '; Search: ' SearchMethod];
EstimationInfo.LossFcn = S.LossFcn;
EstimationInfo.FPE = S.FPE;
EstimationInfo.DataName = pvget(estimator.Data, 'Name');
EstimationInfo.DataLength = sum(size(estimator.Data, 'N'));
EstimationInfo.DataTs = pvget(estimator.Data, 'Ts');
EstimationInfo.DataInterSample = pvget(estimator.Data, 'InterSample');
EstimationInfo.WhyStop = estimator.whyStop(optiminfo.ExitFlag);
if ~strcmpi(SearchMethod, 'lsqnonlin')
    % These quantities are not available when using lsqnonlin.
    EstimationInfo.UpdateNorm = optiminfo.Output.UpdateNorm;
    EstimationInfo.LastImprovement = optiminfo.Output.LastImprovement;
end

EstimationInfo.Iterations = optiminfo.Output.iterations;
EstimationInfo.InitialGuess.Parameters = parinit;
EstimationInfo.InitialGuess.InitialStates = x0init;
EstimationInfo.Warning = S.Warning;

% Update the Estimated private property.
nlsys = pvset(nlsys, 'Estimated', 1);

% Update EstimationInfo.
nlsys.EstimationInfo = EstimationInfo;