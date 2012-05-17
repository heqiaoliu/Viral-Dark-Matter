function nlsys = idnlgrey(varargin)
%IDNLGREY  Create IDNLGREY model structure.
%
%   NLSYS = IDNLGREY(FILENAME, ORDER, PARAMETERS);
%   NLSYS = IDNLGREY(FILENAME, ORDER, PARAMETERS, INITIALSTATES);
%   NLSYS = IDNLGREY(FILENAME, ORDER, PARAMETERS, INITIALSTATES, TS);
%   NLSYS = IDNLGREY(FILENAME, ORDER, PARAMETERS, INITIALSTATES, TS, ...
%                    'PROPERTY1', VALUE1, ..., 'PROPERTYN', VALUEN);
%
%   NLSYS is the returned IDNLGREY object describing a user defined
%      nonlinear model structure.
%
%   FILENAME is the name of the m-, p-, MEX-file or the function handle
%      that describes the model structure. It should always have the format
%
%      [F, H] = FILENAME(t, x, u, p1, p2, ..., pNpo, FileArgument);
%
%      where the first output describes how the states are updated
%      either as a continuous-time (xnew(t) = d/dt x(t)) or discrete-
%      time (xnew(t) = x(t+Ts)) system:
%
%                    ( f1(t, x, u, p1, p2, ..., pNpo, FileArgument)  )
%      xnew(t) = F = (    ...                                        )
%                    ( fNx(t, x, u, p1, p2, ..., pNpo, FileArgument) )
%
%      where f1(.), ..., fNx(.) are Nx nonlinear functions. y represents
%      the output:
%
%                 ( h1(t, x, u, {p1, p2, ..., pNpo}, FileArgument)  )
%      y(t) = H = (    ...                                          )
%                 ( hNy(t, x, u, {p1, p2, ..., pNpo}, FileArgument) )
%
%      where h1(.), ..., hNy(.) are Ny nonlinear functions. The input
%      variables to FILENAME are as follows:
%
%      t: the current time (for modeling of time-varying systems).
%      x: the current (at time t) state vector.
%      u: the current (at time t) input vector.
%      p1, ..., pNpo: are short for the parameters of the model. Each pi
%         can be a scalar, a vector or a matrix. In case all parameters are
%         scalars, then Npo (number of parameter objects) equals Np (total
%         number of parameters).
%      FileArgument: optional input argument, a cell array. Default is {}.
%
%   ORDER is a vector with three entries specifying, in order, the number
%      of outputs (Ny), the number of inputs (Nu) and the number of states
%      (Nx) of the model structure. It can also be a structure with fields
%      'ny', 'nu' and 'nx'. For time-series, nu is set to 0.
%
%   PARAMETERS is a Npo-by-1 structure array with fields
%      Name   : name of the parameter (a string).
%      Unit   : unit of the parameter (a string).
%      Value  : value of the parameter (a finite real scalar, vector or
%               2-dimensional matrix).
%      Minimum: minimum values of the parameter (a real scalar, a vector or
%               a 2-dimensional matrix).
%      Maximum: maximum values of the parameter (a real scalar, a vector or
%               a 2-dimensional matrix).
%      Fixed  : a boolean, a boolean vector or a boolean 2-dimensional
%               matrix specifying whether the parameter is fixed or not.
%
%   PARAMETERS can also be a real finite Np-by-1 vector (INPARAMETERS), in
%      which case the data is converted to a Np-by-1 structure array with fields
%      Name   : 'pi', i = 1, 2, ..., Np.
%      Unit   : ''.
%      Value  : INPARAMETERS(i), i = 1, 2, ..., Np.
%      Minimum: -Inf.
%      Maximum: Inf.
%      Fixed  : false.
%
%   PARAMETERS can also be a Npo-by-1 cell array containing finite real
%      scalars, finite real vectors or finite real 2-dimensional matrices.
%      Name and Unit will be as in the numeric case. Minimum, Maximum and
%      Fixed will hold -Inf, Inf and false elements, respectively, of the
%      same size as the corresponding Value element.
%
%   INITIALSTATES is a Nx-by-1 structure array with fields
%      Name   : name of the state (a string).
%      Unit   : unit of the state (a string).
%      Value  : value of the states (a finite real 1-by-Ne vector, where
%               Ne is the number of experiments.)
%      Minimum: minimum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same minimum value).
%      Maximum: maximum values of the states (a real 1-by-Ne vector or a
%               real scalar, in which case all initial states have the
%               same maximum value).
%      Fixed  : a boolean 1-by-Ne vector, or a scalar boolean (applicable
%               for all states) specifying whether the initial state is
%               fixed or not.
%
%   If INITIALSTATES is specified as [], an Nx-by-1 structure array is
%   created with the following default values:
%      Name   : 'xi', i = 1, 2, ..., Nx.
%      Unit   : ''.
%      Value  : 0
%      Minimum: -Inf.
%      Maximum: Inf.
%      Fixed  : true.
%
%      If INITIALSTATES is specified as a real finite Nx-by-Ne matrix, then
%      the Value of the i:th structure array element will be
%      INITIALSTATES(i, Ne), i.e., a row vector with Ne elements. Minimum,
%      Maximum and Fixed will be -Inf, Inf and true row vectors of the same
%      size as INITIALSTATES(i, Ne). 
%  
%   In addition, INITIALSTATES can be specified as {} (same as []) or a
%   cell array with finite real vectors of size 1-by-Ne.  
%
%   TS is the sampling interval of the (discrete time) model. For a
%      continuous time model TS is equal to 0 (default).
%
%   Any number of property-value pairs can be passed to IDNLGREY. The
%   assignable properties are the ones returned by get(idnlgrey) and the
%   basic algorithm properties returned by get(idnlgrey, 'Algorithm'). The
%   latter properties should be specified without an algorithm prefix,
%   i.e., Algorithm.MaxIter is specified using MaxIter as property name.
%   For more information about IDNLGREY properties, type IDPROPS IDNLGREY.
%   For more information about the basic IDNLGREY algorithm properties,
%   type IDPROPS IDNLGREY ALGORITHM.
%
%   See also IDNLGREY/PEM, IDNLGREY/PREDICT, IDNLGREY/SIM, IDGREY.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $ $Date: 2009/04/21 03:23:03 $
%   Written by Peter Lindskog.

% Retrieve the number of inputs.
nin = nargin;

% Check if an empty IDNLGREY model was given.
if (nin == 0)
    nlsys = idnlgrey('', [], []);
    return;
end

% Quick exit for IDNLGREY objects.
if isa(varargin{1}, 'idnlgrey')
    if (nin ~= 0)
        ctrlMsgUtils.error('Ident:general:useSetForProp', ...
                'Use the "set" command to modify the properties of %s objects.','IDNLGREY');
    end
    nlsys = varargin{1};
    return;
end

% Check that the constructor was called with at least 3 arguments.
if (nin < 3)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyNargChk')
end

% Check FileName.
FileName = varargin{1};
if isa(FileName, 'function_handle')
    % FileName is a function handle.
else
    % FileName is a string. Checking of FileName will be done later on when
    % the model file is accessed.
    if ~ischar(FileName) || (ndims(FileName) ~= 2) || (~isempty(FileName) && ~isvarname(FileName))
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyInvalidFileName')
    end
    FileName = FileName(:)';
end

% Check Order.
if isempty(varargin{2})
    Order = struct('ny', 0, 'nu', 0, 'nx', 0);
else
    [errmsg, Order] = checkgetOrder(varargin{2});
    error(errmsg);
end

% Check Parameters.
[errmsg, Parameters] = checkgetParameters(varargin{3}, true);
error(errmsg);

% If available, check and get InitialStates.
if (nin > 3)
    [errmsg, InitialStates] = checkgetInitialStates(varargin{4}, Order.nx, true);
else
    [errmsg, InitialStates] = checkgetInitialStates([], Order.nx, true);
end
error(errmsg);

% If available, check and get Ts.
if (nin > 4)
    Ts = idutils.utValidateTs(varargin{5},false);
else
    % Time-continuous system by default.
    Ts = 0;
end

% Check model FileArgument.
pvstart = find(cellfun('isclass', varargin(4:end), 'char'), 1, 'first')+3;
[errmsg, FileArgument] = checkgetFileArgument(varargin{pvstart:end});
error(errmsg);

% Define IDNLGREY properties.
nlsys = struct('FileName',         FileName,                       ... % Name of the file/handle defining the model structure.
               'Order',            Order,                          ... % Model order information [nx ny nu].
               'Parameters',       Parameters,                     ... % Model parameter information.
               'InitialStates',    InitialStates,                  ... % Initial state information.
               'FileArgument',     {FileArgument},                 ... % Optional argument to FileName.
               'CovarianceMatrix', 'Estimate',                     ... % Covariance matrix.
               'Algorithm',        idnlgreydef('Algorithm'),       ... % Algorithm information.
               'EstimationInfo',   idnlgreydef('EstimationInfo')   ... % Estimation info.
              );
nlsys.Algorithm.Weighting = eye(Order.ny); 
          
% IDNLGREY should be superior to IDDATA.
superiorto('iddata');

% Let the parent object be IDNLMODEL.
nlparent = idnlmodel(Order.ny, Order.nu, Ts);
nlsys = class(nlsys, 'idnlgrey', nlparent);
nlsys = pvset(nlsys, 'Estimated', -1);
nlsys = timemark(nlsys, 'c');

% Go through the parameter list, and set values to the specified
% parameters.
if ~isempty(pvstart)
    nlsys = setext(nlsys, varargin{pvstart:end});
end
