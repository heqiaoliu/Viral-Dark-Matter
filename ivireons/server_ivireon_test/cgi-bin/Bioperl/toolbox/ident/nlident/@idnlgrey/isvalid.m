function errmsg = isvalid(nlsys, checktype)
%ISVALID  Checks whether an IDNLGREY object is valid or not. If it
%   is valid an empty string is returned; if it is invalid either a
%   string stating the problem is returned or an error is thrown.
%
%   ERRMSG = ISVALID(NLSYS, CHECKTYPE);
%
%   CHECKTYPE can be either 'All' (default), 'OnlyFileName' or
%   'SkipFileName'. In the first case, all properties of NLSYS are checked;
%   in the second case, only the model structure defined by  'FileName' is
%   checked; in the third case, all properties but the file are checked.
%
%   ERRMSG is a struct specifying the first error encountered during
%   object consistency checking (empty if no errors found).
%
%   See also IDNLGREY/IDNLGREY.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2009/03/09 19:14:55 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','isvalid','IDNLGREY');
end

% Check checktype.
if (nin < 2)
    checktype = 1;
elseif ~ischar(checktype)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyIsvalid1')
elseif (ndims(checktype) ~= 2)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyIsvalid1')
elseif isempty(checktype)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyIsvalid1')
elseif ~isempty(strmatch(lower(checktype), 'all'))
    checktype = 1;
elseif ~isempty(strmatch(lower(checktype), 'skipfilename'))
    checktype = 2;
elseif ~isempty(strmatch(lower(checktype), 'onlyfilename'))
    checktype = 3;
else
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyIsvalid1')
end

% If requested, check all properties of nlsys.
if (checktype < 3)
    % Retrieve object properties and some dimension information.
    InputName = pvget(nlsys, 'InputName');
    OutputName = pvget(nlsys, 'OutputName');
    StateName = {nlsys.InitialStates.Name};
    ParameterName = {nlsys.Parameters.Name};
    TimeVariable = pvget(nlsys, 'TimeVariable');
    
    % Check uniqueness amongst InputName, StateName, OutputName,
    % ParameterName and TimeVariable.
    if ~isempty(intersect(InputName, StateName))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyXINameClash',...
            'message','Input names must be distinct from the state names in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(InputName, OutputName))
        errmsg = struct('identifier','Ident:general:IONameClash',...
            'message','Input names must be distinct from the output names.');
        return;
    end
    if ~isempty(intersect(InputName, ParameterName))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyParINameClash',...
            'message','Parameter names must be distinct from the input names in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(InputName, TimeVariable))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyITimeVarNameClash',...
            'message','Input names must be distinct from the time variable in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(StateName, ParameterName))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyParXNameClash',...
            'message','Parameter names must be distinct from the state names in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(StateName, TimeVariable))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyXTimeVarNameClash',...
            'message','State names must be distinct from the time variable in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(OutputName, ParameterName))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyParONameClash',...
            'message','Parameter names must be distinct from the output names in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(OutputName, TimeVariable))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyOTimeVarNameClash',...
            'message','Output names must be distinct from the time variable in an IDNLGREY model.');
        return;
    end
    if ~isempty(intersect(ParameterName, TimeVariable))
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyParTimeVarNameClash',...
            'message','Parameter names must be distinct from the time variable in an IDNLGREY model.');
        return;
    end
    
    % Check that StateName contains nx elements.
    if (length(StateName) ~= nlsys.Order.nx)
        errmsg = struct('identifier','Ident:idnlmodel:idnlgreyXOrdMismatch',...
            'message','The number of initial states must be equal to the value of Order.nx.');
        return;
    end
    
    % Check CovarianceMatrix.
    if (isnumeric(nlsys.CovarianceMatrix) && ~isempty(nlsys.CovarianceMatrix))
        if (size(nlsys.CovarianceMatrix, 1) ~= size(nlsys, 'np'))
            errmsg = 'The value of the "CovarianceMatrix" property must be [] or a symmetric positive real matrix of size equal to the number of parameters.';
            errmsg = struct('identifier','Ident:idnlmodel:CovValue','message',errmsg);
            return;
        end
    end
    
    % In case Solver is not 'Auto':
    %    If Ts > 0 or nlsys is a static system, then check that Solver is
    %    'FixedStepDiscrete', else check that Solver is not
    %    'FixedStepDiscrete'.
    Solver = nlsys.Algorithm.SimulationOptions.Solver;
    if ~strcmpi(Solver, 'Auto')
        if ((pvget(nlsys, 'Ts') > 0) ||(nlsys.Order.nx == 0))
            % Time-discrete case.
            if ~strcmpi(Solver, 'FixedStepDiscrete')
                errmsg = 'The value of the "Algorithm.SimulationOptions.Solver" option must be ''FixedStepDiscrete'' for discrete time models.';
                errmsg = struct('identifier','Ident:idnlmodel:invalidDTSolver','message',errmsg);
                return;
            end
        else
            % Time-continuous case.
            if strcmpi(Solver, 'FixedStepDiscrete')
                errmsg = 'The value of the "Algorithm.SimulationOptions.Solver" cannot be ''FixedStepDiscrete'' for continuous time models.';
                errmsg = struct('identifier','Ident:idnlmodel:invalidCTSolver','message',errmsg);
                return;
            end
        end
    end
    
    %{
    % Check weighting size.
    ny = nlsys.Order.ny;
    if (size(nlsys.Algorithm.Weighting, 1) ~= ny)
        if ny==1
            errmsg = 'The value of the "Weighting" algorithm property must be a real positive scalar.';
            errmsg = struct('identifier','Ident:general:incorrectWeighting3','message',errmsg);
        else 
            errmsg = sprintf('The value of the "Weighting" algorithm property must be a positive semi-definite matrix of size = %d.',ny);
            errmsg = struct('identifier','Ident:general:incorrectWeighting1','message',errmsg);
        end
        return;
    end
    %}
end

% Check FileName.
if (checktype ~= 2)
    errmsg = checkgetFileName(nlsys.FileName, nlsys.Order, {nlsys.Parameters.Value}, nlsys.FileArgument);
    error(errmsg);
end

% Everything went fine. Return an empty struct
errmsg = struct([]);
