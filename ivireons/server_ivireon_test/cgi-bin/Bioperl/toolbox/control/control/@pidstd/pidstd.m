classdef pidstd < ltipack.AbstractPID
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
    
    %   Author(s): R. Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %   $Revision: 1.1.8.6.2.1 $  $Date: 2010/06/24 19:32:24 $
    
    % Public properties with restricted values
    properties (Access = public, Dependent)
        % Proportional gain
        %
        % The "Kp" property stores the proportional gain of a PID
        % controller. Kp must be real and finite. For an array of PIDSTD
        % objects, Kp has the same size as the array size. For example,
        %   Kp = 1;
        %   Ti = 2;
        %   Td = 3;
        %   N = 4;
        %   C = pidstd(Kp,Ti,Td,N);
        % creates a PID controller in standard form.
        Kp
        % Integral time
        %
        % The "Ti" property stores the integral time of a PID controller.
        % Ti must be real and greater than 0. For an array of PID objects,
        % Ti has the same size as the array size. For example,
        %   Kp = 1;
        %   Ti = 2;
        %   Td = 3;
        %   N = 4;
        %   C = pidstd(Kp,Ti,Td,N);
        % creates a PID controller in standard form.
        Ti
        % Derivative time
        %
        % The "Td" property stores the derivative time of a PID controller.
        % Td must be real, finite, greater than or equal to 0. For an array
        % of PID objects, td has the same size as the array size. For
        % example,
        %   Kp = 1;
        %   Ti = 2;
        %   Td = 3;
        %   N = 4;
        %   C = pidstd(Kp,Ti,Td,N);
        % creates a PID controller in standard form.
        Td
        % Derivative filter divisor
        %
        % The "N" property stores the derivative filter divisor of a PID
        % controller. N must be real and greater than 0. For an array of
        % PID objects, N has the same size as the array size. For example,
        %   Kp = 1;
        %   Ti = 2;
        %   Td = 3;
        %   N = 4;
        %   C = pidstd(Kp,Ti,Td,N);
        % creates a PID controller in standard form.
        N
    end
    
    % TYPE MANAGEMENT IN BINARY OPERATIONS
    methods (Static, Hidden)
        
        function T = inferiorTypes()
            T = cell(1,0);
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
        
        function sys = pidstd(varargin)
            
            ni = nargin;
            
            % Handle conversion PIDSTD(SYS) where SYS is also a PIDSTD object
            if ni>0 && isa(varargin{1},'pidstd')
                sys0 = varargin{1};
                if ni==1
                    sys = sys0; % Optimization for SYS of class @pidstd
                else
                    % convert with options.  For example, from one formula to another formula
                    try
                       Options = ltipack.AbstractPID.getConversionOptions(varargin(2:end),'pidstd');
                       sys = copyMetaData(sys0,pidstd_(sys0,Options));
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
                % only ni==0 is allowed
                if ni==1
                    % Bad conversion
                    ctrlMsgUtils.error('Control:ltiobject:construct3','pidstd')
                elseif ni>0
                    % not allowed
                    ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','pidstd','pidstd')
                end
            elseif DataInputs>5
                ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','pidstd','pidstd')
            end
            
            % Process parameters Kp, Ti, Td, N and sample time Ts.  If any
            % PIDSTD parameters is omitted or empty, default value is used.
            try
                Params = {1 inf 0 inf};  % defaults
                Params(1:DataInputs) = varargin(1:DataInputs);
                Kp = checkParameterData(sys,'Kp',Params{1});
                Ti = checkParameterData(sys,'Ti',Params{2});
                Td = checkParameterData(sys,'Td',Params{3});
                N = checkParameterData(sys,'N',Params{4});
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
                ArraySize = ltipack.getLTIArraySize(0,Kp,Ti,Td,N);
                if isempty(ArraySize)
                    ctrlMsgUtils.error('Control:ltiobject:pids1')
                end
            else
                ArraySize = [1 1];
            end
            Nsys = prod(ArraySize);
            sys.IOSize_ = [1 1];
            
            % Create @piddataS object array
            % RE: Inlined for optimal speed
            if Nsys==1
                Data = ltipack.piddataS(Kp,Ti,Td,N,Ts);
            else
                Data = ltipack.piddataS.array(ArraySize);
                Delay = ltipack.utDelayStruct(1,1,false);
                for ct=1:Nsys
                    Data(ct).Kp = Kp(min(ct,end));
                    Data(ct).Ti = Ti(min(ct,end));
                    Data(ct).Td = Td(min(ct,end));
                    Data(ct).N = N(min(ct,end));
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
        
        function Value = get.Ti(sys)
            % GET method for Ti
            Value = getParameter(sys,'Ti');
        end
        
        function Value = get.Td(sys)
            % GET method for Td
            Value = getParameter(sys,'Td');
        end
        
        function Value = get.N(sys)
            % GET method for N
            Value = getParameter(sys,'N');
        end
        
        %% set methods
        function sys = set.Kp(sys,Value)
            % SET method for Kp
            sys = setParameter(sys,'Kp',Value);
        end
        
        function sys = set.Ti(sys,Value)
            % SET method for Ti
            sys = setParameter(sys,'Ti',Value);
        end
        
        function sys = set.Td(sys,Value)
            % SET method for Td
            sys = setParameter(sys,'Td',Value);
        end
        
        function sys = set.N(sys,Value)
            % SET method for N
            sys = setParameter(sys,'N',Value);
        end
        
    end
    
    %% DATA ABSTRACTION INTERFACE
    methods (Access=protected)
        
        %% BINARY OPERATIONS
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
            D0 = ltipack.piddataS(0,inf,0,inf,getTs_(sys));
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
                switch type
                    case 'Kp'
                        if ~isempty(value) && isnumeric(value) && isreal(value) && all(isfinite(value(:)))
                            value = double(full(value));
                        else
                            ctrlMsgUtils.error('Control:ltiobject:pidSet1',type);
                        end
                    case 'Td'
                        if ~isempty(value) && isnumeric(value) && isreal(value) && all(isfinite(value(:)))
                            value = double(full(value));
                            if any(value(:)<0)
                                ctrlMsgUtils.error('Control:ltiobject:pidSet2','Td');
                            end
                        else
                            ctrlMsgUtils.error('Control:ltiobject:pidSet1',type);
                        end
                    otherwise
                        if ~isempty(value) && isnumeric(value) && isreal(value) && all(value(:)>0)
                            value = double(full(value));
                        else
                            ctrlMsgUtils.error('Control:ltiobject:pidSet3',type);
                        end
                end
            end
        end
        
    end
    
    %% STATIC METHODS
    methods(Static, Hidden)
        
        function sys = make(D,~)
            % Constructs PIDSTD model from ltipack.piddataS instance
            sys = pidstd;
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
        Data(ct).Kp = A(min(ct,end)) * Data(ct).Kp;
    end
    sys.Data_ = Data;
else
    ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
end
end