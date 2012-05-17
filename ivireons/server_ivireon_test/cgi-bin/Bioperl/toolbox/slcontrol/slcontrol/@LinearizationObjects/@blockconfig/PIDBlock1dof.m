function blockstruct = PIDBlock1dof(this,blockname,parameterdata) %#ok<INUSL>
% PIDBlock1dof  This is the configuration file for the 1 dof PID Controller
% block in simulink/Continuous and simulink/Discrete added in 2009b.

% Author(s): Murad Abu-Khalaf  16-March-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2010/03/22 04:25:50 $

TunableParameters = [
    parameterdata(1)       % Controller  (not tunable)
    parameterdata(2)       % TimeDomain  (not tunable)
    parameterdata(6)       % Form (not tunable)
    parameterdata(4)       % IntegratorMethod (not tunable)
    parameterdata(5)       % FilterMethod (not tunable)
    parameterdata(7)       % P
    parameterdata(8)       % I
    parameterdata(9)       % D
    parameterdata(10)      % N
    parameterdata(3)];     % SampleTime (not tunable)

TunableParameters(1).Tunable  = 'off'; % Controller
TunableParameters(2).Tunable  = 'off'; % TimeDomain
TunableParameters(3).Tunable  = 'off'; % Form
TunableParameters(4).Tunable  = 'off'; % IntegratorMethod
TunableParameters(5).Tunable  = 'off'; % FilterMethod
TunableParameters(10).Tunable = 'off'; % SampleTime

ctrlstruct = localgetstruct(TunableParameters);

% Setup the appropriate constraints, Eval and Inv functions
switch upper(ctrlstruct.Controller)
    case 'PID'
        % Get the Sample time
        rto = get_param(sprintf('%s/Integral Gain',blockname),'RunTimeObject');
        % Create the constraints
        Constraints = struct('MaxZeros',2,'MaxPoles',2,'isStaticGainTunable',true);
    case 'PI'
        % Get the Sample time
        rto = get_param(sprintf('%s/Integral Gain',blockname),'RunTimeObject');
        Constraints = struct('MaxZeros',1,'MaxPoles',1,'isStaticGainTunable',true);
        TunableParameters(8).Tunable  = 'off'; % D
        TunableParameters(9).Tunable  = 'off'; % N
    case 'PD'
        % Get the Sample time
        rto = get_param(sprintf('%s/Derivative Gain',blockname),'RunTimeObject');
        Constraints = struct('MaxZeros',1,'MaxPoles',1,'isStaticGainTunable',true);
        TunableParameters(7).Tunable  = 'off'; % I
    case 'I'
        % Get the Sample time
        rto = get_param(sprintf('%s/Integral Gain',blockname),'RunTimeObject');
        if strcmpi(ctrlstruct.TimeDomain,'Discrete-time')
            Constraints = struct('MaxZeros',1,'MaxPoles',1,'isStaticGainTunable',true);
        else
            Constraints = struct('MaxZeros',0,'MaxPoles',1,'isStaticGainTunable',true);
        end
        TunableParameters(6).Tunable  = 'off'; % P
        TunableParameters(8).Tunable  = 'off'; % D
        TunableParameters(9).Tunable  = 'off'; % N
    case 'P'
        % Get the Sample time
        rto = get_param(sprintf('%s/Proportional Gain',blockname),'RunTimeObject');
        Constraints = struct('MaxZeros',0,'MaxPoles',0,'isStaticGainTunable',true);
        TunableParameters(7).Tunable  = 'off'; % I
        TunableParameters(8).Tunable  = 'off'; % D
        TunableParameters(9).Tunable  = 'off'; % N
end
TunableParameters(10).Value = rto.SampleTimes(1);

blockstruct = struct('TunableParameters',TunableParameters,...
    'EvalFcn',@LocalEvalFcn,...
    'InvFcn',@LocalInvFcn,...
    'Constraints',Constraints,...
    'Inport',1,...
    'Outport',1);



%---------------- Branch local Eval functions -----------------------------
function [Cfree,Cfixed] = LocalEvalFcn(TunableParameters)

ctrlstruct = localgetstruct(TunableParameters);
P  = TunableParameters(6).Value;
I  = TunableParameters(7).Value;
D  = TunableParameters(8).Value;
N  = TunableParameters(9).Value;
Ts = TunableParameters(10).Value;

try
    [Cfree,Cfixed] = utPID1dof_getCfreeCfixedfromPIDN(P,I,D,N,Ts,ctrlstruct);
catch ME
    rethrow(ME);
end


%---------------- Branch local Inv functions -----------------------------

% Source of the ZPK could be from the original PIDN values or from
% graphical tuning, Automated tunining, etc. This should handle any ZPK
% thrown at it.
function TunableParameters = LocalInvFcn(TunableParameters,z,p,k)

ctrlstruct = localgetstruct(TunableParameters);
Ts = TunableParameters(10).Value;

try
    [P, I, D, N] = utPID1dof_getPIDNfromZPK(z,p,k,Ts,ctrlstruct);
    if ~isempty(P)
        TunableParameters(6).Value = P;
    end
    if ~isempty(I)
        TunableParameters(7).Value = I;
    end
    if ~isempty(D)
        TunableParameters(8).Value = D;
    end
    if ~isempty(N)
        TunableParameters(9).Value = N;
    end
catch ME
    rethrow(ME);
end

function ctrlstruct = localgetstruct(TunableParameters)
% Should work whether Mask parameters are evaluated or not.
if isnumeric(TunableParameters(1).Value)
    Controller = {'PIDF','PI','PDF','P','I'};
    ctrlstruct.Controller = Controller{TunableParameters(1).Value};
else
    ctrlstruct.Controller = TunableParameters(1).Value;
end
if isnumeric(TunableParameters(2).Value)
    TimeDomain = {'Continuous-time','Discrete-time'};
    ctrlstruct.TimeDomain = TimeDomain{TunableParameters(2).Value};
else
    ctrlstruct.TimeDomain = TunableParameters(2).Value;
end
if isnumeric(TunableParameters(3).Value)
    Form = {'Ideal','Parallel'};
    ctrlstruct.Form = Form{TunableParameters(3).Value};
else
    ctrlstruct.Form = TunableParameters(3).Value;
end
if isnumeric(TunableParameters(4).Value)
    IntegratorMethod = {'Forward Euler','Backward Euler','Trapezoidal'};
    ctrlstruct.IntegratorMethod = IntegratorMethod{TunableParameters(4).Value};
else
    ctrlstruct.IntegratorMethod = TunableParameters(4).Value;
end
if isnumeric(TunableParameters(5).Value)
    FilterMethod = {'Forward Euler','Backward Euler','Trapezoidal'};
    ctrlstruct.FilterMethod = FilterMethod{TunableParameters(5).Value};
else
    ctrlstruct.FilterMethod = TunableParameters(5).Value;
end
