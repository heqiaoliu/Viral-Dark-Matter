function rlqg = lqgreg(kest,k,varargin)
%LQGREG  Form linear-quadratic-Gaussian (LQG) regulator
%
%   RLQG = LQGREG(KEST,K) produces an LQG regulator by connecting the
%   Kalman estimator KEST designed with KALMAN and the state-feedback gain
%   K designed with (D)LQR or LQRY:
%
%           .----------------------------.
%         u |                            |
%           |    .------.                |
%           '--->|      |-->o y_e        |
%                | KEST |       .----.   |
%     y -------->|      |------>| -K |---'-----> u
%                '------'  x_e  '----'
%
%   The resulting regulator RLQG has input y and generates the control
%   signal u = -K x_e where x_e is the Kalman state estimate based on the
%   measurements y.  This regulator should be connected to the plant using
%   positive feedback.  LQGREG assumes that u and x_e are the first inputs
%   and last outputs of KEST.
%
%   For discrete systems, RLQG generates the control signal u = -K x[n|n]
%   when KEST is the "current" Kalman estimator, and u = -K x[n|n-1] when
%   KEST is the "delayed" Kalman estimator (type HELP KALMAN for details).
%
%   RLQG = LQGREG(KEST,K,CONTROLS) handles estimators that have 
%   access to additional known plant inputs Ud.  The index vector
%   CONTROLS then specifies which estimator inputs are the 
%   controls u, and the LQG regulator has input [Ud;y]:
%
%           .----------------------------.
%         u |                            |
%           |    .------.                |
%           '--->|      |-->o y_e        |
%    Ud -------->| KEST |       .----.   |
%     y -------->|      |------>| -K |---'-----> u
%                '------'  x_e  '----'
%
%   See also LQR, LQRY, LQRD, KALMAN, LQG, REG, SS.

%   Author(s): P. Gahinet  8-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2010/02/08 22:28:38 $

ni = nargin;
error(nargchk(2,4,ni));
if ndims(kest)>2
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqgreg')
elseif ~isa(k,'double') || ndims(k)>2,
   ctrlMsgUtils.error('Control:design:lqgreg1')
end

% Check dimensions
[Nu,Nx] = size(k);
[kny,knu] = size(kest);
knx = order(kest);
if Nx~=knx,
   ctrlMsgUtils.error('Control:design:lqgreg2')
elseif kny<Nx,
   ctrlMsgUtils.error('Control:design:lqgreg3')
elseif Nu>knu,
   ctrlMsgUtils.error('Control:design:lqgreg4')
end
StateEstim = kny-Nx+1:kny;  % State estimates should be last Nx outputs of KEST

% Look for 'current' flag, issue warning, and then ignore it
ix = find(strcmp(varargin,'current'));
if ~isempty(ix)
   varargin(:,ix) = [];  ni = ni-1;
   ctrlMsgUtils.warning('Control:design:ObsoleteFlagInLQGREG');
end

% Determine which inputs of KEST are the controls u
if ni > 2
    controls = varargin{1};
    if ~isnumeric(controls)
        % Controls should be numeric
        ctrlMsgUtils.error('Control:design:lqgreg7')
    end
else
    controls = 1:Nu;
end
        
% Check dims of CONTROLS
if any(controls<=0) || any(controls>knu),
    ctrlMsgUtils.error('Control:general:IndexOutOfRange','lqgreg(KEST,K,CONTROLS)','CONTROLS')
elseif length(controls)~=Nu,
    ctrlMsgUtils.error('Control:design:lqgreg6')
end

% Close the loop
%             +------+
%      +------|  -K  |<----+
%   u  |      +------+     |
%      |                   |
%      |       +------+    |
%      +------>|      |--- | ---> y_e
%   Ud ------->| KEST |    |
%    y ------->|      |----+----> x_e
%              +------+
%
% RE: the state estimates should be the last Nx outputs

% Build the regulator
[rlqg,SingularFlag] = feedback(...
   (-k)*subparen(kest,{StateEstim,':'}),eye(Nu),controls,1:Nu,+1);
if SingularFlag
   % Interconnection of KEST and K gives rise to singular algebraic loop
   % RLQG may be improper or singular for the "current" Kalman estimator
   % x[n|n] = ... + Dux * u[n] (Dux=-MD) (I-KMD) is singular.
   ctrlMsgUtils.error('Control:design:lqgreg8')
end
ukeep = 1:size(rlqg,2);  ukeep(controls) = [];
rlqg = subparen(rlqg,{':', ukeep});  %rlqg(:,controls) = [];

% Keep control names and label all outputs as Controls
if Nu>0
   rlqg.OutputName = kest.InputName(controls);
   rlqg.OutputGroup = struct('Controls',1:Nu);
end

