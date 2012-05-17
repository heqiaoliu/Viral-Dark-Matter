function sysOut = pid(varargin)
%PID  Create a PID controller in parallel form.
%
%  Construction:
%    SYS = PID(Kp,Ki,Kd,Tf) creates a continuous-time PID controller
%    in parallel form with a first order derivative filter:
%
%                  Ki       Kd*s
%           Kp + ------ + ----------
%                   s       Tf*s+1
%
%    When Kp, Ki, Kd and Tf are scalar, the output SYS is a PID
%    object that represents a single-input-single-output PID
%    controller. The following rules apply to construct a valid PID
%    controller in parallel form:
%
%       Kp (proportional gain) must be real and finite
%       Ki (integral gain) must be real and finite
%       Kd (derivative gain) must be real and finite
%       Tf (filter time constant) must be real, finite and non-negative
%
%    The default values are Kp=1, Ki=0, Kd=0 and Tf=0. If a parameter
%    is omitted, its default value is used.  For example:
%       
%       PID(Kp) returns a proportional only controller
%       PID(Kp,Ki) returns a PI controller
%       PID(Kp,Ki,Kd) returns a PID controller
%       PID(Kp,Ki,Kd,Tf) returns a PID controller with derivative filter
%
%    SYS = PID(Kp,Ki,Kd,Tf,Ts) creates a discrete-time PID controller
%    with sample time Ts (a positive real value). A discrete time PID
%    controller is obtained by discretizing the integrators with
%    numerical integration methods:
%
%        The above continuous-time PID formula can be rewritten in
%        an equivalent expression that contains two integrators:
%
%                      1          Kd
%           Kp + Ki * --- + ---------------
%                      s              1
%                              Tf  + ---
%                                     s
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
%    that set the various properties of PID systems. Type LTIPROPS
%    for details of the properties that are common for LTI systems.
%
%    You can create arrays of PID objects by using ND arrays for
%    Kp, Ki, Kd and Tf parameters.  For example, if Kp and Ki are
%    arrays of size [3 4], then
%
%       SYS = PID(Kp,Ki)
%
%    creates a 3-by-4 array of PID objects.  You can also use indexed
%    assignment and STACK to build PID arrays:
%
%       SYS = PID(zeros(2,1))          % create 2x1 array of PID controllers
%       SYS(:,:,1) = PID(1)            % assign 1st PID controller
%       SYS(:,:,2) = PID(2,3)          % assign 2st PID controller
%       SYS = STACK(1,SYS,PID(4,5,6))  % add 3rd PID controller to array
%
%  Conversion:
%    PIDSYS = PID(SYS) converts the dynamic system SYS to a PID object.
%    An error is thrown when SYS cannot be expressed as a PID
%    controller in parallel form. If SYS is a LTI array, PIDSYS is an
%    array of PID objects.
%
%    PIDSYS = PID(SYS,'IFormula',Value1,'DFormula',Value2) converts SYS
%    to PIDSYS with specified discrete-time formulas for the integrator
%    and derivative terms.
%
%  See also PIDSTD, TF.

%   Author(s): Rong Chen
%   Copyright 2009-2010 MathWorks, Inc.
%	$Revision: 1.1.8.5.2.1 $  $Date: 2010/06/24 19:43:23 $

try
    [ConstructFlag,InputList] = lti.parseConvertFcnInputs('pid',varargin);
    if ConstructFlag
        ctrlMsgUtils.error('Control:ltiobject:pidOperations6','PID');
    else
        % Inherit metadata and Variable
        sys = InputList{1};
        if isa(sys,'FRDModel')
           ctrlMsgUtils.error('Control:transformation:pid1',class(sys))
        elseif issiso(sys)
           Options = ltipack.AbstractPID.getConversionOptions(InputList(2:end),'pid');
           sysOut = copyMetaData(sys,pid_(sys,Options));
        else
           ctrlMsgUtils.error('Control:ltiobject:pidOperations5','PID');
        end
    end
catch E
    throw(E)
end
