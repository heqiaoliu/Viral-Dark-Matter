function Klqg = lqg(sys,qxu,qwv,varargin)
%LQG  Synthesis of LQG regulators and servo-controllers.
%  
%   KLQG = LQG(SYS,QXU,QWV) computes an optimal linear-quadratic Gaussian
%   (LQG) regulator KLQG given a state-space model SYS of the plant and 
%   weighting matrices QXU and QWV.  The dynamic regulator KLQG uses the 
%   measurements y to generate a control signal u that regulates y around 
%   the zero value. Use positive feedback to connect this regulator to the 
%   plant output y.
%
%                                     w |               | v
%                                       |   .-------.   | 
%                       .--------.      '-->|       |   V
%               .------>|  KLQG  |--------->|  SYS  |---O--.-----> y
%               |       '--------'  u       |       |      |
%               |                           '-------'      |
%               |                                          |
%               '------------------------------------------'
%
%   The LQG regulator minimizes the cost function
%  
%         J(u) = Integral [x',u'] * QXU * [x;u] dt
%
%   subject to the plant equations
%
%         dx/dt = Ax + Bu + w
%             y = Cx + Du + v
%
%   where the process noise w and measurement noise v are Gaussian white
%   noises with covariance:
% 
%         E ([w;v] * [w',v']) = QWV.
%
%   LQG uses the commands LQR and KALMAN to compute the LQG regulator. The
%   state-space model SYS should specify the A, B, C, D matrices (see SS
%   for details).
%
%   KLQG = LQG(SYS,QXU,QWV,QI) computes an LQG servo-controller KLQG that
%   uses the setpoint command r and measurements y to generate the control 
%   signal u. KLQG has integral action to ensure that the output y tracks 
%   the command r.
%                                                       
%                                       | w             | v
%                       .----------.    |   .-------.   | 
%          r   -------->|          |    '-->|       |   V
%                       |   KLQG   |------->|  SYS  |---O--.-----> y
%          y   .------->|          |  u     |       |      |
%              |        '----------'        '-------'      |
%              |                                           |
%              '-------------------------------------------'
%
%   The LQG servo-controller minimizes the cost function
%
%         J(u) = Integral [x',u'] * QXU * [x;u] + xi' * Qi * xi dt
%
%   where xi is the integral of the tracking error r-y and SYS,w,v are as
%   described above. For MIMO systems, r, y, and xi must have the same
%   length. LQG uses the commands LQI and KALMAN to compute KLQG.
%
%   KLQG = LQG(SYS,QXU,QWV,QI,'1dof') computes a one-degree-of-freedom
%   servo-controller that takes e=r-y rather than [r;y] as input. 
%
%   KLQG = LQG(SYS,QXU,QWV,QI,'2dof') is equivalent to LQG(SYS,QXU,QWV,QI)
%   and produces the two-degree-of-freedom servo-controller shown above.
%  
%   LQG can be used for both continuous- and discrete-time plants. In
%   discrete-time, LQG uses x[n|n-1] as state estimate (see KALMAN for
%   details).
%
%   See also LQR, LQI, LQRY, KALMAN, SS, CARE, DARE.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2010/02/08 22:28:37 $
ni = nargin;
error(nargchk(3,5,ni))
WantRegulator = (ni<4);

% Check dimensions
[ny,nu,na] = size(sys);
nx = order(sys);
if na>1
   ctrlMsgUtils.error('Control:general:RequiresSingleModel','lqg')
elseif hasdelay(sys)
   throw(ltipack.utNoDelaySupport('lqg',sys.Ts,'all'))
end

% Error if any of QXU or QWV is syntactically wrong, or if the dimensions
% are inconsistent.
if ~(isnumeric(qxu) && ndims(qxu)<3 && all(size(qxu)==nx+nu))
   ctrlMsgUtils.error('Control:design:lqg1',nx+nu)
elseif ~(isnumeric(qwv) && ndims(qwv)<3 && all(size(qwv)==nx+ny))
    ctrlMsgUtils.error('Control:design:lqg2',nx+ny)
end

% Determine Tracker arguments if any
if ni>3
    Qi = varargin{1};
    % Error if any of Qi is syntactically wrong, or has inconsistent dimensions.
    if ~(isnumeric(Qi) && isequal(size(Qi),[ny ny]))
        ctrlMsgUtils.error('Control:design:lqg3',ny)
    end
end
if ni>4
    DOF = varargin{2};
    % Error if wrong string is passed
    if ~any(strcmpi(DOF,{'1dof','2dof'}))
        ctrlMsgUtils.error('Control:design:lqg4');
    end
else
    DOF = '2dof';
end

% LQG Regulator Design
% Kalman filter
sysN = localAddNoise(sys,ny,nu,nx);
Qn = qwv(1:nx,1:nx);
Rn = qwv(nx+1:nx+ny,nx+1:nx+ny);
Nn = qwv(1:nx,nx+1:nx+ny);
try
   Kest = kalman(sysN,Qn,Rn,Nn,'delayed');
catch E
   error(E.identifier,strrep(E.message,'kalman','lqg'))
end

% Optimal state-feedback gains
Q = qxu(1:nx,1:nx);
R = qxu(nx+1:nx+nu,nx+1:nx+nu);
N = qxu(1:nx,nx+1:nx+nu);
if WantRegulator
    try
        K = lqr(sys,Q,R,N);
    catch E
       error(E.identifier,strrep(E.message,'lqr','lqg'))
    end
    % Form the regulator
    Klqg = lqgreg(Kest,K);
else       
    % LQG Tracker compensator design
    try
        K=lqi(sys,blkdiag(Q,Qi),R,[N; zeros(ny,nu)]);
    catch E
        error(E.identifier,strrep(E.message,'lqi','lqg'))
    end        
    % Form the tracker 
    Klqg = lqgtrack(Kest,K,DOF);  
end


% ----------- Local Functions --------------
function sys = localAddNoise(sys,ny,nu,nx)
% D+C(sI-A)B -> [D 0] + C(sI-A)[B,I]
sys = [sys zeros(ny,nx)];
Data = sys.Data_;
Data.b(:,nu+1:nu+nx) = eye(nx);
sys.Data_ = Data;
