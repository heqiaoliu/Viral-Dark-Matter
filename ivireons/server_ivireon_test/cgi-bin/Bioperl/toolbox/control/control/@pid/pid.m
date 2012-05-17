classdef pid < ltipack.AbstractPID
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
    
    %   Author(s): R. Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 1.1.8.6.2.1 $  $Date: 2010/06/24 19:32:23 $
    
    % Public properties with restricted values
    properties (Access = public, Dependent)
        % Proportional gain
        %
        % The "Kp" property stores the proportional gain of a PID
        % controller. Kp must be real and finite. For an array of PID
        % objects, Kp has the same size as the array size. For example,
        %   Kp = 1;
        %   Ki = 2;
        %   Kd = 3;
        %   Tf = 4;
        %   C = pid(Kp,Ki,Kd,Tf);
        % creates a PID controller in parallel form.
        Kp
        % Integral gain
        %
        % The "Ki" property stores the integral gain of a PID controller.
        % Ki must be real and finite. For an array of PID objects, Ki has
        % the same size as the array size. For example,
        %   Kp = 1;
        %   Ki = 2;
        %   Kd = 3;
        %   Tf = 4;
        %   C = pid(Kp,Ki,Kd,Tf);
        % creates a PID controller in parallel form.
        Ki
        % Derivative gain
        %
        % The "Kd" property stores the derivative gain of a PID controller.
        % Kd must be real and finite. For an array of PID objects, Kd has
        % the same size as the array size. For example,
        %   Kp = 1;
        %   Ki = 2;
        %   Kd = 3;
        %   Tf = 4;
        %   C = pid(Kp,Ki,Kd,Tf);
        % creates a PID controller in parallel form.
        Kd
        % Derivative filter time constant
        %
        % The "Tf" property stores the derivative filter time constant of a
        % PID controller. Tf must be real, finite, greater than or equal to
        % 0. For an array of PID objects, Tf has the same size as the array
        % size. For example,
        %   Kp = 1;
        %   Ki = 2;
        %   Kd = 3;
        %   Tf = 4;
        %   C = pid(Kp,Ki,Kd,Tf);
        % creates a PID controller in parallel form.
        Tf
    end
    
    % TYPE MANAGEMENT IN BINARY OPERATIONS
    methods (Static, Hidden)
        
        function T = inferiorTypes()
            T = {'pidstd'};
        end
        
        function boo = isCombinable(op)
            boo = strcmp(op,'stack');
        end
        
        function boo = isSystem()
            boo = true;
        end
        
        function boo = isFRD()
            boo = false;
        end
        
        function boo = isStructured()
            boo = false;
        end
        
        function boo = isGeneric()
            boo = true;
        end
        
        function T = toFRD()
            T = 'frd';
        end
        
        function T = toStructured(uflag)
            if uflag
                T = 'uss';
            else
                T = 'genss';
            end
        end
        
        function T = toCombinable()
            T = 'tf';
        end
        
    end
    
    % Public methods
    methods
        
        function sys = pid(varargin)
            
            ni = nargin;
            
            % Handle conversion PID(SYS) where SYS is a @pid or ltiblock.pid object
            if ni>0 && (isa(varargin{1},'pid') || isa(varargin{1},'ltiblock.pid'))
               sys0 = varargin{1};
               if ni==1 && isa(sys0,'pid')  % Optimization for SYS of class @pid
                  sys = sys0;
               else
                  try
                     Options = ltipack.AbstractPID.getConversionOptions(varargin(2:end),'pid');
                     sys = copyMetaData(sys0,pid_(sys0,Options));
                  catch ME
                     throw(ME)
                  end
               end
               return
            end
            
            % Dissect input list
            DataInputs = 0;
            PVStart = ni+1;
            for ct=1:ni
                nextarg = varargin{ct};
                if ischar(nextarg)
                    PVStart = ct;
                    break
                else
                    DataInputs = DataInputs+1;
                end
            end
            
            % Handle bad calls
            if PVStart==1
                % only ni == 0 is allowed
                if ni==1
                    % Bad conversion
                    ctrlMsgUtils.error('Control:ltiobject:construct3','pid')
                elseif ni>0
                    % not allowed
                    ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','pid','pid')
                end
            elseif DataInputs>5
                ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','pid','pid')
            end
            
            % Process parameters Kp, Ki, Kd, Tf and sample time Ts.  If any
            % PID parameters is omitted or empty, default value is used.
            try
                Params = {1 0 0 0};  % defaults
                Params(1:DataInputs) = varargin(1:DataInputs);
                Kp = checkParameterData(sys,'Kp',Params{1});
                Ki = checkParameterData(sys,'Ki',Params{2});
                Kd = checkParameterData(sys,'Kd',Params{3});
                Tf = checkParameterData(sys,'Tf',Params{4});
                % Sample time
                if DataInputs==5
                    Ts = ltipack.utValidateTs(varargin{5});
                else
                    Ts = 0;
                end
            catch ME
                throw(ME)
            end
            
            % Determine I/O and array size
            if ni>0
                ArraySize = ltipack.getLTIArraySize(0,Kp,Ki,Kd,Tf);
                if isempty(ArraySize)
                    ctrlMsgUtils.error('Control:ltiobject:pid1')
                end
            else
                ArraySize = [1 1];
            end
            Nsys = prod(ArraySize);
            sys.IOSize_ = [1 1];
            
            % Create @piddataP object array
            % RE: Inlined for optimal speed
            if Nsys==1
                Data = ltipack.piddataP(Kp,Ki,Kd,Tf,Ts);
            else
                Data = ltipack.piddataP.array(ArraySize);
                Delay = ltipack.utDelayStruct(1,1,false);
                for ct=1:Nsys
                    Data(ct).Kp = Kp(min(ct,end));
                    Data(ct).Ki = Ki(min(ct,end));
                    Data(ct).Kd = Kd(min(ct,end));
                    Data(ct).Tf = Tf(min(ct,end));
                    Data(ct).Ts = Ts;
                    Data(ct).Delay = Delay;
                end
            end
            sys.Data_ = Data;
            
            % Process additional settings and validate system
            % Note: Skip when just constructing empty instance for efficiency
            if ni>0
                try
                    % User-defined properties
                    Settings = varargin(:,PVStart:ni);
                    
                    % Apply settings
                    if ~isempty(Settings)
                        sys = fastSet(sys,Settings{:});
                    end
                    % Consistency check: parameters
                    sys = checkConsistency(sys);
                    
                catch ME
                    throw(ME)
                end
            end
        end
        
        %% get methods
        function Value = get.Kp(sys)
            % GET method for Kp
            Value = getParameter(sys,'Kp');
        end
        
        function Value = get.Ki(sys)
            % GET method for Ki
            Value = getParameter(sys,'Ki');
        end
        
        function Value = get.Kd(sys)
            % GET method for Kd
            Value = getParameter(sys,'Kd');
        end
        
        function Value = get.Tf(sys)
            % GET method for Tf
            Value = getParameter(sys,'Tf');
        end
        
        %% set methods
        function sys = set.Kp(sys,Value)
            % SET method for Kp
            sys = setParameter(sys,'Kp',Value);
        end
        
        function sys = set.Ki(sys,Value)
            % SET method for Ki
            sys = setParameter(sys,'Ki',Value);
        end
        
        function sys = set.Kd(sys,Value)
            % SET method for Kd
            sys = setParameter(sys,'Kd',Value);
        end
        
        function sys = set.Tf(sys,Value)
            % SET method for Tf
            sys = setParameter(sys,'Tf',Value);
        end
        
    end
    
    %% DATA ABSTRACTION INTERFACE
    methods (Access=protected)
        
        %% BINARY OPERATIONS
        function sys = addNumeric(sys,A)
            % Special handling of PID + scalar
            Data = sys.Data_;
            if isscalar(A) || isequal(size(A),[1 1 size(Data)])
                for ct=1:numel(Data)
                    Data(ct).Kp = Data(ct).Kp + A(min(ct,end));
                end
                sys.Data_ = Data;
            else
                ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
            end
        end
        
        function sys = rightMultiplyByNumeric(sys,A)
            % Special handling of PID * scalar
            sys = localScalarMult(sys,A);
        end
        
        function sys = leftMultiplyByNumeric(sys,A)
            % Special handling of PID * scalar
            sys = localScalarMult(sys,A);
        end
        
        %% INDEXING
        function sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask)
            % Data management in SYS(indices) = RHS.
            % ioSize is the new I/O size and ArrayMask tracks which
            % entries in the resulting system array have been reassigned.
            
            % Construct template initial value for new entries in system array
            D0 = ltipack.piddataP(0,inf,0,inf,getTs_(sys));
            % Update data
            sys.Data_ = indexasgn(sys.Data_,indices,rhs.Data_,ioSize,ArrayMask,D0);
        end
        
    end
        
    %% PROTECTED METHODS
    methods (Access=protected)

        function value = checkParameterData(~, type, value)
            % Checks parameter is properly formatted
            if isempty(value)
                value = ones(size(value));
            else
                if isnumeric(value) && isreal(value) && all(isfinite(value(:)))
                    value = double(full(value));
                    if strcmp(type,'Tf') && any(value(:)<0)
                        ctrlMsgUtils.error('Control:ltiobject:pidSet2','Tf');
                    end
                else
                    ctrlMsgUtils.error('Control:ltiobject:pidSet1',type);
                end
            end
        end
        
    end
    
    %% STATIC METHODS
    methods(Static, Hidden)
        
        function sys = make(D,~)
            % Constructs PID model from ltipack.piddataP instance
            sys = pid;
            sys.Data_ = D;
        end
        
    end
    
end

%-----------------------------------------------------------------------

function sys = localScalarMult(sys,A)
% Multiplies PID for a numeric array A
Data = sys.Data_;
if isscalar(A) || isequal(size(A),[1 1 size(Data)])
    for ct=1:numel(Data)
        alpha = A(min(ct,end));
        Data(ct).Kp = alpha * Data(ct).Kp;
        Data(ct).Ki = alpha * Data(ct).Ki;
        Data(ct).Kd = alpha * Data(ct).Kd;
    end
    sys.Data_ = Data;
else
    ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
end
end
