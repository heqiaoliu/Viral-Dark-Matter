classdef AbstractPID < lti
    % ABSTRACTPID  parent class for all PID MCOS objects
    %
    
    % Author(s): Rong Chen 19-Nov-2009
    %   Copyright 2009-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.6.2.1 $ $Date: 2010/06/24 19:43:00 $
    
    % Public properties with restricted values
    properties (Access = public, Dependent)
        % Numerical integration formula for the integral action
        %
        % The "IFormula" property stores the numerical integration formula
        % for the integral action of a discrete-time PID controller.
        % IFormula must be one of the following strings: 'ForwardEuler',
        % 'BackwardEuler' and 'Trapezoidal', where
        %
        %    'ForwardEuler':     replace 1/s with Ts/(z-1)
        %    'BackwardEuler':    replace 1/s with Ts*z/(z-1)
        %    'Trapezoidal':      replace 1/s with (Ts/2)*(z+1)/(z-1)
        %
        % The default value is 'ForwardEuler'. For example,
        %   C = pid(1,2,'Ts',0.1,'IFormula','BackwardEuler');
        % creates a discrete-time PID controller in parallel form with the
        % Backward Euler formula for integral action.
        IFormula
        % Numerical integration formula for the derivative action
        %
        % The "DFormula" property stores the numerical integration formula
        % for the derivative action of a discrete-time PID controller.
        % DFormula must be one of the following strings: 'ForwardEuler',
        % 'BackwardEuler' and 'Trapezoidal', where
        %
        %    'ForwardEuler':     replace 1/s with Ts/(z-1)
        %    'BackwardEuler':    replace 1/s with Ts*z/(z-1)
        %    'Trapezoidal':      replace 1/s with (Ts/2)*(z+1)/(z-1)
        %
        % The default value is 'ForwardEuler'. For example,
        %   C = pid(1,2,3,4,'Ts',0.1,'DFormula','Trapezoidal');
        % creates a discrete-time PID controller in parallel form with the
        % Trapezoidal formula for derivative action.
        DFormula
    end
    
    %% Abstract methods
    methods(Access=protected, Abstract)
        checkParameterData(sys,name,newvalue)
    end
    
    
    %% Public methods
    methods
        
        %% Get methods
        function Value = get.IFormula(sys)
            % GET method for IFormula
            Value = getFormula(sys,'IFormula');
        end
        
        function Value = get.DFormula(sys)
            % GET method for DFormula
            Value = getFormula(sys,'DFormula');
        end
        
        %% Set methods
        function sys = set.IFormula(sys,Value)
            % SET method for Form
            sys = setFormula(sys,'IFormula',Value);
            if sys.CrossValidation_
                sys = checkConsistency(sys);
            end
        end
        
        function sys = set.DFormula(sys,Value)
            % SET method for Form
            sys = setFormula(sys,'DFormula',Value);
            if sys.CrossValidation_
                sys = checkConsistency(sys);
            end
        end
        
        %% Other methods
        function Value = getType(sys)
            %GETTYPE  returns the controller type.
            %
            %   TYPE = GETTYPE(SYS) returns the controller type as a string
            %   when SYS is a PID or PIDSTD object. TYPE is one of the
            %   following strings: 'P', 'I' (parallel form only), 'PI',
            %   'PD', 'PDF', 'PID', 'PIDF' where 'F' indicates a 1st order
            %   filter on the derivative action. If SYS is an array of
            %   PID controllers, TYPE is a cell array of the same size.
            Data = sys.Data_;
            if isscalar(Data)
                Value = Data.getType;
            else
                Value = cell(size(Data));
                for ct=1:numel(Data)
                    Value{ct} = Data(ct).getType;
                end
            end
        end
        
    end
    
    %% ABSTRACT SUPERCLASS INTERFACES
    methods (Access=protected)
        
        function displaySize(~,sizes)
            % Displays SIZE information in SIZE(SYS)
            if length(sizes)==2
                disp(ctrlMsgUtils.message('Control:ltiobject:pidSize1',1,1))
            else
                ArrayDims = sprintf('%dx',sizes(3:end));
                disp(ctrlMsgUtils.message('Control:ltiobject:pidSize2',ArrayDims(1:end-1),1,1))
            end
        end
        
        function sys = setTs_(sys,Ts)
            % Implementation of @SingleRateSystem:setTs_
            if Ts==-1
                ctrlMsgUtils.warning('Control:ltiobject:pidAmbiguousRate1')
            end
            sys = setTs_@lti(sys,abs(Ts));
            if Ts==0
                % make sure IFormula and Dformula is 'F' when Ts is 0
                Data = sys.Data_;
                for ct=1:numel(Data)
                    Data(ct).IFormula = 'F';
                    Data(ct).DFormula = 'F';
                end
                sys.Data_ = Data;
            end
        end
        
    end
    
    %% DATA ABSTRACTION INTERFACE
    methods (Access=protected)
        
        %% MODEL CHARACTERISTICS
        function sys = checkDataConsistency(sys)
            % No need for a checkData method for @piddata* because there is
            % no size compatibility issue (the parameter values should
            % always be scalar). [] values is handled in setParameter
            % Sampling time restriction
            if getTs_(sys)==-1
                % Ts=-1 is ambiguous for PID systems and may lead to
                % inconsistencies, e.g., if sys1.Ts=-1 and sys2.Ts=.1,
                % pid(sys1)+pid(sys2) and pid(sys1+sys2) differ
                % because the response in pid(sys1) is effectively
                % evaluated for Ts=1. Similar problems arise when
                % absorbing delays with Ts=-1. Force Ts=1 and warn.
                ctrlMsgUtils.warning('Control:ltiobject:pidAmbiguousRate1')
                sys = setTs_(sys,1);
            end
            if getTs_(sys)==0
                % make sure IFormula and Dformula is 'F' when Ts is 0
                Data = sys.Data_;
                for ct=1:numel(Data)
                    Data(ct).IFormula = 'F';
                    Data(ct).DFormula = 'F';
                end
                sys.Data_ = Data;
            end
        end
        
        %% BINARY OPERATIONS
        function boo = hasSimpleInverse_(~)
            boo = true;
        end
        
        %% TRANSFORMATIONS
        function sys = conj_(sys)
            % Forms model with complex conjugate coefficients (null operation for PID).
        end
        
        function sys = transpose_(sys)
            % Transposition (null operation for PID).
        end
        
        function sys = inv_(sys)
            % Convert to TF before evaluating
            sys = inv_(tf(sys));
        end
        
        function sys = mpower_(sys,k)
            % Convert to TF before evaluating
            sys = mpower_(tf(sys),k);
        end
        
        function sys = minreal_(sys,~,~)
            % Pole/zero cancellations (null operation for PID).
        end
        
        function sys = pade_(sys,varargin)
            % Pade approximation (null operation for PID).
        end
        
    end
    
    
    
    %% PROTECTED METHODS
    methods (Access=protected)
        
        function boo = hasFixedDelay(~)
            % Subclasses can override sys method to make delays read-only
            % and fix their value to zero (see @pid)
            boo = true;
        end
        
        
        %% PID specific methods
        function Value = getParameter(sys,name)
            % helper function for get tuning parameters
            Data = sys.Data_;
            if isscalar(Data)
                Value = Data.(name);
            else
                Value = zeros(size(Data));
                for ct=1:numel(Data)
                    Value(ct) = Data(ct).(name);
                end
            end
        end
        
        function Value = getFormula(sys,name)
            % helper function for get properties Formula (homogeneous)
            Data = sys.Data_;
            if isempty(Data)
                Value = '';
            else
                Value = ltipack.getPIDFormula(Data(1).(name),Data(1).Ts);
            end
        end
        
        function sys = setParameter(sys,name,newvalue)
            % helper function for set parameters
            Value = checkParameterData(sys,name,newvalue);
            % Check compatibility of RHS with model array sizes
            Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,0);
            for ct=1:numel(Data)
                Data(ct).(name) = Value(min(ct,end));
            end
            sys.Data_ = Data;
        end
        
        function sys = setFormula(sys,name,Value)
            % helper function for set properties Formulas
            Value = ltipack.setPIDFormula(Value);
            % Check compatibility of RHS with model array sizes
            Data = sys.Data_;
            for ct=1:numel(Data)
                Data(ct).(name) = Value;
            end
            sys.Data_ = Data;
        end
        
    end
    
    
    %% HIDDEN METHODS
    methods (Hidden)
        
        function TuningData = getPIDTuningData(G,C,~,index)
            % GETPIDTUNINGDATA returns ltipack.PIDTuningData object that
            % implements RRT tuning method. By overloading this method PID
            % tuning API/GUI tools now supports designing for @pid/@pidstd
            % class.
            % convert from piddataP or piddataS to ZPKdata
            if nargin<=3
                Gdata = zpk(G.Data_);
            else
                Gdata = zpk(G.Data_(index));
            end
            if ischar(C)
                C = ltipack.getPIDfromType(C,getTs(G));
            end
            % obtain PIDTuningData
            TuningData = ltipack.PIDTuningData(Gdata,C);
        end
        
    end
    
    %% STATIC METHODS
    methods (Static, Hidden)
       
       function Options = getConversionOptions(PVPairs,Command)
          % Reads PV pairs in PID/PIDSTD conversion methods.
          Options = struct('IFormula',[],'DFormula',[]);
          ni = numel(PVPairs);
          if ni>0
             % Check formatting of name/value pair list
             ltioptions.checkNameValuePairs(PVPairs);
             for i=1:2:ni
                Name = ltipack.matchKey(PVPairs{i},{'IFormula','DFormula'});
                if isempty(Name)
                   ctrlMsgUtils.error('Control:ltiobject:pidOptionError',PVPairs{i},Command);
                end
                Value = ltipack.matchKey(PVPairs{i+1},{'ForwardEuler','BackwardEuler','Trapezoidal'});
                if isempty(Value)
                   ctrlMsgUtils.error('Control:ltiobject:pidInvalidFormula');
                end
                Options.(Name) = Value(1);
             end
          end
       end
       
    end
    
end

