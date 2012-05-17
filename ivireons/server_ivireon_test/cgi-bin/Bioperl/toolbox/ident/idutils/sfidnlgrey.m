function [sys, x0, str, ts] = sfidnlgrey(t, x, u, flag, nlsys, varargin)
%SFIDNLGREY  S-function for simulating an IDNLGREY model in Simulink.
%
%   [SYS, X0, STR, TS] = SFIDNLGREY(T, X, U, FLAG, NLSYS, X0);
%
%   NLSYS should be an IDNLGREY object.
%
%   X0 is an optional input specifying the initial state of the IDNLGREY
%   object to be simulated. It can be
%      1. 'zero': use a zero initial state x(0).
%      2. 'fixed' or 'model': the initial state is determined by
%         nlsys.InitialState.
%      3. a Nx-by-1 structure array with fields 'Name', 'Unit', 'Value',
%         'Minimum', 'Maximum' and 'Fixed' with proper values assigned.
%      4. a finite real Nx-by-Ne matrix (the first Ne column will be used
%         as initial state).
%      5. an Nx-element cell array with finite real vectors of size 1-by-Ne
%      each.
%   See help idnlgrey for more information about X0.
%
%   See also idnlgrey/idnlgrey.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $ $Date: 2009/07/09 20:52:23 $

% Execute function.
fna = pvget(nlsys,'FileName');
if isa(fna,'function_handle')
    fna = func2str(fna);
end

switch flag
    case 0
        % Check that the function is called with 5 or 6 input arguments.
        error(nargchk(5, 6, nargin, 'struct'));
        
        % Check that NLSYS is an IDNLGREY object.
        if ~isa(nlsys, 'idnlgrey')
            ctrlMsgUtils.error('Ident:simulink:idnlgreyCheck1')
        end
        
        % Initialization.
        if isempty(varargin)
            [sys, x0, str, ts] = mdlInitializeSizes(nlsys, []);
        else
            [sys, x0, str, ts] = mdlInitializeSizes(nlsys, varargin{1});
        end
    case 1
        if ((pvget(nlsys, 'Ts') == 0) && ~isempty(x))
            % Time-continuous system with states. Update derivatives.
            P = pvget(nlsys, 'Parameters');
            P = {P.Value};
            sys = feval(pvget(nlsys, 'FileName'), t, x, u', P{:}, ...
                pvget(nlsys, 'FileArgument'));
            
            if any(~isfinite(sys))
                ctrlMsgUtils.error('Ident:simulink:idnlgreyCheck2',fna)
            end
        else
            sys = [];
        end
    case 2
        if ((pvget(nlsys, 'Ts') > 0) && ~isempty(x))
            % Time-discrete system with states. Update states.
            P = pvget(nlsys, 'Parameters');
            P = {P.Value};
            sys = feval(pvget(nlsys, 'FileName'), t, x, u', P{:}, ...
                pvget(nlsys, 'FileArgument'));
            if any(~isfinite(sys))
                ctrlMsgUtils.error('Ident:simulink:idnlgreyCheck3',fna)
            end
        else
            sys = [];
        end
    case 3
        % Outputs.
        P = pvget(nlsys, 'Parameters');
        P = {P.Value};
        [~, sys] = feval(pvget(nlsys, 'FileName'), t, x, u', P{:}, ...
            pvget(nlsys, 'FileArgument'));
        if any(~isfinite(sys))
            ctrlMsgUtils.error('Ident:simulink:idnlgreyCheck4',fna)
        end
    otherwise
        % Do nothing.
        sys = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local function.                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sys, x0, str, ts] = mdlInitializeSizes(nlsys, x0Init)

% Get the number of inputs and outputs.
sizes = simsizes;
no = pvget(nlsys, 'Order');
sizes.NumOutputs = no.ny;
sizes.NumInputs  = no.nu;

% Get the number of states.
Ts = pvget(nlsys, 'Ts');
if (Ts == 0)
    % Time-continuous system.
    sizes.NumContStates = no.nx;
    sizes.NumDiscStates = 0;
else
    % Time-discrete system.
    sizes.NumDiscStates = no.nx;
    sizes.NumContStates = 0;
end
sizes.NumSampleTimes = 1;

% Create outputs.
if ~isempty(x0Init)
    if (size(nlsys, 'Ne') > 1)
        % Get nlsys.x0 and strip it from multiple experiments.
        x0 = pvget(nlsys, 'InitialStates');
        for i = 1:length(x0)
            x0(i).Value = x0(i).Value(1);
            x0(i).Minimum = x0(i).Minimum(1);
            x0(i).Maximum = x0(i).Maximum(1);
            x0(i).Fixed = x0(i).Fixed(1);
        end
        nlsys = pvset(nlsys, 'InitialStates', x0);
    end
    if ischar(x0Init)
        choices = {'zero' 'fixed' 'model'};
        choice = strmatch(lower(x0Init), choices);
        if (isempty(x0Init) || isempty(choice))
            ctrlMsgUtils.error('Ident:simulink:idnlgreyInvalidX0', ...
                '''%s'' is not a valid value of ''x0''.',x0Init);
        elseif (choice(1) == 1)
            % This call checks that a zero initial state is feasible.
            setinit(nlsys, 'Value', num2cell(zeros(1, no.nx)));
        end
    elseif isnumeric(x0Init)
        % InitialState is a scalar/vector/matrix.
        setinit(nlsys, 'Value', num2cell(x0Init(:, 1)'));
    elseif iscell(x0Init)
        % InitialState is a cell array.
        setinit(nlsys, 'Value', x0Init);
    else
        % InitialState is a structure. This structure must be a proper
        % InitialStates structure.
        nlsys = pvset(nlsys, 'InitialStates', x0Init);
    end
end
if (no.nx < 1)
    x0 = [];
else
    x0 = getinit(nlsys, 'Value');
    x0 = cat(1, x0{:});
    x0 = x0(:, 1);
end

% Determine DirFeedthrough.
if (no.nu == 0)
    sizes.DirFeedthrough = 0;
else
    % Retrieve properties from nlsys.
    P = pvget(nlsys, 'Parameters');
    P = {P.Value};
    [~, y] = feval(pvget(nlsys, 'FileName'), 0, x0, NaN(1, no.nu), P{:}, ...
        pvget(nlsys, 'FileArgument'));
    if any(isnan(y))
        sizes.DirFeedthrough = 1;
    else
        sizes.DirFeedthrough = 0;
    end
end
sys = simsizes(sizes);
str = [];
if (no.nx == 0)
    ts  = [-1 0];
else
    ts = [Ts 0];
end