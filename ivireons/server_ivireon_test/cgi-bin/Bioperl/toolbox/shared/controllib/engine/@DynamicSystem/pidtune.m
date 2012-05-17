function [PID, varargout] = pidtune(sys,C,varargin) 
% PIDTUNE  Tune PID controller.
%  
%      PIDTUNE designs a PID controller C for the unit feedback loop
%  
%               r --->O--->[ C ]--->[ G ]---+---> y
%                   - |                     |
%                     +---------------------+
%
%      Given a plant model G, PIDTUNE automatically tunes the PID gains to
%      balance performance (response time) and robustness (stability
%      margins). You can select from various PID configurations and specify
%      your own response time and phase margin targets with PIDTUNEOPTIONS.
%      Note that increasing performance typically decreases robustness and
%      vice versa.
%  
%      C = PIDTUNE(G,TYPE) designs a PID controller for the single-input,
%      single-output plant G. You can specify G as any LTI model type
%      including TF, ZPK, SS, FRD and the System Identification Toolbox
%      models IDARX, IDFRD, IDGREY, IDPOLY, IDPROC and IDSS. The string
%      TYPE specifies the controller type among the following:
%  
%         'P'     Proportional only control
%         'I'     Integral only control
%         'PI'    PI control
%         'PD'    PD control  
%         'PDF'   PD control with first order derivative filter 
%         'PID'   PID control
%         'PIDF'  PID control with first order derivative filter
%  
%      PIDTUNE returns a PID object C with the same sampling time as G. If
%      G is an array of LTI models, PIDTUNE designs a controller for each
%      plant model and returns an array C of PID objects.
%  
%      C = PIDTUNE(G,C0) constrains C to match the structure of the PID or
%      PIDSTD object C0. The resulting C has the same type, form, and
%      integrator/derivative formulas as C0. For example, to tune a
%      discrete-time PI controller in Standard Form with the sampling time
%      of 0.1 and the Trapezoidal formula, set
%         C0 = pidstd(1,1,'Ts',0.1,'IFormula','T')
%  
%      C = PIDTUNE(G,TYPE,OPTIONS) and C = PIDTUNE(G,C0,OPTIONS) specify
%      additional tuning options such as the target crossover frequency and
%      phase margin. Use PIDTUNEOPTIONS command to create the option set
%      OPTIONS.
%
%      [C,INFO] = PIDTUNE(SYS,...) returns additional tuning data such as
%      closed-loop stability, crossover frequency and phase margin.
%  
%      Example:
%         G = tf(1,[1 3 3 1]); % plant model
%
%         % Design a PI controller in parallel form
%         [C Info] = pidtune(G,'pi') 
%
%         % Double the crossover frequency for faster response
%         OPT = pidtuneOptions('Crossover',2*Info.CrossoverFrequency); 
%         [C Info] = pidtune(G,'pi',OPT) 
%
%         % Improve stability margins by adding derivative action
%         [C Info] = pidtune(G,'pidf',OPT) 
%
%         % Design a discrete-time PIDF controller in Standard Form  
%         C0 = pidstd(1,1,1,1,'Ts',0.1,'IFormula','Trapezoidal',...
%                                      'DFormula','BackwardEuler');
%         [C info] = pidtune(c2d(G,0.1),C0)
%   
%      See also PIDTUNEOPTIONS, PIDTOOL.

% Author(s): Rong Chen 01-Mar-2010
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5.2.1 $ $Date: 2010/06/24 19:43:25 $

ni = nargin;
no = nargout;
if ni<2
    ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','pidtune','pidtune');
end

%% pre-process sys: SISO SingleRateSystem
if ~isa(sys,'ltipack.SingleRateSystem') || ~issiso(sys)
    ctrlMsgUtils.error('Control:design:pidtune1','pidtune');
end

%% pre-process Ts: -1 is not accepted
Ts = sys.Ts;
if Ts<0
    ctrlMsgUtils.error('Control:design:pidtune4','pidtune');
end

%% pre-process Type and C
if ischar(C)
    % get type
    if any(strcmpi(C,{'p','i','pi','pd','pdf','pid','pidf'}))
        C = ltipack.getPIDfromType(C,Ts);
    else
        ctrlMsgUtils.error('Control:design:pidtune2','pidtune','pidtune');
    end
elseif isa(C,'pid') || isa(C,'pidstd')
    % check arraysize
    if prod(getArraySize(C))~=1    
        ctrlMsgUtils.error('Control:design:pidtune2','pidtune','pidtune');
    end
    % check sample time
    if  C.Ts~=Ts
        ctrlMsgUtils.error('Control:design:pidtune10','pidtune');
    end    
else
    ctrlMsgUtils.error('Control:design:pidtune2','pidtune','pidtune');
end

%% pre-process Options
if ni>=3
    % get options
    Options = varargin{1};
    if ~isa(Options,'ltioptions.pidtune') || ~isequal(size(Options),[1 1])
        ctrlMsgUtils.error('Control:design:pidtune3','pidtune','pidtuneOptions');
    end
    if Ts>0 && ~isempty(Options.CrossoverFrequency) && Options.CrossoverFrequency>=pi/Ts
        % for discrete time PID, if specified, WC must be smalled than pi/Ts
        ctrlMsgUtils.error('Control:design:pidtune5');
    end
else
    % default options
    Options = pidtuneOptions; 
end

%% compute PID
[PID,varargout{1:no-1}] = pidtune_(sys,C,Options);

