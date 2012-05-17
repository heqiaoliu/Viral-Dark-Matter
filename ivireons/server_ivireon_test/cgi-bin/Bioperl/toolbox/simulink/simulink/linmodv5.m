function [A,B,C,D]=linmodv5(model,varargin)
%  LINMODV5 Obtains linear models from systems of ord. diff. equations (ODEs) 
%     using the full-model-perturbation algorithm that was found in MATLAB 5.x.
% 
%     [A,B,C,D]=LINMODV5('SYS') obtains the state-space linear model of the
%     system of ordinary differential equations described in the
%     block diagram 'SYS' when the state variables and inputs are set
%     to zero.
%  
%     [A,B,C,D]=LINMODV5('SYS',X,U) allows the state vector, X, and
%     input, U, to be specified. A linear model will then be obtained
%     at this operating point.  If a model has model reference blocks
%     X must be specified using the structure format.  Extract this
%     structure using the command:
%
%           X = Simulink.BlockDiagram.getInitialState('SYS');
%  
%     [A,B,C,D]=LINMODV5('SYS',X,U,PARA) allows a vector of parameters
%     to be set.  PARA(1) sets the perturbation level for obtaining the
%     linear model (default PARA(1)=1e-5) according to:
%        XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%        UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%     where XPERT and UPERT are the perturbation levels for the system's states
%     and inputs. For systems that are functions of time PARA(2) may be set with
%     the value of t at which the linear model is to be obtained (default PARA(2)=0).
%     Set PARA(3)=1 to remove extra states associated with blocks that have no path
%     from input to output.
% 
%     [A,B,C,D]=LINMOD('SYS',X,U,PARA,XPERT,UPERT) allows the perturbation
%     levels for all of the elements of X and U to be set. Any or all of PARA, 
%     XPERT, UPERT may be empty matrices in which case these parameters will be
%     assumed to be undefined and the default option will be used.  If X is
%     specified using the structure format, XPERT also must be specified
%     using the structure format.
% 
%     See also LINMOD, LINMOD2, DLINMOD, TRIM.

% Copyright 1999-2008 The MathWorks, Inc.
% $Revision: 1.8.2.12 $

% make sure model is supported
supportMsg = linmodsupported(model);
if ~isempty(supportMsg)
    error(supportMsg);
end

% Find the normal mode model references
[normalblks,normalrefs] = getLinNormalModeBlocks(model);
models = [model;normalrefs];

% Disable acceleration and force inline parameters
want = struct('SimulationMode','normal','RTWInlineParameters','on', 'InitInArrayFormatMsg', 'None');
[have, preloaded] = local_push_context(models, want);

% Pre-compile the model
EnableLincompileForModelRefOld = feature('EnableLincompileForModelRef');
feature('EnableLincompileForModelRef',1)
feval(model, [], [], [], 'lincompile');
feature('EnableLincompileForModelRef',EnableLincompileForModelRefOld)

% Run the linearization
errmsg = [];
try
    [A,B,C,D]=linmod_alg(model,varargin{:});
catch e 
    errmsg = e;
end

% Release the compiled model
feval(model, [], [], [], 'term');
local_pop_context(models, have, preloaded);

% Issue an error if one occurred during the linearization.
if ~isempty(errmsg),
    rethrow(errmsg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D]=linmod_alg(model,x,u,para,xpert,upert)

% ---------------Options--------------------
sizes = feval(model, [], [], [], 'sizes');
sizes=[sizes(:); zeros(6-length(sizes),1)];
nxz=sizes(1)+sizes(2); nu=sizes(4);
nx=sizes(1);

if nargin<2, x=[]; end
if nargin<3, u=[]; end
if nargin<4, para=[]; end
if nargin<5, xpert=[]; end
if nargin<6, upert=[]; end

% Initialize the model inputs
if isempty(u), u=zeros(nu,1); end

% Determine whether we are in model reference mode
mdlrefflag = ~isempty(find_system(model,'BlockType','ModelReference'));

% Check for model reference when getting the operation point
if isempty(x)
    if mdlrefflag
        x = sl('getInitialState',model);
    else
        x = zeros(nxz,1);
    end
else
    if mdlrefflag && ~isstruct(x)
        DAStudio.error('Simulink:tools:dlinmodv5RequireStateStruct')
    end
end
    
if isempty(para) , para=[0;0;0]; end
if para(1)==0, para(1)=1e-5; end
if isempty(upert), upert=para(1)+1e-3*para(1)*abs(u); end
if isempty(xpert)
    if isstruct(x)
        % Create a copy of the initial state matrix
        xpert = x;
        % Loop over to write the states into the vector
        for ct = 1:length(x.signals)
            xval = x.signals(ct).values;
            xpert.signals(ct).values = para(1)+1e-3*para(1)*abs(xval);
        end
    else
        xpert=para(1)+1e-3*para(1)*abs(x);
    end
end
if length(para)>1, t=para(2); else t=0; end
if length(para)<3, para(3)=0; end
if ~mdlrefflag && ~isstruct(x) && length(x)<nxz
  DAStudio.warning('Simulink:tools:dlinmodExtraStatesZero')
  x=[x(:); zeros(nxz-length(x),1)];
end

if nxz > nx
  DAStudio.warning('Simulink:tools:dlinmodIgnoreDiscreteStates');
end

% Initialization of nominal outputs and derivatives
oldx=x; oldu=u;
% force all rates in the model to have a hit
feval(model, [], [], [], 'all');
y = struct2vect(feval(model, t, x ,u, 'outputs'));
ny = numel(y);
dx = struct2vect(feval(model, t, x, u, 'derivs'));
oldy=y; olddx=dx;

% Initialize the state terms
A=zeros(nx,nx); B=zeros(nx,nu); C=zeros(ny,nx); D=zeros(ny,nu);

if isstruct(x)
    % Be sure that the state structures are in the order that the model
    % returns
    model_struct = sl('getInitialState',model);
    nsignals = numel(model_struct.signals);
    blocknames = {model_struct.signals.blockName};
    indsort = zeros(nsignals,1);
    for ct = 1:nsignals
        indsort(strcmp(x.signals(ct).blockName,blocknames)) = ct;
    end
    x.signals = x.signals(indsort);

    % Check to make sure that xpert is a structure
    if ~isstruct(xpert)
        DAStudio.error('Simulink:tools:dlinmodv5StateStructXPert')
    end
    
    % Be sure that the state perturbation structures are in the same
    % order that the model returns
    indsort = zeros(nsignals,1);
    for ct = 1:nsignals
        indsort(strcmp(xpert.signals(ct).blockName,blocknames)) = ct;
    end
    xpert.signals = xpert.signals(indsort);
    
    % Eliminate nondouble states
    for ct = length(x.signals):-1:1
        if ~strcmp(class(x.signals(ct).values),'double')
            x.signals(ct) = [];
            xpert.signals(ct) = [];
        end
    end
   
    % A and C matrices. Loop over all of the states in the model
    ctr = 1;
    for ct1 = 1:length(x.signals);
        for ct2 = 1:length(x.signals(ct1).values)
            xpertval = xpert.signals(ct1).values(ct2);
            xval = x.signals(ct1).values(ct2);
            x.signals(ct1).values(ct2) = xval+xpertval;
            % Evaluate outputs and derivative and flatten to a vector
            y = struct2vect(feval(model, t, x, u, 'outputs'));
            dx = struct2vect(feval(model, t, x, u, 'derivs'));
            A(:,ctr)=(dx-olddx)./xpertval;
            if ny > 0
                C(:,ctr)=(y-oldy)./xpertval;
            end
            x=oldx;
            ctr = ctr + 1;
        end
    end
else
    % A and C matrices
    for i=1:nx;
        x(i)=x(i)+xpert(i);
        y = feval(model, t, x ,u, 'outputs');
        dx = feval(model, t, x, u, 'derivs');
        A(:,i)=(dx-olddx)./xpert(i);
        if ny > 0
            C(:,i)=(y-oldy)./xpert(i);
        end
        x=oldx;
    end
end

% B and D matrices
for ct1=1:nu
    u(ct1)=u(ct1)+upert(ct1);
    % Evaluate outputs and derivative and flatten to a vector
    y = struct2vect(feval(model, t, x, u, 'outputs'));
    dx = struct2vect(feval(model, t, x, u, 'derivs'));
    if ~isempty(B),
        B(:,ct1)=(dx-olddx)./upert(ct1);
    end
    if ny > 0
        D(:,ct1)=(y-oldy)./upert(ct1);
    end
    u=oldu;
end

% para(3) is set to 1 to remove extra states from blocks that are not in the
% input/output path. This removes a class of uncontrollable and unobservable
% states but does not remove states caused by pole/zero cancellation.
if para(3) == 1 
   [A,B,C] = minlin(A,B,C);
end

% Return transfer function model
if nargout == 2
  disp('Returning transfer function model')
  % Eval it in case it's not on the path
  [A, B] = feval('ss2tf',A,B,C,D,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% struct2vect - Return a flattened vector of a structure of Simulink
% signals.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = struct2vect(xstr)

if isstruct(xstr)
    % Eliminate nondouble states
    for ct = length(xstr.signals):-1:1
        if ~strcmp(class(xstr.signals(ct).values),'double')
            xstr.signals(ct) = [];
        end
    end

    % Compute the number of states in the structure
    nels = sum([xstr.signals.dimensions]);

    % Initialize the state vector
    x = zeros(nels,1);

    % Initialize the index into the state vector
    ind = 1;

    % Loop over to write the states into the vector
    for ct = 1:length(xstr.signals)
        x(ind:ind+xstr.signals(ct).dimensions-1) = xstr.signals(ct).values;
        ind = ind + xstr.signals(ct).dimensions;
    end
else
    x = xstr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [old_values, preloaded] = local_push_context(models, new)
% Save model parameters before setting up new ones

preloaded = false(numel(models),1);

for ct = numel(models):-1:1
    % Make sure the model is loaded
    if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',models{ct}))
        load_system(models{ct});
    else
        preloaded(ct) = true;
    end

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_pop_context(models, old, preloaded)
% Restore model parameters from previous context

for ct = numel(models):-1:1
    f = fieldnames(old);
    for k = 1:length(f)
        prop = f{k};
        if ~isequal(prop,'Dirty')
            set_param(models{ct}, prop, old(ct).(prop));
        end
    end

    set_param(models{ct}, 'Dirty', old(ct).Dirty); %% should be the last set_param

end
