function h = pidtool(varargin)
%PIDTOOL  Interactive GUI tool for PID controller design.
%
%    PIDTOOL opens the PID Tuner for designing a PID controller. The
%    control system configuration used by the PID Tuner is 
%
%             r --->O--->[ PID ]--->[ Plant ]---+---> y
%                 - |                           |
%                   +---------------------------+
%
%    To import a plant model into the PID Tuner, select the first toolbar
%    button that launches the Import Linear System dialog.  
%
%    PIDTOOL(SYS,TYPE) designs a PID controller for plant SYS. SYS is a
%    single-input-single-output LTI system such as TF, ZPK, SS, FRD or a
%    linear model produced by System Identification Toolbox such as IDARX,
%    IDFRD, IDGREY, IDPOLY, IDPROC and IDSS. TYPE defines controller type,
%    and can be one of the following strings:
%
%       'P'     Proportional only control
%       'I'     Integral only control
%       'PI'    PI control
%       'PD'    PD control  
%       'PDF'   PD control with first order derivative filter 
%       'PID'   PID control
%       'PIDF'  PID control with first order derivative filter
%
%    For discrete-time SYS, the PID controller has the same sample time as
%    SYS.
%
%    PIDTOOL(SYS,C) takes a LTI system C as the baseline controller so that
%    you can compare performances between the designed PID and the baseline
%    controller.  IF C is a PID or PIDSTD object, the designed controller
%    has the same type, form, and discretization methods as C. C can also
%    be a SS, TF, or ZPK system.
%
%    When SYS is (1) a FRD system or (2) a SS system that has internal
%    delay and cannot be converted into a ZPK system, the PID tuner assumes
%    that the plant does not have unstable poles. If there are unstable
%    poles, you must open the Import Linear System dialog after PID Tuner
%    is launched and import SYS with the number of unstable poles specified
%    in the dialog.
%
%   See also PIDTUNE
 
% Author(s): Rong Chen 30-Apr-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/05/10 16:58:07 $

ni = nargin;
if ni==0
    sys = zpk(1);
    C = 'p';
elseif ni==1
    sys = varargin{1};
    C = 'pi';
elseif ni==2
    sys = varargin{1};
    C = varargin{2};
else
    ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','pidtool','pidtool');
end

%% pre-process sys
if isa(sys,'ltipack.SingleRateSystem')
    if ~issiso(sys)
        ctrlMsgUtils.error('Control:design:pidtune1','pidtool');
    end
    if nmodels(sys)~=1
        ctrlMsgUtils.error('Control:design:pidtune6','pidtool');
    end
elseif isa(sys,'idmodel')
    % get size information
    sz = size(sys);
    if ~isequal(sz(1:2),[1 1])
        ctrlMsgUtils.error('Control:design:pidtune1','pidtool');
    end
    % convert to @ss (SS is the best LTI representation for idmodel systems)
    sys = ss(subsref(sys,struct('type','()','subs',{{'m'}})));
elseif isa(sys,'idfrd')
    % get size information
    sz = size(sys);
    if ~isequal(sz(1:2),[1 1])
        ctrlMsgUtils.error('Control:design:pidtune1','pidtool');
    end
    % convert to @frd
    sys = frd(sys);
else
    ctrlMsgUtils.error('Control:design:pidtune1','pidtool');
end

%% pre-process Ts: -1 is not accepted
Ts = sys.Ts;
if Ts<0
    ctrlMsgUtils.error('Control:design:pidtune4','pidtool');
end

%% pre-process Type and C (@ss, @tf, @zpk, @pid, @pidstd, @ltiblock.*)
if ischar(C)
    % get type
    if ~any(strcmpi(C,{'p','i','pi','pd','pdf','pid','pidf'}))
        ctrlMsgUtils.error('Control:design:pidtune2','pidtool','pidtool');
    end
    Type = C;
    Baseline = [];
elseif (isa(C,'pid') || isa(C,'pidstd'))
    % check array
    if nmodels(C)~=1    
        ctrlMsgUtils.error('Control:design:pidtune2','pidtool','pidtool');
    end
    % check sample time
    if  C.Ts~=Ts
        ctrlMsgUtils.error('Control:design:pidtune10','pidtool');
    end    
    Type = getType(C);
    Baseline = C;
elseif isa(C,'ltipack.SingleRateSystem')
    % check FRD model, siso, array
    if isa(C,'FRDModel') || ~issiso(C) || nmodels(C)~=1
        ctrlMsgUtils.error('Control:design:pidtune2','pidtool','pidtool');
    end
    % check sample time
    if C.Ts~=Ts
        ctrlMsgUtils.error('Control:design:pidtune10','pidtool');
    end
    Type = 'pi';
    Baseline = C;
else
    ctrlMsgUtils.error('Control:design:pidtune2','pidtool','pidtool');
end

%% start GUI
if nargout>0
    h = pidtool.tunerdlg(sys,Type,Baseline);
else
    pidtool.tunerdlg(sys,Type,Baseline);
end
