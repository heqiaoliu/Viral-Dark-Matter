function [a,b,c,d,J] = dlinmod(model, Ts, varargin)
%DLINMOD Obtains linear models from systems of ODEs and discrete-time systems.
%   [A,B,C,D]=DLINMOD('SYS',TS) obtains a discrete-time state-space linear
%   model (with sample time TS) of the system of mixed continuous and
%   discrete systems described in the block diagram 'SYS' when the state
%   variables and inputs are set to the defaults specified in the block
%   diagram.
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U) allows the state vector, X, and
%   input, U, to be specified. A linear model will then be obtained
%   at this operating point.  X also can be specified using the structure
%   format.  Extract this structure using the command:
%
%           X = Simulink.BlockDiagram.getInitialState('SYS');
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,PARA) allows a vector of parameters to
%   be set.  PARA(1) sets the perturbation level (obsolete in R12 unless
%   using the 'v5' option - see below). For systems that are functions of
%   time PARA(2) may be set with the value of t at which the linear
%   model is to be obtained (default t=0). Set PARA(3)=1 to remove extra
%   states associated with blocks that have no path from input to output.
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5') uses the full-model-perturbation
%   algorithm that was found in MATLAB 5.x.
%
%   The current algorithm uses pre-programmed linearizations for some
%   blocks, and should be more accurate in most cases.  The new algorithm
%   also allows for special treatment of problematic blocks such as the
%   Transport Delay and the Quantizer.  See the mask dialog of these
%   blocks for more information and options.  Use the
%   full-model-perturbation algorithm to linearize models with model
%   reference.
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,PARA,XPERT,UPERT,'v5') uses the
%   full-model-perturbation algorithm that was found in MATLAB 5.x.
%   If XPERT and UPERT are not given, PARA(1) will set the perturbation level
%   according to:
%      XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%      UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%   The default perturbation level is PARA(1)=1e-5.
%   If vectors XPERT and UPERT are given they will be used as the perturbation
%   level for the systems states and inputs.
%
%   See also: DLINMODV5, LINMOD, LINMOD2, TRIM

%   S = DLINMOD('SYS',...) returns a structure containing the state-space
%   matrices, state names, operating point, and other information about
%   the linearized model.
%
%   [A,B,C,D,J] = DLINMOD('SYS',...) returns the sparse Jacobian structure
%   in addition to the state-space matrices.
%

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.47.4.21 $
%   Andrew Grace 11-12-90, 7-24-97
%   Greg Wolodkin 09-09-1999
%   John Glass 4-28-2005

% Ts is optional
if nargin < 2, Ts = []; end;

ni = nargin-2;
lmflag = 0;
v5flag = 0;
spflag = 0;
apflag = 'off';

% Accept a number of string arguments at the end of the list
while (ni > 0) && ischar(varargin{ni})
    lastarg = varargin{ni};
    ni = ni - 1;
    switch lower(lastarg)
        case 'ignorediscretestates'
            lmflag = 1;
            if ~isequal(Ts,0)
                DAStudio.warning('Simulink:tools:dlinmodUseZeroTs');
                Ts = 0;
            end
        case 'v5'
            v5flag = 1;
        case 'sparse'
            spflag = 1;
        case 'useanalysisports'
            apflag = 'on';
        otherwise
            DAStudio.error('Simulink:tools:dlinmodUnrecognizedOption');
    end
end

if v5flag
    if spflag
        DAStudio.warning('Simulink:tools:dlinmodNoV5Sparse');
    end
    if strcmp(apflag,'on')
        DAStudio.warning('Simulink:tools:dlinmodNoV5AnalysisPorts');
    end
    if (lmflag)
        [a,b,c,d] = linmodv5(model,varargin{1:ni});
    else
        [a,b,c,d] = dlinmodv5(model,Ts,varargin{1:ni});
    end
    return
end

% Find the normal mode model references
[~,normalrefs] = getLinNormalModeBlocks(model);
models = [model;normalrefs];

% Make sure the model is loaded
preloaded = false(numel(models,1));
for ct = 1:numel(models)
    if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',models{ct}))
        load_system(models{ct});
    else
        preloaded(ct) = true;
    end
end

% Parameter settings we need to set/cache before linearizing
want = struct('AnalyticLinearization','on',...
    'UseAnalysisPorts', apflag, ...
    'BufferReuse', 'off',...
    'SimulationMode', 'normal',...
    'RTWInlineParameters','on', ...
    'InitInArrayFormatMsg', 'None');

% Determine the simulation status 
simstat = strcmp(get_param(model,'SimulationStatus'),'stopped');

% Old argument parsing
if ni < 1, x    = []; else    x = varargin{1}; end
if ni < 2, u    = []; else    u = varargin{2}; end
if ni < 3, para = []; else para = varargin{3}; end

if isempty(para), para = [0;0;0]; end
if para(1) == 0, para(1) = 1e-5; end          % unused
if length(para)>1, t = para(2); else t = 0; end
if length(para)<3, para(3) = 0; end

% Turn on load initial state if the user has specified initial states.  This will
% allow externally specified initial states to be overwritten using the ic ports.
% If x,u specified set the output option to refine
if simstat && ni > 0
    if ~isempty(x)
        want.InitialState = '[]';
        want.LoadInitialState = 'on';
    end
    want.OutputOption = 'RefineOutputTimes';
    % If the user has specified an input then be sure that the load
    % initial state flag is turned off.  If it is left on then the model
    % api will not set these values.
    if ~isempty(u)
        tu = [t reshape(u,1,numel(u))];
        want.ExternalInput = mat2str(tu);        
        want.LoadExternalInput = 'on';
    end
    want.BlockJacobianDiagnostics = 'off';
end

% Load model, save old settings, install new ones suitable for linearization
have = local_push_context(models, want);

% Check to be sure that a single tasking solver is being used in all the models.
if ~checkSingleTaskingSolver({model}) && simstat
    DAStudio.error('Simulink:tools:dlinmodMultiTaskingSolver');
end


% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);

try
    % Compile the model to set the state values
    if simstat
        feval(model, [], [], [], 'lincompile');
    end
   
    % Only call sizes if ni >0 or if we need to check the solver mode
    if ni > 0
        sizes = feval(model,[],[],[],'sizes');
    end


    % If [x,u] are given we need some info from the model
    if ni > 0
        if isempty(x) && simstat
            x = sl('getInitialState',model);
        end

        % Time in the first column, u in the remaining columns
        if (length(u) ~= sizes(4)) && (numel(u) ~= 0)
            DAStudio.error('Simulink:tools:dlinmodWrongInputVectorSize',sizes(4));
        end

        nxz = sizes(1)+sizes(2);
        if ~isstruct(x) && length(x) < nxz
            DAStudio.warning('Simulink:tools:dlinmodExtraStatesZero');
            x = [x(:); zeros(nxz-length(x),1)];
        end
    end

    % Force all rates in the model to have a sample hit and then evaluate the
    % outputs to ensure initial conditions are set for externally specified
    % integrators.
    if ni > 0
        feval(model, [], [], [], 'all');
        feval(model, t, x, u, 'outputs');
    end
    
    % Compute the linearization
    J = feval(model,[],[],[], 'graph_jacobian');
    % Terminate the compilation
    if simstat
        feval(model, [], [], [], 'term');
    end
    
    NestedCleanUp;
catch e
    % Terminate the compilation
    if simstat && strcmp(get_param(model,'SimulationStatus'),'paused')
        feval(model, [], [], [], 'term');
    end
    
    % Restore sparse math and block diagram settings
    spparms('autommd', autommd_orig);
    local_pop_context(models, have);

    NestedCleanUp;
    rethrow(e);
end

if nargout == 2
    % Eval it in case it's not on the path
    [a,b] = sl('dlinmod_post', J, model, t, Ts, x, u, lmflag, spflag, para); 
elseif nargout == 1
    a =  sl('dlinmod_post', J, model, t, Ts, x, u, lmflag, spflag, para); 
else 
    [a, b, c, d] = sl('dlinmod_post', J, model, t, Ts, x, u, lmflag, spflag, para);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested clean up function
    function NestedCleanUp
        % Restore sparse math and block diagram settings
        spparms('autommd', autommd_orig);
        local_pop_context(models, have);

        for ct_clean = 1:numel(models)
            if ~preloaded(ct_clean)
                close_system(models{ct_clean},0);
            end
        end
    end
% 
end


function old_values = local_push_context(models, new)
% Save model parameters before setting up new ones

for ct = numel(models):-1:1
    % Save this before calling set_param() ..
    old = struct('Dirty', get_param(models{ct},'Dirty'));

    f = fieldnames(new);
    for k = 1:length(f)
        prop = f{k};
        have_val = get_param(models{ct}, prop);
        want_val = new.(prop);
        set_param(models{ct}, prop, want_val);
        old.(prop) = have_val;
    end
    old_values(ct) = old;
end
end
%---

function local_pop_context(models, old)
% Restore model parameters from previous context

for ct = numel(models):-1:1
    f = fieldnames(old(ct));
    for k = 1:length(f)
        prop = f{k};
        if ~isequal(prop,'Dirty')
            set_param(models{ct}, prop, old(ct).(prop));
        end
    end

    set_param(models{ct}, 'Dirty', old(ct).Dirty);
end
end
