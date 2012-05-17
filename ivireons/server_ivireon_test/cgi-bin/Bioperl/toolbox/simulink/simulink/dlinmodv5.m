function [A,B,C,D]=dlinmodv5(model,varargin)
%DLINMODV5 linearization for discrete-time and hybrid systems
%
%   DLINMODV5 is the DLINMOD algorithm which was shipped with MATLAB 5.x.
%   It uses numerical perturbations to obtain the linear model.  The new
%   DLINMOD can obtain exact linearizations which are independent of
%   perturbation size.
%
%   [A,B,C,D]=DLINMODV5('SYS',TS) obtains a discrete-time state-space linear
%   model (with sample time TS) of the system of mixed continuous and
%   discrete systems described in the S-function 'SYS' when the state
%   variables and inputs are set to zero.
%
%   [A,B,C,D]=DLINMODV5('SYS',X,U) allows the state vector, X, and
%   input, U, to be specified. A linear model will then be obtained
%   at this operating point.  If a model has model reference blocks
%   X must be specified using the structure format.  Extract this
%   structure using the command:
%
%           X = Simulink.BlockDiagram.getInitialState('SYS');
%
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA) allows a vector of parameters
%   to be set.  PARA(1) sets the perturbation level for obtaining the
%   linear model (default PARA(1)=1e-5) according to:
%      XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%      UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%   where XPERT and UPERT are the perturbation levels for the system's states
%   and inputs. For systems that are functions of time PARA(2) may be set with
%   the value of t at which the linear model is to be obtained (default PARA(2)=0).
%   Set PARA(3)=1 to remove extra states associated with blocks that have no path
%   from input to output.
%
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA,XPERT,UPERT) allows the perturbation
%   levels for all of the elements of X and U to be set. Any or all of  PARA,
%   XPERT, UPERT may be empty matrices in which case these parameters will be
%   assumed to be undefined and the default option will be used.
%
%   To see more help, enter TYPE DLINMODV5.
%   See also DLINMOD, LINMOD, LINMOD2, TRIM.

%
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA,XPERT,UPERT) allows the
%   perturbation levels for all of the elements of X and U to be set.
%   The default is otherwise  XPERT=PARA(1)+1e-3*PARA(1)*abs(X),
%   UPERT=PARA(1)+1e-3*PARA(1)*abs(U).
%
%   Any or all of  PARA, XPERT, UPERT may be empty matrices in which case
%   these parameters will be assumed to be undefined and the default
%   option will be used.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.8.4.14 $
%   Andrew Grace 11-12-90.

% make sure model is supported
supportMsg = linmodsupported(model);
if ~isempty(supportMsg)
    error(supportMsg);
end

% Find the normal mode model references
[normalblks,normalrefs] = getLinNormalModeBlocks(model);
models = [model;normalrefs];

% Disable acceleration and force inline parameters
want = struct('SimulationMode','normal','RTWInlineParameters','on','InitInArrayFormatMsg', 'None');
[have, preloaded] = local_push_context(models, want);

% Check to be sure that a single tasking solver is being used in all the models.
if ~checkSingleTaskingSolver(models)
    DAStudio.error('Simulink:tools:dlinmodMultiTaskingSolver');
end

% Pre-compile the model
EnableLincompileForModelRefOld = feature('EnableLincompileForModelRef');
feature('EnableLincompileForModelRef',1)
feval(model, [], [], [], 'lincompile');
feature('EnableLincompileForModelRef',EnableLincompileForModelRefOld)

% Run the algorithm as a subroutine so we can trap errors and <CTRL-C>
errmsg = [];
try
    [A,B,C,D]=dlinmod_alg(model,varargin{:});
catch e
    errmsg=e;
end

% Release the compiled model
feval(model, [], [], [], 'term');
local_pop_context(models, have, preloaded);

% Issue an error if one occurred during the trim.
if ~isempty(errmsg)
    rethrow(errmsg);
end

% end dlinmod

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D]=dlinmod_alg(model,st,x,u,para,xpert,upert)

% ---------------Options--------------------
[sizes x0 x_str ts tsx]=feval(model,[],[],[],'sizes');
sizes=[sizes(:); zeros(6-length(sizes),1)];
nu=sizes(4);

if nargin<2, st = []; end
if nargin<3, x=[]; end
if nargin<4, u=[]; end
if nargin<5, para=[]; end
if nargin<6, xpert=[]; end
if nargin<7, upert=[]; end

% Initialize the model inputs
if isempty(u), u=zeros(nu,1); end

% Determine whether we are in model reference mode
mdlrefflag = ~isempty(find_system(model,'BlockType','ModelReference'));

% Check for model reference when getting the operation point
if isempty(x)
    if mdlrefflag
        x = sl('getInitialState',model);
    else
        x = x0;
    end
else
    if mdlrefflag && ~isstruct(x)
        DAStudio.error('Simulink:tools:dlinmodv5RequireStateStruct')
    end
end

% If the structure format is used, we need to make sure that we get the
% order of the sample times correct for the linearization.
if isstruct(x)
    tsx = struct2vect(x,'sampleTime');
else
    if ~isempty(tsx), tsx = tsx(:,1); end
end

% Get the number of states from the length of tsx
nxz = length(tsx);

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
if ~mdlrefflag && ~isstruct(x) && length(x)<nxz
    DAStudio.warning('Simulink:tools:dlinmodExtraStatesZero')
    x=[x(:); zeros(nxz-length(x),1)];
end
if length(para)>1, t=para(2); else t=0; end
if length(para)<3, para(3)=0; end

ts = [0 0; ts];

% Eliminate sample times that are the same with different offsets.
tsnew = unique(ts(:,1));
[nts] = length(tsnew);

if isempty(st)
    st = local_vlcm(tsnew(tsnew>0));
    if isempty(st)
        DAStudio.warning('Simulink:tools:dlinmodNoSampleTimeFound');
        st = 1;
    end
end

% Handle the state sorting for the structure case.
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
end

% Compute unperturbed values (must occur each time through the loop,
% after the call to 'all' with a given sampling time.  Otherwise,
% linearizations about nonzero initial states might get munged.
oldx=x; oldu=u;
% force all rates in the model to have a hit
feval(model, [], [], [], 'all');
y  = struct2vect(feval(model, t, x, u, 'outputs'),'values');
dall = compdxds(model,t,x,u);
oldy=y; olddall=dall;

% Initialize A and B, prepare for loop over sample times
A = zeros(nxz,nxz); B = zeros(nxz, nu); Acd = A; Bcd = B;
Aeye = eye(nxz,nxz);

% Define the initial C and D terms
ny = numel(y);
C=zeros(ny,nxz); D=zeros(ny,nu);

% Starting with smallest sample time, convert those models to the
% next smallest sample time.  Each pass through the loop removes a
% sample time from the list (and from the model).  Stop when the
% system is single-rate.
for m = 1:nts
    % Choose the next sample time
    if length(tsnew) > 1
        stnext = min(st, tsnew(2));
    else
        stnext = st;
    end
    storig = tsnew(1);
    index = find(tsx == storig);		% states with Ts = storig
    nindex = find(tsx ~= storig);		% states with another Ts
    oldA = Acd;
    oldB = Bcd;

    %% Begin linearization algorithm (formerly LINALL)

    %% This code block performs the simple linearization based on perturbations
    %% about x0, u0.  A sample time is specified not as the time at which the
    %% linearization occurs, but rather as a "granularity" or sampling time over
    %% which we are interested.  Thus, states with long sampling times will not
    %% change due to perturbations/linearization around shorter sampling times.

    %% Here t really is the time at which linearization occurs, same as linmod.
    %% storig is the sampling time for the current linearization.
    feval(model, storig, [], [], 'all');	% update blocks with Ts <= storig
    Acd=zeros(nxz,nxz); Bcd=zeros(nxz,nu); 

    if isstruct(x)
        % A and C matrices. Loop over all of the states in the model
        ctr = 1;
        for ct1 = 1:length(x.signals);
            for ct2 = 1:length(x.signals(ct1).values)
                xpertval = xpert.signals(ct1).values(ct2);
                xval = x.signals(ct1).values(ct2);
                x.signals(ct1).values(ct2) = xval+xpertval;
                % Evaluate outputs and derivative and flatten to a vector
                y = struct2vect(feval(model, t, x, u, 'outputs'),'values');
                dall = compdxds(model,t,x,u);
                Acd(:,ctr)=(dall-olddall)./xpertval;
                if ny > 0
                    C(:,ctr)=(y-oldy)./xpertval;
                end
                x=oldx;
                ctr = ctr + 1;
            end
        end
    else
        % Compute unperturbed values (must occur each time through the loop,
        % after the call to 'all' with a given sampling time.  Otherwise,
        % linearizations about nonzero initial states might get munged.
        oldx=x; oldu=u;
        y  = struct2vect(feval(model, t, x, u, 'outputs'),'values');
        dall = compdxds(model,t,x,u);
        oldy=y; olddall=dall;
        % Define the initial C and D terms
        ny = numel(y);
        C=zeros(ny,nxz); D=zeros(ny,nu);
        % A and C matrices
        for ct=1:nxz;
            x(ct)=x(ct)+xpert(ct);
            y = struct2vect(feval(model, t, x, u, 'outputs'),'values');
            dall = compdxds(model,t,x,u);
            Acd(:,ct)=(dall-olddall)./xpert(ct);
            if ny > 0
                C(:,ct)=(y-oldy)./xpert(ct);
            end
            x=oldx;
        end
    end
    
    % B and D matrices
    for ct=1:nu
        u(ct)=u(ct)+upert(ct);
        y = struct2vect(feval(model, t, x, u, 'outputs'),'values');
        dall = compdxds(model,t,x,u);
        if ~isempty(Bcd),
            Bcd(:,ct)=(dall-olddall)./upert(ct);
        end
        if ny > 0
            D(:,ct)=(y-oldy)./upert(ct);
        end
        u=oldu;
    end

    %% End linearization algorithm (formerly LINALL)

    % Update A, B matrices with any new information
    % Any differences between this linearization (Acd) and the last (oldA)
    % get premultiplied by the ZOH B-matrix associated with those states..
    % see the update method for Aeye below.
    A = A + Aeye * (Acd - oldA);
    B = B + Aeye * (Bcd - oldB);
    n = length(index);

    % Convert states at Ts=storig to sample time stnext
    % States with Ts > storig are treated as inputs (since they are constant
    % over one period at storig..) so the relevant columns of A are treated
    % as columns of B instead, via premultiplication by bd2.
    if n && storig ~= stnext
        if storig ~=  0
            if stnext ~= 0
                [ad2,bd2] = linmod_d2d(A(index, index),eye(n,n),storig, stnext);
            else
                [ad2,bd2] = d2ci(A(index, index),eye(n,n),storig);
            end
        else
            [ad2,bd2] = linmod_c2d(A(index, index),eye(n,n),stnext);
        end
        A(index, index)  =  ad2;

        if ~isempty(nindex)
            A(index, nindex) = bd2*A(index,nindex);
        end
        if nu
            B(index,:) = bd2*B(index,:);
        end

        % Any further updates to these states also get hit with bd2
        Aeye(index,index) = bd2*Aeye(index,index);
        tsx(index) =  stnext(ones(length(index),1));
    end

    % Remove this sample time (storig) from the list
    tsnew(1) = [];
end

if norm(imag(A), 'inf') < sqrt(eps), A = real(A); end
if norm(imag(B), 'inf') < sqrt(eps), B = real(B); end

% para(3) is set to 1 to remove extra states from blocks that are not in the
% input/output path. This removes a class of uncontrollable and unobservable
% states but does not remove states caused by pole/zero cancellation.
if para(3) == 1
    [A,B,C] = minlin(A,B,C);
end

% Return transfer function model
if nargout == 2
    % Eval it in case its not on the path
    [A, B] = feval('ss2tf',A,B,C,D,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compdxds - Return a flattened vector of the state derivatives and updates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dall = compdxds(model,t,x,u)

% Compute model update and derivatives
dx = feval(model, t, x, u, 'derivs');
ds = feval(model, t, x, u, 'update');

if isstruct(x)
    % Loop over each of the derivatives and replace the update values in ds
    % with the values of the derivated.
    if ~isempty(dx)
        for ct = 1:length(dx.signals)
            ind = strcmp(dx.signals(ct).blockName,{ds.signals.blockName});
            ds.signals(ind).values = dx.signals(ct).values;
        end
    end
    dall = struct2vect(ds,'values');
else
    dall = [dx; ds];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% struct2vect - Return a flattened vector of a structure of Simulink
% signals.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = struct2vect(xstr,field)

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
        if strcmp(field,'values')
            x(ind:ind+prod(xstr.signals(ct).dimensions)-1) = xstr.signals(ct).(field);
        else
            tsx = xstr.signals(ct).(field);
            x(ind:ind+prod(xstr.signals(ct).dimensions)-1) = tsx(1:end,1);
        end
        ind = ind + prod(xstr.signals(ct).dimensions);
    end
else
    x = xstr;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = local_vlcm(x)
% VLCM  find least common multiple of several sample times

% Protect against a few edge cases
x(~x) = [];
x(isinf(x)) = [];
if isempty(x), M = []; return; end;

[a,b]=rat(x);
v = b(1);
for k = 2:length(b), v=lcm(v,b(k)); end
d = v;

y = round(d*x);         % integers
v = y(1);
for k = 2:length(y), v=lcm(v,y(k)); end
M = v/d;

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

