function [pnstruct, props, defvals, asgnvals] = idnlgreydef(type)
%IDNLGREYDEF  Returns the basic definitions of the structures of an
%             IDNLGREY object. PRIVATE FUNCTION.
%
%   [PNSTRUCT, PROPS, DEFVALS, ASGNVALS] = IDNLGREYDEF(TYPE);
%
%   TYPE specifies the desired IDNLGREY structure. It can be 'Algorithm',
%   'SimulationOptions', ''GradientOptions', 'Advanced' or
%   'EstimationInfo'.
%
%   The outputs are as follows.
%
%   PNSTRUCT: Type-specific name-value structure.
%   PROPS   : Type-specific property names. It is a column-oriented
%             cell array of strings.
%   DEFVALS : Type-specific values. It is a column-oriented cell array.
%   ASGNVALS: Type-specific definitions of the type of data that can
%             be assigned to the respective fields of the specified
%             structure. It is a cell array of cell arrays of strings.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $ $Date: 2009/03/09 19:14:59 $
%   Written by Peter Lindskog.

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));
nout = nargout;

% Check TYPE.
if ~ischar(type)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreydefCheck1')
end

% Retrieve TYPE-specific data.
switch type
    case 'Algorithm'
        props   = {'SimulationOptions'   ... % Parameters of the differential/difference equation solvers.
            'GradientOptions'     ... % Parameters of the gradient computation algorithms.
            'SearchMethod'        ... % Search strategy to use in the iterative search.
            'Criterion'           ... % Minimization criterion - determinant or trace.
            'Weighting'           ... % Weighting outputs relative to each other
            'MaxIter'             ... % Maximum number of iterations to perform.
            'Tolerance'           ... % Tolerance for terminating the iterative search.
            'LimitError'          ... % For limiting the influence of large residuals (robustification).
            'Display'               ... % Send information about the search to the screen or not.
            'Advanced'            ... % A structure that contains further estimation related algorithmic properties.
            };
        defvals = {idnlgreydef('SimulationOptions')   ... % SimulationOptions.
            idnlgreydef('GradientOptions')     ... % GradientOptions.
            'Auto'                             ... % SearchMethod.
            'trace'                            ... % Criterion.
            []                                 ... % Weighting.
            20                                 ... % MaxIter.
            0.01                               ... % Tolerance.
            0                                  ... % LimitError.
            'off'                              ... % Display.
            idnlgreydef('Advanced')            ... % Advanced.
            };
        pnstruct = cell2struct(defvals, props, 2);
        if (nout > 3)
            asgnvals = {{'Struct (see ''SimulationOptions'')'};        ... % SimulationOptions.
                {'Struct (see ''GradientOptions'')'};          ... % GradientOptions.
                {'Auto' 'gn' 'gna' 'grad' 'lm' 'lsqnonlin'};   ... % SearchMethod.
                {'det' 'trace'};                               ... % Criterion.
                {'Positive semi-definite matrix'};             ... % Weighting.
                {'Positive integer'};                          ... % MaxIter.
                {'Positive double'};                           ... % Tolerance.
                {'Positive double'};                           ... % LimitError.
                {'off' 'on' 'full'};                           ... % Display.
                {'Structure (see ''Advanced'')'}               ... % Advanced.
                };
        end
    case 'SimulationOptions'
        props   = {'Solver'      ... % Differential/difference equation solver to use.
            'RelTol'      ... % Relative error tolerance of variable-step ODE solver.
            'AbsTol'      ... % Absolute error tolerance of variable-step ODE solver.
            'MinStep'     ... % Lower bound of the step size used by variable-step ODE solvers.
            'MaxStep'     ... % Upper bound of the step size used by variable-step ODE solvers.
            'InitialStep' ... % Initial step size used by variable-step ODE solvers.
            'MaxOrder'    ... % Maximum order of ode15s.
            'FixedStep'   ... % Fixed step size.
            };
        defvals = {'Auto'   ... % Solver.
            1e-3     ... % RelTol.
            1e-6     ... % AbsTol.
            'Auto'   ... % MinStep.
            'Auto'   ... % MaxStep.
            'Auto'   ... % InitialStep.
            5        ... % MaxOrder.
            'Auto'   ... % FixedStep.
            };
        pnstruct = cell2struct(defvals, props, 2);
        if (nout > 3)
            asgnvals = {{'Auto' 'ode113' 'ode15s' 'ode23' 'ode23s' 'ode45'   ... % Solver, adaptive ODEs.
                'ode5' 'ode4' 'ode3' 'ode2' 'ode1'                  ... % Solver, fixed ODEs.
                'FixedStepDiscrete'};                               ... % Solver, difference equations.
                {'Positive double'};                                 ... % RelTol.
                {'Positive double'};                                 ... % AbsTol.
                {'Auto' 'Positive double'};                          ... % MinStep.
                {'Auto' 'Positive double'};                          ... % MaxStep.
                {'Auto' 'Positive double'};                          ... % InitialStep.
                {1 2 3 4 5};                                         ... % MaxOrder.
                {'Auto' 'Positive double'}                           ... % FixedStep.
                };
        end
    case 'GradientOptions'
        props   = {'DiffScheme'      ... % Approximation of derivatives: central, forward, backward or auto approximation.
            'DiffMinChange'   ... % Used for computing numerical derivatives.
            'DiffMaxChange'   ... % Used for computing numerical derivatives.
            'GradientType'    ... % Method to use when computing the numerical derivatives.
            };
        defvals = {'Auto'           ... % DiffScheme.
            0.01*sqrt(eps)   ... % DiffMinChange.
            Inf              ... % DiffMaxChange.
            'Auto'           ... % GradientType.
            };
        pnstruct = cell2struct(defvals, props, 2);
        if (nout > 3)
            asgnvals = {{'Auto' 'Central approximation'                       ... % DiffScheme.
                'Forward approximation' 'Backward approximation'};   ...
                {'Positive double'};                                  ... % DiffMinChange.
                {'Positive double'};                                  ... % DiffMaxChange.
                {'Auto' 'Basic' 'Refined'}                            ... % GradientType.
                };
        end
    case 'Advanced'
        props   = {'GnPinvConst'      ... % Multiplying factor used to compute tolerance for singular value computations.
            'MinParChange'     ... % Minimum allowed parameter update in each iteration.
            'StepReduction'    ... % Decrease direction factor used in the line search algorithm (G, GN, and GNS).
            'MaxBisections'    ... % Maximum number of iterations performed by the line search algorithm.
            'LMStartValue'     ... % The starting value of mu in the LM algorithm.
            'LMStep'           ... % Factor for updating mu in the LM algorithm.
            'RelImprovement'   ... % Stop iterating when the relative improvement is less than RelImprovement.
            'MaxFunEvals'      ... % Maximum number of function evaluations to perform in a simulation call.
            };
        defvals = {1e4      ... % GnPinvConst.
            1e-16    ... % MinParChange.
            2        ... % StepReduction.
            25       ... % MaxBisections.
            0.001    ... % LMStartValue.
            10       ... % LMStep.
            0        ... % RelImprovement.
            Inf      ... % MaxFunEvals.
            };
        pnstruct = cell2struct(defvals, props, 2);
        if (nout > 3)
            asgnvals = {{'Positive double'};                           ... % GnPinvConst.
                {'Positive double'};                           ... % MinParChange.
                {'Positive double, strictly larger than 1'};   ... % StepReduction.
                {'Positive integer'};                          ... % MaxBisections.
                {'Strictly positive double'};                  ... % LMStartValue.
                {'Positive double, strictly larger than 1'};   ... % LMStep.
                {'Positive double'};                           ... % RelImprovement.
                {'Strictly positive integer'};                 ... % MaxFunEvals.
                };
        end
    case 'EstimationInfo'
        props   = {'Status'            ... % Describes whether the model is estimated or not.
            'Method'            ... % Describes how the model was estimated.
            'LossFcn'           ... % The value of the loss function, det(sum epsi*epsi^T).
            'FPE'               ... % The Value of Akaike's Final Prediction Error.
            'DataName'          ... % Name of the data set used for parameter estimated.
            'DataLength'        ... % Length of the data set used for parameter estimation.
            'DataTs'            ... % Sampling instances of the estimation data.
            'DataDomain'        ... % Domain of the data.
            'DataInterSample'   ... % The intersample behavior of the input data (zoh or foh).
            'WhyStop'           ... % The reason for terminating the iterative search.
            'UpdateNorm'        ... % The norm of the search vector (GN-vector).
            'LastImprovement'   ... % The criterion improvement in the last iteration, measured in %.
            'Iterations'        ... % Number of iterations performed before termination.
            'InitialGuess'      ... % Information about InitialGuess of InitialStates and Parameters.
            'Warning'           ... % Information about warning messages.
            'EstimationTime'    ... % Elapsed time for the estimation.
            };
        defvals = {'Not estimated'                 ... % Status.
            ''                              ... % Method.
            []                              ... % LossFcn.
            []                              ... % FPE.
            ''                              ... % DataName.
            []                              ... % DataLength.
            []                              ... % DataTs.
            'Time'                          ... % DataDomain.
            ''                              ... % DataInterSample.
            ''                              ... % WhyStop.
            []                              ... % UpdateNorm.
            []                              ... % LastImprovement.
            []                              ... % Iterations.
            struct('InitialStates', {{}},   ...
            'Parameters', {{}})      ... % InitialGuess.
            ''                              ... % Warning.
            []                              ... % EstimationTime.
            };
        pnstruct = cell2struct(defvals, props, 2);
        if (nout > 3)
            asgnvals = {{'Not estimated' 'Estimated model (PEM)'                  ... % Status.
                'Model modified after last estimate'};                   ...
                {'char'};                                                 ... % Method.
                {'Positive double'};                                      ... % LossFcn.
                {'Positive double'};                                      ... % FPE.
                {'char'};                                                 ... % DataName.
                {'Positive integer'};                                     ... % DataLength.
                {'Strictly positive double'                               ... % DataTs. Data from all experiment should be equally sampled.
                'Cell array with Ne strictly positive doubles'};         ...
                {'Time' 'Frequency'};                                     ... % DataDomain. (Only Time is supported for now.)
                {'zoh' 'foh'                                              ... % DataInterSample. Data from all experiment should be sampled in the same way.
                'Cell array with Ne intersample entries'};               ...
                {'Near (local) minimum, (norm(g) < tol)'                  ... % WhyStop.
                'Change in parameters was less than the specified tolerance'             ...
                'Change in cost was less than the specified tolerance'                   ...
                'Magnitude of search direction was smaller than the specified tolerance' ...
                'Maximum number of iterations reached'                                   ...
                'Algorithm was terminated prematurely by the user'                       ...
                'Problem is infeasible: SVD of Jacobian failed'                          ...
                'Number of function evaluations exceeded MaxFunEvals'                    ...
                'No improvement along the search direction with line search'};           ...
                {'Positive double'};                                      ... % UpdateNorm.
                {'Percentage'};                                           ... % LastImprovement.
                {'Positive integer'};                                     ... % Iterations.
                {'Structure with fields InitialStates and Parameters'};   ... % InitialGuess.
                {'None' 'Covariance matrix ill-conditioned'};             ... % Warning.
                {'Positive double'}                                       ... % EstimationTime.
                };
        end
    otherwise
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreydefCheck1')
end

% if needed, change from row to column oriented props and defvals outputs.
if (nout > 1)
    props = props';
    if (nout > 2)
        defvals = defvals';
    end
end