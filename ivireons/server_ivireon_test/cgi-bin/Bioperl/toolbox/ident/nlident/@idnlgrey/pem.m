function nlsys = pem(data, nlsys, varargin)
%PEM  Computes the prediction error estimate of an IDNLGREY model.
%
%         NLSYS = PEM(DATA, NLSYS);
%         NLSYS = PEM(DATA, NLSYS, 'PROPERTY1', 'VALUE1', ..., 'PROPERTYN',
%                     'VALUEN');
%
%   The input-output arguments are as follows.
%
%   DATA holds the data used for estimation and should be given as an
%   IDDATA object or as an output-input matrix [Y1 ... Yn U1 ... Um]. See
%   help IDDATA or type IDPROPS IDDATA.
%
%   NLSYS is an IDNLGREY object that defines the model structure and
%   controls how the model is going to be estimated. See help IDNLGREY.
%
%   NLSYS is the estimated model stored as an IDNLGREY object. The function
%   estimates the parameter vector, the noise covariance matrix and, if so
%   specified, the covariance matrix of the parameters. Structure
%   information about the estimation process as such is also stored. For
%   the exact format on IDNLGREY objects, type IDPROPS IDNLGREY.
%
%   Additional property-value pairs can be defined. The assignable
%   properties are the ones returned by get(idnlgrey) and the basic
%   algorithm properties returned by get(idnlgrey, 'Algorithm'). The latter
%   properties should be specified without an algorithm prefix, i.e.,
%   Algorithm.MaxIter is specified using MaxIter as property name. For more
%   information about IDNLGREY properties, type IDPROPS IDNLGREY. For more
%   information about the basic IDNLGREY algorithm properties, type
%   IDPROPS IDNLGREY ALGORITHM.
%
%   The properties Parameters and InitialStates can be specified through
%   structure arrays (see IDPROPS IDNLGREY PARAMETERS or IDPROPS IDNLGREY
%   INITIALSTATES). The following short form values of Parameters and
%   InitialStates are also supported:
%      'zero'       : use zero values on all parameters or initial states
%                     and keep these fixed (the corresponding Fixed
%                     property of NLSYS is thus ignored).
%      'fixed'      : fix all parameters or initial states and use the
%                     corresponding property values of NLSYS.
%      'estimate'   : estimate all parameters or initial states starting
%                     off with the corresponding property values of NLSYS.
%      'model'      : use the parameters or initial states of NLSYS. Only
%                     the non-fixed parameters and initial states of NLSYS
%                     will be estimated (default).
%      vector/matrix: a vector of appropriate length is used as (initial)
%                     values of the parameters or the initial states. For
%                     parameters, the vector form can only be used if all
%                     parameters are scalars (otherwise use cell arrays).
%                     For multiple experiment DATA, initial states may be a
%                     matrix whose columns give different initial states
%                     for each experiment. This option requires values such
%                     that the Minimum and Maximum constraints of the
%                     corresponding property of NLSYS are fulfilled. Only
%                     the non-fixed parameters and initial states of NLSYS
%                     will be estimated.
%      cell array   : a cell array of scalars, vectors and matrices. For
%                     parameters, it should be a Npo-by-1 cell array
%                     containing finite real scalars, finite real vectors
%                     or finite real 2-dimensional matrices. For initial
%                     states, it should be a Nx-by-1 cell array with
%                     finite real vectors of size 1-by-Ne (the number of
%                     experiments). This option requires values such
%                     that the Minimum and Maximum constraints of the
%                     corresponding property of NLSYS are fulfilled. Only
%                     the non-fixed parameters and initial states of NLSYS
%                     will be estimated.
%
%   Example:
%       % A. Load and create DC-motor data set.
%       load(fullfile(matlabroot, 'toolbox', 'ident', 'iddemos', 'data', 'dcmotordata'));
%       z = iddata(y, u, 0.1, 'Name', 'DC-motor');
%       % B. Create and initialize DC-motor IDNLGREY model object.
%       Order         = [2 1 2];           % Model orders [ny nu nx].
%       Parameters    = [1; 0.28];         % Initial parameters. Np = 2.
%       InitialStates = [0; 0];            % Initial initial states.
%       nlgr = idnlgrey('dcmotor_m', Order, Parameters, InitialStates, 0, ...
%                       'Name', 'DC-motor');
%       % C. Estimate the parameters of the DC-motor model object.
%       nlgr = pem(z, nlgr, 'Display', 'Full');
%       % D. Reestimate the parameters using another initial guess of the
%       %    parameter values.
%       nlgr = pem(z, nlgr, 'Parameters', [0.5; 0.5]);
%       % E. Continue the parameter estimation, starting off with the
%       %    parameter values obtained in the previous call to pem. In
%       %    addition, estimate the initial states.
%       nlgr = pem(z, nlgr, 'InitialStates', 'e');
%
%   See also IDNLGREY/IDNLGREY, IDDATA/IDDATA, IDNLGREY/PREDICT,
%   IDNLGREY/PE, IDNLGREY/SIM, IDNLMODEL/SET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $ $Date: 2008/10/02 18:53:56 $
%   Written by Peter Lindskog.

% Retrieve the number of inputs.
nin = nargin;

% Check that the function is called with at least 2 arguments.
error(nargchk(2, Inf, nin, 'struct'));

% Remember start time.
StartTime = cputime;

% Allow DATA and NLSYS arguments to be swapped.
if (isa(nlsys, 'iddata') || isa(nlsys, 'cell') || isnumeric(nlsys))
    datatmp = nlsys;
    nlsys = data;
    data = datatmp;
end

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:InvalidSyntax','pem','idnlgrey/pem')
end

% Handle varargin.
if (nin > 2)
    % Allow short forms on Parameters and InitialStates.
    [errmsg, varargin] = checkgetShortForm(nlsys, varargin{:});
    error(errmsg);
    
    % Set the specified properties.
    nlsys = setext(nlsys, varargin{:});
end

% Check NLSYS.
error(isvalid(nlsys, 'OnlyFileName'));

% Check that DATA is an IDDATA object or a matrix of appropriate size.
[errmsg, data, nlsys, warningtxt] = checkgetiddata(data, nlsys, 'pem');
error(errmsg)

% Get InitialStates from NLSYS and check that it is consistent with DATA.
ne = size(data, 'ne');
[errmsg, InitialStates] = checkgetx0(nlsys.InitialStates, 'Model', ne, true);
error(errmsg);

nlsys.InitialStates = InitialStates;

% Display warning messages.
% Display warning messages.
for i = 1:size(warningtxt,1)
    warning(warningtxt{i,1}, warningtxt{i,2});
end

% Check that there is something to estimate.
estquant = obj2var(nlsys);
if isempty(estquant.Value)
    ctrlMsgUtils.warning('Ident:estimation:allFixedParameters')
else
    % Create estimator.
    Estimator = createEstimator(nlsys, data);

    % Perform minimization and suppress infeasible simulation warnings.
    warning('off', 'Ident:idnlmodel:infeasibleSimulation');
    optiminfo = minimize(Estimator);

    % Update NLSYS with new values for parameters, initial states, noise
    % variance, covariance matrix (optional) and update EstimationInfo.
    nlsys = updatemodel(nlsys, optiminfo, Estimator);
    nlsys.EstimationInfo.EstimationTime = cputime - StartTime;

    % Activate infeasible simulation warnings.
    warning('on', 'Ident:idnlmodel:infeasibleSimulation');
end