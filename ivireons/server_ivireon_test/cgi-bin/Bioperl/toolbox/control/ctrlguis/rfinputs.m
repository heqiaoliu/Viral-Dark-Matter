function [sys,SystemName,InputNames,OutputNames,PlotStyle,ExtraArgs,OptionsObject] = ...
   rfinputs(PlotType,ArgNames,varargin)
%RFINPUTS  Parse input list for time and frequency response functions.
%
%   RFINPUTS parses the argument list for the various time and
%   frequency response functions.
%
%   Note: ArgNames is empty when no plot is created (call with output
%   arguments)
%
%   LOW-LEVEL UTILITY.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.27.4.17 $  $Date: 2009/12/07 20:41:30 $


% Identify input argument of class LTI
ni = length(varargin);
if ni==0
    sys = {};  SystemName = {};
    InputNames = {''};   OutputNames = {''};
    PlotStyle = {};   ExtraArgs   = {}; 
    OptionsObject = [];
    return
end
makingPlot = ~isempty(ArgNames);  % true when plot is being created

% Check for Plot Options
if isa(varargin{ni},'plotopts.PlotOptions');
    OptionsObject = varargin{ni};
    varargin(ni) = [];
    ni = ni - 1;
else
    OptionsObject = [];
end

InputClass = zeros(1,ni);
for ct=1:ni,
   argj = varargin{ct};
   if isa(argj,'lti') || isa(argj,'idmodel') || isa(argj,'idfrd')
      InputClass(ct) = 1;
      varargin{ct} = LocalConvert2LTI(argj);
   elseif isa(argj,'char') && ~any(strcmpi(argj,{'inv','zoh','foh'}))
      InputClass(ct) = -1;
   end
end

% Extract LTI systems 
isys = find(InputClass>0);
sep = isys(2:end)-isys(1:end-1);
if isempty(isys) || any(sep>2)
    ctrlMsgUtils.error('Control:analysis:rfinputs01')
end
sys = varargin(isys);
nsys = length(sys);

% Get plot-related info
if makingPlot
   % Use system name if it exists, otherwise use argument name
   SystemName = cell(nsys,1);
   for ct = 1:nsys
      if isempty(sys{ct}.Name)
         SystemName(ct) = ArgNames(isys(ct));
      else
         SystemName(ct) = {sys{ct}.Name};
      end
   end

   % Find plot style specifiers if any
   istyle = find(InputClass<0);
   if any(istyle>isys(end)+1) || any(istyle<2)
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
   end
   PlotStyle = cell(1,nsys);
   ColorOnly = strcmpi(PlotType,'pzmap');
   ilast = 0;
   idxsys = 0;
   for ct=1:length(istyle)
      idxsys = idxsys + istyle(ct) - (ilast+1);
      Style = varargin{istyle(ct)};
      [a,b,c,msg] = colstyle(Style);
      if ~isempty(msg)
          ctrlMsgUtils.error('Control:analysis:rfinputs02',Style)
      elseif ColorOnly
         PlotStyle{idxsys} = b;
      else
         PlotStyle{idxsys} = Style;
      end
      ilast = istyle(ct);
   end

   % Determine joint I/O names
   [InputNames,OutputNames,EmptySys] = mrgios(sys{:});
   if any(EmptySys)
      ctrlMsgUtils.warning('Control:analysis:PlotEmptyModel')
   end
else
   SystemName = [];
   PlotStyle = [];
   InputNames = [];
   OutputNames = [];
   istyle = 0;
end

% Plot-specific checks
ExtraArgs = varargin(max([isys,istyle])+1:ni);
switch PlotType
case {'step','impulse'}
   ExtraArgs = LocalTimeCheck(ExtraArgs,sys);
   MaxArg = 1;
case 'initial'
   ExtraArgs = LocalInitialCheck(ExtraArgs,sys);
   MaxArg = 2;
case 'lsim'
   ExtraArgs = LocalLsimCheck(ExtraArgs,sys);
   MaxArg = 4;
case {'bode','bodemag','nyquist','nichols'}
   ExtraArgs = LocalFreqCheck(ExtraArgs);
   MaxArg = 1;   
case 'sigma'
   ExtraArgs = LocalSigmaCheck(ExtraArgs,sys);
   MaxArg = 2;   
case {'pzmap','iopzmap'}
   MaxArg = 0;
case 'rlocus'
   [ExtraArgs,sys] = LocalRootLocusCheck(ExtraArgs,sys);
   MaxArg = 1;
otherwise
   MaxArg = Inf;
end
if length(ExtraArgs)>MaxArg
   ctrlMsgUtils.error('Control:analysis:rfinputs01')
end
   
% Check computability of all responses
if strcmp(PlotType,'lsim')
   [t,x0,u] = deal(ExtraArgs{1:3});
   if ~(isempty(u) && isempty(t) && isempty(x0))
      % Only call iscomputable if args are specfied. Otherwise the lsim GUI
      % is being used to specify inputs
      for ct=1:nsys
         sys{ct} = LocalCheckComputability(sys{ct},'lsim',t,x0,u);
      end
   else
       % Throw error if any model is FRD for lsim. Protect against
       % launching lsim GUI for FRD models
       for ct=1:nsys
           if isa(sys{ct}, 'frd')
               ctrlMsgUtils.error('Control:analysis:rfinputs03', 'frd')
           end
       end
   end
elseif ~strcmp(PlotType,'unspecified')
   for ct=1:nsys
      sys{ct} = LocalCheckComputability(sys{ct},PlotType,ExtraArgs{:});
   end
end
%---------------- Local Functions --------------------------

%%%%%%%%%%%%%%%%%%
% LocalTimeCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalTimeCheck(ExtraArgs,sys)
% Checks extra inputs for STEP, IMPULSE
if isempty(ExtraArgs)
   t = [];
else
   t = ExtraArgs{1};
end
nsys = length(sys);
Ts = zeros(nsys,1);
for ct=1:nsys
   Ts(ct) = getTs(sys{ct});
end
ExtraArgs = {LocalCheckTX0(t,0,[],Ts)};


%%%%%%%%%%%%%%%%%%
% LocalFreqCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalFreqCheck(ExtraArgs)
% Checks extra inputs for BODE, BODEMAG, NYQUIST, NICHOLS
if isempty(ExtraArgs)
   ExtraArgs = {[]};
else
   ExtraArgs{1} = FreqVectorCheck(ExtraArgs{1});
end


%%%%%%%%%%%%%%%%%%%%%
% LocalInitialCheck %
%%%%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalInitialCheck(ExtraArgs,sys)
% Checks extra inputs for INITIAL
switch length(ExtraArgs)
case 0
    ctrlMsgUtils.error('Control:analysis:rfinputs04')
case 1
   x0 = ExtraArgs{1};  t = [];
otherwise
   x0 = ExtraArgs{1};  t = ExtraArgs{2};
end
nsys = length(sys);
Ts = zeros(nsys,1);
for ct=1:nsys
   Ts(ct) = getTs(sys{ct});
end
[t,x0] = LocalCheckTX0(t,0,x0,Ts);
ExtraArgs(1:2) = {t, x0};


%%%%%%%%%%%%%%%%%%
% LocalLsimCheck %
%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalLsimCheck(ExtraArgs,sys)
% Checks extra inputs for LSIM
if isempty(ExtraArgs)
    % GUI being used for input specification
    ExtraArgs = {[],[],[],'auto'};  return
end

% Look for zoh/foh string
ioh = find(strcmpi('zoh',ExtraArgs) | strcmpi('foh',ExtraArgs));
if ~isempty(ioh)
   InterpRule = ExtraArgs{ioh};
   ExtraArgs(ioh) = [];
else
   InterpRule = 'auto';
end
ExtraArgs = [ExtraArgs cell(1,3-length(ExtraArgs))];
[u,t,x0] = deal(ExtraArgs{1:3});

% Compute sample times
nsys = length(sys);
Ts = zeros(nsys,1);
for ct=1:nsys
   Ts(ct) = getTs(sys{ct});
end

% Check input data   
if isempty(u),
   % Convenience for systems w/o input
   ns = max([size(u),length(t)]);
   if ns==0
      ctrlMsgUtils.error('Control:analysis:rfinputs20')
   else
      u = zeros(ns,0);
   end
else
   su = size(u);
   nu = size(sys{1},2);
   if length(su)>2 || ~(isnumeric(u) || islogical(u)) || ...
         ~isreal(u) || ~all(isfinite(u(:)))
      ctrlMsgUtils.error('Control:analysis:rfinputs18')
   elseif ~any(su==nu)
      ctrlMsgUtils.error('Control:analysis:rfinputs19')
   elseif su(2)~=nu
      % Transpose U (users often supply a row vector for SISO systems)
      u = u.';
   end
   u = full(double(u));
   ns = size(u,1);
end

% Need at least two samples
if ns<2
   ctrlMsgUtils.error('Control:analysis:rfinputs18')
end

% Check time vector
if isempty(t)
   % If no time vector and all systems discrete or all cts with same Ts then use equisampled t
   Tsref = abs(Ts(1));
   if any(Ts==0)
      ctrlMsgUtils.error('Control:analysis:rfinputs05')
   elseif all(Ts==-1) || (Tsref>0 && all(Ts==Tsref)),
      % All sample times are equal
      t = Tsref * (0:1:ns-1)';
   else
      ctrlMsgUtils.error('Control:analysis:rfinputs06')
   end
end
t0 = t(1:min(1,end));
[t,x0] = LocalTimeRespCheck(t,t0,x0);
if length(t)~=ns
   ctrlMsgUtils.error('Control:analysis:rfinputs19')
end

ExtraArgs = {t,x0,u,InterpRule};


%%%%%%%%%%%%%%%%%%%
% LocalSigmaCheck %
%%%%%%%%%%%%%%%%%%%
function ExtraArgs = LocalSigmaCheck(ExtraArgs,sys)
% Checks extra inputs for SIGMA
w = []; 
if ~isempty(ExtraArgs) && ~ischar(ExtraArgs{1}) % for TYPE = 'inv'
   w = FreqVectorCheck(ExtraArgs{1});
   ExtraArgs(1) = [];
end
% Type argument
if isempty(ExtraArgs)
   type = 0;
else
   type = ExtraArgs{1};
   if strcmpi(type,'inv')
      type = 1;
   end
end
if ~isequal(size(type),[1 1]) || ~any(type==[0 1 2 3])
    ctrlMsgUtils.error('Control:analysis:rfinputs07')
elseif type>0
   % Check systems are square for TYPE 1,2,3
   for ct=1:length(sys),
      [ny,nu] = size(sys{ct});
      if ny~=nu,
         ctrlMsgUtils.error('Control:analysis:rfinputs07')
      end
   end
end
ExtraArgs = {w type};


%%%%%%%%%%%%%%%%%%%%%%%
% LocalRootLocusCheck %
%%%%%%%%%%%%%%%%%%%%%%%
function [ExtraArgs,sys] = LocalRootLocusCheck(ExtraArgs,sys)
% Checks extra inputs for INITIAL
if isempty(ExtraArgs)
   ExtraArgs = {[]};
end
for ct=1:length(sys)
   if isdt(sys{ct}) && hasdelay(sys{ct})
      % Map delay times to poles at z=0 in discrete-time case
      sys{ct} = delay2z(sys{ct});
   end
end


%%%%%%%%%%%%%%%%%
% LocalCheckTX0 %
%%%%%%%%%%%%%%%%%
function [t,x0] = LocalCheckTX0(t,t0,x0,Ts)
% Check that 1) time input is valid vector or final time, and 2) x0 is valid
% Last argument = absolute start time (e.g., t=0 for step)
[t,x0] = LocalTimeRespCheck(t,t0,x0);

% Check T against system sample times
lt = length(t);
if lt==0 && any(Ts<0) && any(Ts>0),
   % No time vector or final time specified
   ctrlMsgUtils.error('Control:analysis:rfinputs08')
elseif lt==1 && all(Ts==-1) && ~isequal(t,round(t))
   % Final time specified
   ctrlMsgUtils.error('Control:analysis:rfinputs09')
end  


%%%%%%%%%%%%%%%%%%%%
% LocalConvert2LTI %
%%%%%%%%%%%%%%%%%%%%
function sys = LocalConvert2LTI(sys)
% Convert all models to @lti subclasses
if ~isa(sys,'lti')
    % Must comes from IDENT at this point
    % Check the number of inputs to the model
    nu = size(sys,'nu');
    if nu > 0
        % If the model is not a time series or output spectrum extract the
        % model from the input channels to output channels.
        sys = sys('m');
    elseif nu == 0 && isa(sys,'idfrd')
        % If the model is an output spectrum model error out.
        ctrlMsgUtils.error('Control:analysis:rfinputs10')
    else
        % If the model is a time series idmodel extract the model from the 
        % noise channels to output channels 
        sys = sys('n');
    end
    % Perform the conversion of the IDENT models to LTI Models
    if isa(sys,'idss')
        sys = ss(sys);
    elseif isa(sys,'idfrd')
        sys = frd(sys);
    else
        sys = tf(sys);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckComputability %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = LocalCheckComputability(sys,ResponseType,varargin)
% Checks that all requested system response are computable
% VARARGIN = {t,x0,u}
% Hide warnings, e.g., from ISPROPER
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
% Check computability for individual models
D = getPrivateData(sys);
try
   for ct=1:numel(D)
      D(ct) = utCheckComputability(D(ct),ResponseType,varargin{:});
   end
catch ME
   throw(ME)
end
sys = setPrivateData(sys,D);

%%%%%%%%%%%%%%%%%%%
% FreqVectorCheck %
%%%%%%%%%%%%%%%%%%%
function w = FreqVectorCheck(w)
% Checks frequency input is valid vector or frequency range.

% Error checking
if isempty(w)
   w = [];
elseif iscell(w)
   % W = {WMIN , WMAX}
   if numel(w)~=2 || ~isscalar(w{1}) ||  ~isscalar(w{2}) 
       ctrlMsgUtils.error('Control:analysis:rfinputs11')
   end
   wmin = w{1}(1); 
   wmax = w{2}(1);
   if ~isnumeric(wmin) || ~isreal(wmin) || ~isnumeric(wmax) || ~isreal(wmax) || wmin<=0 || wmax<=wmin
      ctrlMsgUtils.error('Control:analysis:rfinputs11')
   end
   w = {full(double(wmin)),full(double(wmax))};
else
   if ~isnumeric(w) || ~isreal(w) || ~isvector(w) || any(w<0) || any(isnan(w))
       ctrlMsgUtils.error('Control:analysis:rfinputs12')
   end
   w = full(double(w(:)));
end

%%%%%%%%%%%%%%%%%%%%%%
% LocalTimeRespCheck %
%%%%%%%%%%%%%%%%%%%%%%
function [t,x0] = LocalTimeRespCheck(t,t0,x0)
% Checks input arguments to time response functions.
ni = nargin;

% RE: T0 = start time of event-based simulation (e.g., t0=0 for step)
if ~isempty(t)
   if isscalar(t)
      % Final time
      if ~isnumeric(t) || ~isreal(t)
          ctrlMsgUtils.error('Control:analysis:rfinputs13')
      end
      t = full(double(t));
      if t<=0,
         ctrlMsgUtils.error('Control:analysis:rfinputs13')
      elseif ~isfinite(t)
         t = [];
      end
   elseif isvector(t)
      % Time vector specified
      if ~isnumeric(t) || ~isreal(t)
          ctrlMsgUtils.error('Control:analysis:rfinputs14')
      end
      t = full(double(t(:)));  t0 = double(t0);
      dt = t(2)-t(1);
      if any(diff(t)<=0) || ~all(isfinite(t)) || any(abs(diff(t)-dt)>0.01*dt)
         ctrlMsgUtils.error('Control:analysis:rfinputs14')
      elseif t(1)<t0
         % Simulation with event at t=t0 (step,...)
         ctrlMsgUtils.error('Control:analysis:rfinputs15',sprintf('%0.3g',t0))
      end
      
      % Enforce even spacing
      nt0 = round((t(1)-t0)/dt);
      t = t0 + dt * (nt0:nt0-1+length(t))';
   else
       ctrlMsgUtils.error('Control:analysis:rfinputs16')
   end  
end

% Initial condition
if ni>2 && ~isempty(x0)
   if ~isnumeric(x0) || ~isreal(x0) || ~isvector(x0) || ~all(isfinite(x0))
       ctrlMsgUtils.error('Control:analysis:rfinputs17')
   end
   x0 = full(double(x0(:)));
end


