function lqgtrk = lqgtrack(kest,k,varargin)
%LQGTRACK Forms a Linear-Quadratic-Gaussian (LQG) servo controller
%
%   LQGTRACK builds an LQG compensator C with integral action for the loop
%   below. This compensator ensures that the output y tracks the reference
%   command r and rejects process disturbances w and measurement noise v.
%   LQGTRACK assumes that r and y are of the same length.
%
%                                       | w             | v
%                       .----------.    |   .-------.   |
%          r   -------->|          |    '-->|       |   V
%                       |    C     |------->| Plant |---O--.-----> y
%          y   .------->|          |  u     |       |      |
%              |        '----------'        '-------'      |
%              |                                           |
%              '-------------------------------------------'
%
%
%   C = LQGTRACK(KEST,K) or C = LQGTRACK(KEST,K,'2dof') produces a
%   two-degree-of-freedom compensator C by connecting the Kalman estimator
%   KEST and the state-feedback gain K as shown below. C has inputs [r;y]
%   and generates the command u = -K [x_e; xi] where x_e is the Kalman
%   estimate of the plant state and xi is the integrator output. This
%   compensator should be connected to the plant output y using positive
%   feedback.
%
%              .---------------------------------------------.
%              | u  .----------.  y_e                        |
%              '--->|          |-->o                         |
%                   |   Kest   |----------.                  |
%        .--------->|          |   x_e    |     .----.       |
%        |          '----------'          '---->| -K |       |
%        |                                .---->|    |-------'---> u
%        |     r-y  .----------.          |     '----'
%    r ------O----->|Integrator|----------'
%        |   ^      '----------'    xi
%        |   |-
%    y --'---'
%
%
%   The size of the gain matrix K determines the length of xi which is used
%   to compute the similarly equal length of y.
%
%   C = LQGTRACK(KEST,K,'1dof') produces a one-degree-of-freedom
%   compensator C that takes the tracking error e = r - y as input instead
%   of [r;y] (see diagram below).
%
%              .---------------------------------------------.
%              | u     .----------.  y_e                     |
%              '------>|          |-->o                      |
%               .--.   |   Kest   |----------.               |
%    e -----.-->|-1|-->|          |  x_e     |     .----.    |
%      r-y  |   '--'   '----------'          '---->|-K  |    |
%           |                                .---->|    |----'---> u
%           |          .----------.          |     '----'
%           '--------->|Integrator|----------'
%                      '----------'    xi
%
%
%   C = LQGTRACK(KEST,K,...,CONTROLS) handles estimators that have access
%   to additional known commands Ud. The index vector CONTROLS specifies
%   which inputs of KEST are the control channels u. The resulting
%   compensator C has inputs [Ud;r;y] in the 2-dof case, and [Ud;e] in the
%   1dof case. The corresponding compensator structure is shown below for
%   the 2dof case:
%
%              .---------------------------------------------.
%              | u  .----------.  y_e                        |
%              '--->|          |-->o                         |
%   Ud ------------>|   Kest   |----------.                  |
%        .--------->|          |   x_e    |     .----.       |
%        |          '----------'          '---->| -K |       |
%        |                                .---->|    |-------'---> u
%        |     r-y  .----------.          |     '----'
%    r ------O----->|Integrator|----------'
%        |   ^      '----------'    xi
%        |   |-
%    y --'---'
%
%
%   LQGTRACK supports both continuous- and discrete-time systems. In
%   discrete-time, integrators are based on forward Euler (see LQI for
%   details) and the state estimate x_e is x[n|n] or x[n|n-1] depending on
%   the type of estimator (see KALMAN for details).
%
%   See also  LQG, LQI, KALMAN, LQGREG, LQR.

%   Author: Murad Abu-Khalaf April 18, 2008
%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2010/02/08 22:28:39 $
ni = nargin;
error(nargchk(2,4,ni));
if ndims(kest)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqgtrack')
elseif ~isa(k,'double') || ndims(k)>2,
   ctrlMsgUtils.error('Control:design:lqgtrack6')
end

nx = order(kest);  % # of estimated states = # of plant states
[kest_nout, kest_nin]= size(kest); % kest_nout, kest_nin: # of I/O channels
nu  = size(k,1);                   % # of control inputs of the plant                       
nxi = size(k,2) - nx;              % # of integrators = # measured plant outputs
Plant_nin = kest_nin - nxi;        % # of known (deterministic) plant inputs
Ts  = kest.Ts;

% Check if nxi is properly set
if nxi <= 0
   ctrlMsgUtils.error('Control:design:lqgtrack1');
end

% Check if dimensions of KEST are consistent
if kest_nout<nx || kest_nin<nxi+nu
   ctrlMsgUtils.error('Control:design:lqgtrack7',nxi+nu,nx);
end

% Parse extra input arguments
controls = 1:Plant_nin;   % Assume all known plant inputs to be controls
dof = '2dof';
for ct = 1:length(varargin)
    arg = varargin{ct};
    if isnumeric(arg)
        controls = arg;
        if any(controls<=0) || any(controls>Plant_nin),
            ctrlMsgUtils.error('Control:general:IndexOutOfRange',...
                'lqgtrack(KEST,K,CONTROLS)','CONTROLS');
        end
    elseif any(strcmpi(arg,{'1dof','2dof'}))
        dof = arg;
    else
        ctrlMsgUtils.error('Control:design:lqgtrack2');
    end
end

% Check size of CONTROLS and get Ud channels
if length(controls)~=nu
    ctrlMsgUtils.error('Control:design:lqgtrack5');
end
KnownInputs = 1:Plant_nin; KnownInputs(controls) = [];

% State Estimates should be last nx outputs of kest.
StateEstim  = (kest_nout-nx+1):kest_nout;
OutputEstim = 1:(kest_nout-nx);

% Check if this is continuous time or discrete-time
if Ts==0             % Continuous-time
    Aint = zeros(nxi);
    Bint = eye(nxi);
else                 % Discrete-time
    Aint = eye(nxi);
    Bint = eye(nxi)*abs(Ts);
end

% Get I/O names of KEST
Kest_InputNames = kest.InputName;

% Assign unique names to the I/O channels of KEST in preparation for
% CONNECT
PlantInputNames = strseq('u',1:Plant_nin);
uNames  = PlantInputNames(controls);
UdNames = PlantInputNames(KnownInputs);
yNames  = strseq('y',1:nxi);
% Static systems have no states
xeNames = localAppendStr(strseq('x',1:length(StateEstim)),'_e');
% KEST outputs may not include measurement estimates y_e
yeNames = localAppendStr(strseq('y',OutputEstim),'_e');
kest.InputName_ = [PlantInputNames;yNames];
kest.OutputName_ = [yeNames;xeNames];

% Setup other signal names
eNames  = strseq('e',1:nxi);
xiNames = strseq('xi',1:nxi);

% Form integrator, and name inputs, and states.
integrator_sys = ss(Aint,Bint,eye(nxi),zeros(nxi),Ts);
integrator_sys.InputName_ = eNames;
integrator_sys.OutputName_ = xiNames;
integrator_sys.StateName = xiNames;

% Form feedback gains block
kss = ss(-k);
kss.InputName_ = [xeNames; xiNames];
kss.OutputName_ = uNames;

% Connect the blocks in accordance with dof
if strcmpi(dof,'1dof')
   % Form a gain block from e to -e that connects to y channels of kest
   Gain = ss(-eye(nxi));
   Gain.InputName_ = eNames;
   Gain.OutputName_ = yNames;
   [lqgtrk,SingularFlag] = connect(kest,integrator_sys,Gain,kss,[UdNames;eNames],uNames);
else
   % 2dof case
   rNames  = strseq('r',1:nxi);
   Sum = sumblk(eNames,rNames,yNames,'+-'); % Form a summation junction
   [lqgtrk,SingularFlag] = connect(kest,integrator_sys,Sum,kss,[UdNames;rNames;yNames],uNames);
end

% LQGTRK may be improper for "current" Kalman estimators (case I-K*MD singular).
if SingularFlag
    ctrlMsgUtils.error('Control:design:lqgtrack4')
end

% Use I/O names from KEST and define I/O groups
uNames  = Kest_InputNames(controls);
UdNames = Kest_InputNames(KnownInputs);
nUd = length(UdNames);
lqgtrk.OutputName = uNames;
lqgtrk.OutputGroup = struct('Controls',1:nu);
if strcmpi(dof,'1dof')
   lqgtrk.InputName = [UdNames ; eNames];
   lqgtrk.InputGroup = struct('KnownInput',1:nUd,'Error',nUd+1:nUd+nxi);
else
   yNames = Kest_InputNames(Plant_nin+1:end);
   lqgtrk.InputName = [UdNames ; rNames; yNames];
   lqgtrk.InputGroup = struct('KnownInput',1:nUd,'Setpoint',nUd+1:nUd+nxi,...
      'Measurement',nUd+nxi+1:nUd+2*nxi);
end


% ------------------------- Local functions ------------------------------
function names = localAppendStr(names,str)
for ct=1:length(names)
   names{ct} = [names{ct} str];
end
