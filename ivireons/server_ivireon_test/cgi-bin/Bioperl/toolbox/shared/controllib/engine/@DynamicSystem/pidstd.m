function sysOut = pidstd(varargin)
%PIDSTD  Create a PID controller in standard form.
%
%  Construction:
%    SYS = PIDSTD(Kp,Ti,Td,N) creates a continuous-time PID controller
%    in standard form with a first order derivative filter:
%
%                        1          Td*s
%           Kp * ( 1 + ------ + ------------ )
%                       Ti*s     (Td/N)*s+1
%
%    When Kp, Ti, Td and N are scalar, the output SYS is a PIDSTD
%    object that represents a single-input-single-output PID
%    controller. The following rules apply to construct a valid PID
%    controller in standard form:
%
%       Kp (proportional gain) must be real and finite
%       Ti (integral time) must be real and positive
%       Td (derivative time) must be real, finite and non-negative
%       N (filter divisor) must be real and positive
%
%    The default values are Kp=1, Ti=Inf, Td=0 and N=Inf. If a
%    parameter is omitted, its default value is used.  For example:
%       
%       PIDSTD(Kp) returns a proportional only controller
%       PIDSTD(Kp,Ti) returns a PI controller
%       PIDSTD(Kp,Ti,Td) returns a PID controller
%       PIDSTD(Kp,Ti,Td,N) returns a PID controller with derivative filter
%
%    SYS = PIDSTD(Kp,Ki,Kd,Tf,Ts) creates a discrete-time PID
%    controller with sample time Ts (a positive real value). A discrete
%    time PID controller is obtained by discretizing the integrators
%    with numerical integration methods:
%
%        The above continuous-time PID formula can be rewritten in
%        an equivalent expression that contains two integrators:
%
%                       1     1          Td
%           Kp * ( 1 + --- * --- + --------------- )
%                       Ti    s       Td     1
%                                    ---- + ---
%                                      N     s
%
%         When the PID controller is discretized, the two integrators
%         are replaced by the discretizers that are defined in the
%         "IFormula" and "DFormula" properties respectively.  The
%         supported numerical integration methods are:
%
%           'ForwardEuler':     replace 1/s with Ts/(z-1)
%           'BackwardEuler':    replace 1/s with Ts*z/(z-1)
%           'Trapezoidal':      replace 1/s with (Ts/2)*(z+1)/(z-1)
%
%        The default method for both integrators is ForwardEuler. When
%        the PID controller is in continuous time, 'IFormula' and
%        'DFormula' are ignored.
%
%    In all syntax above, the input list can be followed by pairs
%       'PropertyName1', PropertyValue1, ...
%    that set the various properties of PIDSTD systems. Type LTIPROPS
%    for details of the properties that are common for LTI systems.
%
%    You can create arrays of PIDSTD objects by using N-dimension
%    double arrays for Kp, Ti, Td and N parameters.  For example, if Kp
%    and Ti are arrays of size [3 4], then
%
%       SYS = PIDSTD(Kp,Ti)
%
%    creates a 3-by-4 array of PIDSTD objects.  You can also use
%    indexed assignment and STACK to build PIDSTD arrays:
%
%       SYS = PIDSTD(zeros(2,1))          % create 2x1 array of PID controllers
%       SYS(:,:,1) = PIDSTD(1)            % assign 1st PID controller
%       SYS(:,:,2) = PIDSTD(2,3)          % assign 2st PID controller
%       SYS = STACK(1,SYS,PIDSTD(4,5,6))  % add 3rd PID controller to array
%
%  Conversion:
%    PIDSYS = PIDSTD(SYS) converts the dynamic system SYS to a PIDSTD
%    object. An error is thrown when SYS cannot be expressed as a
%    PID controller in standard form. If SYS is a LTI array, PIDSYS is
%    an array of PIDSTD objects.
%
%    PIDSYS = PIDSTD(SYS,'IFormula',Value1,'DFormula',Value2) converts
%    SYS to PIDSYS with specified discrete-time formulas for the
%    integrator and derivative terms.
%
%  See also PID, TF.

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.5.2.1 $  $Date: 2010/06/24 19:43:24 $

try
    [ConstructFlag,InputList] = lti.parseConvertFcnInputs('pidstd',varargin);
    if ConstructFlag
        ctrlMsgUtils.error('Control:ltiobject:pidOperations6','PIDSTD');
    else
        % Inherit metadata and Variable
        sys = InputList{1};
        if isa(sys,'FRDModel')
           ctrlMsgUtils.error('Control:transformation:pid1',class(sys))
        elseif issiso(sys)
           Options = ltipack.AbstractPID.getConversionOptions(InputList(2:end),'pidstd');
           sysOut = copyMetaData(sys,pidstd_(sys,Options));
        else
            ctrlMsgUtils.error('Control:ltiobject:pidOperations5','PIDSTD');
        end
    end
catch E
    throw(E)
end

