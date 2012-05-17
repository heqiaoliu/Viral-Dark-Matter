classdef tf < lti
   %TF  Constructs transfer function or converts to transfer function.
   %
   %  Construction:
   %    SYS = TF(NUM,DEN) creates a continuous-time transfer function SYS with
   %    numerator NUM and denominator DEN. SYS is an object of class @tf.
   %
   %    SYS = TF(NUM,DEN,TS) creates a discrete-time transfer function with
   %    sampling time TS (set TS=-1 if the sampling time is undetermined).
   %
   %    S = TF('s') specifies the transfer function H(s) = s (Laplace variable).
   %    Z = TF('z',TS) specifies H(z) = z with sample time TS.
   %    You can then specify transfer functions directly as expressions in S
   %    or Z, for example,
   %       s = tf('s');  H = exp(-s)*(s+1)/(s^2+3*s+1)
   %
   %    SYS = TF creates an empty TF object.
   %    SYS = TF(M) specifies a static gain matrix M.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = tf(1,[1 2 5],0.1,'Variable','q','ioDelay',3)
   %    also sets the variable and transport delay. Type "properties(tf)" 
   %    for a complete list of model properties, and type 
   %       help tf.<PropertyName>
   %    for help on a particular property. For example, "help tf.Variable" 
   %    provides information about the "Variable" property.
   %
   %    By default, transfer functions are displayed as functions of 's' or 
   %    'z'. Alternatively, you can use the variable 'p' in continuous time 
   %    and the variables 'z^-1' or 'q' in discrete time by modifying the  
   %    "Variable" property.
   %
   %  Data format:
   %    For SISO models, NUM and DEN are row vectors listing the numerator 
   %    and denominator coefficients in descending powers of s,p,z,q or in
   %    ascending powers of z^-1 (DSP convention). For example, 
   %       sys = tf([1 2],[1 0 10])
   %    specifies the transfer function (s+2)/(s^2+10) while 
   %       sys = tf([1 2],[1 5 10],0.1,'Variable','z^-1')
   %    specifies (1 + 2 z^-1)/(1 + 5 z^-1 + 10 z^-2).
   %
   %    For MIMO models with NY outputs and NU inputs, NUM and DEN are 
   %    NY-by-NU cell arrays of row vectors where NUM{i,j} and DEN{i,j} 
   %    specify the transfer function from input j to output i. For example,
   %       H = tf( {-5 ; [1 -5 6]} , {[1 -1] ; [1 1 0]})
   %    specifies the two-output, one-input transfer function
   %       [     -5 /(s-1)      ]
   %       [ (s^2-5s+6)/(s^2+s) ]
   %
   %  Arrays of transfer functions:
   %    You can create arrays of transfer functions by using ND cell arrays 
   %    for NUM and DEN above. For example, if NUM and DEN are cell arrays 
   %    of size [NY NU 3 4], then
   %       SYS = TF(NUM,DEN)
   %    creates the 3-by-4 array of transfer functions
   %       SYS(:,:,k,m) = TF(NUM(:,:,k,m),DEN(:,:,k,m)),  k=1:3,  m=1:4.
   %    Each of these transfer functions has NY outputs and NU inputs.
   %
   %    To pre-allocate an array of zero transfer functions with NY outputs
   %    and NU inputs, use the syntax
   %       SYS = TF(ZEROS([NY NU k1 k2...])) .
   %
   %  Conversion:
   %    SYS = TF(SYS) converts any dynamic system SYS to the transfer
   %    function representation. The resulting SYS is of class @tf.
   %
   %  See also TF/EXP, FILT, TFDATA, ZPK, SS, FRD, DYNAMICSYSTEM.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.21.4.13 $  $Date: 2010/04/30 00:36:17 $
   
   % Add static method to be included for compiler
   %#function ltipack.utValidateTs
   %#function tf.loadobj
   %#function tf.make

   % Public properties with restricted value
   properties (Access = public, Dependent)
      % Numerator coefficients (cell array of row vectors).
      %
      % The "num" property stores the transfer function numerator(s). For 
      % SISO transfer functions, set "num" to the row vector of numerator 
      % coefficients. For all variables but 'z^-1', the vector [1 2 3] is 
      % interpreted as the polynomial s^2+2s+3. For Variable='z^-1', [1 2 3] 
      % is interpreted as the polynomial 1 + 2 z^-1 + 3 z^-2.
      %
      % For MIMO transfer functions with Ny outputs and Nu inputs, set "num" 
      % to the Ny-by-Nu cell array of numerator coefficients for each I/O
      % pair. For example, 
      %    num = {[1 0] , 1     ; 3 , [1 2 3]}
      %    den = {[1 2] , [1 1] ; 1 , [5 2]  }
      %    H = tf(num,den)
      % specifies the two-input, two-output transfer function:
      %    [ s/(s+2)            1/(s+1)  ]
      %    [ 3/1       (s^2+2s+3)/(5s+2) ]
      num
      % Denominator coefficients (cell array of row vectors).
      %
      % Counterpart of "num" for the denominator coefficients, type
      % "help tf.num" for details.
      den
      % Transfer function variable (string, default = 's' or 'z').
      %
      % You can set this property to either 's' or 'p' in continuous time,
      % and to 'z', 'q', or 'z^-1' in discrete time. Note that s and p are
      % equivalent and so are z and q.
      % 
      % The "Variable" setting is reflected in the display and also affects
      % the discrete-time interpretation of the num,den vectors. For 
      % Variable='z' or 'q', the vector [1 2 3] is interpreted as z^2+2z+3 
      % (descending powers of z). For Variable='z^-1', however, [1 2 3] is 
      % interpreted as 1 + 2 z^-1 + 3 z^-2 (ascending powers of z^-1).
      Variable
      % Transport delays (numeric array, default = all zeros).
      %
      % The "ioDelay" property specifies a separate time delay for each 
      % I/O pair. For continuous-time systems, specify I/O delays in
      % the time unit stored in the "TimeUnit" property. For discrete-
      % time systems, specify I/O delays as integer multiples of the
      % sampling period "Ts", for example, ioDelay=2 to mean a delay
      % of two sampling periods.
      %
      % For MIMO transfer functions with Ny outputs and Nu inputs, set 
      % "ioDelay" to a Ny-by-Nu matrix. You can also set this property to 
      % a scalar value to apply the same delay to all I/O pairs.
      %
      % Example: sys.ioDelay = [0 , 1.2 ; 0.5 , 0] specifies nonzero
      % transport delays from input 1 to output 2 and from input 2 to
      % output 1.
      ioDelay
   end

   properties (Access = protected)
      % Storage for Variable property
      Variable_  % type = string
   end
   
   % OBSOLETE PROPERTIES
   properties (Access = public, Dependent, Hidden)
      % Obsolete property, shortened to ioDelay.
      ioDelayMatrix
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = {'pidstd','pid'};
      end
      
      function boo = isCombinable(~)
         boo = true;
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
      
   end
   
   
   methods
      
      function sys = tf(varargin)
         ni = nargin;
         % Handle conversion TF(SYS) where SYS is a TF or LTIBLOCK.TF object
         if ni>0 && (isa(varargin{1},'tf') || isa(varargin{1},'ltiblock.tf'))
            sys0 = varargin{1};
            if isa(sys0,'tf')  % Optimization for SYS of class @tf
               sys = sys0;
            else
               sys = copyMetaData(sys0,tf_(sys0));
            end
            return
         end
                  
         % Trap the syntax TF('s',...) or TF('z',Ts,...)
         % RE: Do not support x=TF('z^-1') because we can't make (1/z)+(1/z)^2 minimal
         if ni>0 && ischar(varargin{1}) && any(strcmp(varargin{1},{'s' 'p' 'z' 'q'})),
            var = varargin{1};
            if ni>1 && isnumeric(varargin{2})
               Ts = varargin{2};   varargin = varargin(3:end);
               if xor(Ts==0,any(var=='sp'))
                  ctrlMsgUtils.error('Control:ltiobject:setVariableProperty')
               end
            else
               Ts = -double(any(var=='zq'));   varargin = varargin(2:end);
            end
            if any(var=='pq')
               varargin = [{'Variable' var} varargin];
            end
            ni = 3+length(varargin);
            varargin = [{[1 0] [0 1] Ts} varargin];
         end
          
         % Dissect input list
         DataInputs = 0;
         LtiInput = 0;
         PVStart = ni+1;
         for ct=1:ni
            nextarg = varargin{ct};
            if isa(nextarg,'struct') || isa(nextarg,'lti')
               LtiInput = ct;   PVStart = ct+1;   break
            elseif ischar(nextarg)
               PVStart = ct;   break
            else
               DataInputs = DataInputs+1;
            end
         end
         
         % Handle bad calls
         if PVStart==1,
            if ni==1,
               % Bad conversion
               ctrlMsgUtils.error('Control:ltiobject:construct3','tf')
            elseif ni>0
               ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','tf','tf')
            end
         elseif DataInputs>3
            ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','tf','tf')
         end
         
         % Process numerical data
         try
            switch DataInputs,
               case 0
                  if ni,
                     ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','tf','tf')
                  else
                     num = {};  den = {};
                  end
                  
               case 1
                  % Gain matrix
                  nummat = varargin{1};
                  if ~isnumeric(nummat),
                     ctrlMsgUtils.error('Control:ltiobject:construct2','tf')
                  end
                  if isempty(nummat),
                     num = cell(size(nummat));
                  else
                     num = num2cell(double(full(nummat)));
                  end
                  den = cell(size(nummat));
                  den(:) = {1};
                  
               otherwise
                  % NUM and DEN specified
                  num = checkNumDenData(varargin{1},'N');
                  den = checkNumDenData(varargin{2},'D');
            end
            
            % Sample time
            if DataInputs==3
               % Discrete SS
               Ts = ltipack.utValidateTs(varargin{3});
            else
               Ts = 0;
            end
         catch ME
            throw(ME)
         end
            
         % Determine I/O and array size
         if ni>0
            Ny = size(num,1);
            Nu = size(num,2);
            ArraySize = ltipack.getLTIArraySize(2,num,den);
            if isempty(ArraySize)
               ctrlMsgUtils.error('Control:ltiobject:tf1')
            end
         else
            Ny = 0;  Nu = 0;  ArraySize = [1 1];
         end
         Nsys = prod(ArraySize);
         sys.IOSize_ = [Ny Nu];
            
         % Create @tfdata object array
         % RE: Inlined for optimal speed
         if Nsys==1
            Data = ltipack.tfdata(num,den,Ts);
         else
            Data = ltipack.tfdata.array(ArraySize);
            Delay = ltipack.utDelayStruct(Ny,Nu,false);
            for ct=1:Nsys
               Data(ct).num = num(:,:,min(ct,end));
               Data(ct).den = den(:,:,min(ct,end));
               Data(ct).Ts = Ts;
               Data(ct).Delay = Delay;
            end
         end
         sys.Data_ = Data;
         
         % Process additional settings and validate system
         % Note: Skip when just constructing empty instance for efficiency
         if ni>0
            try
               Settings = cell(1,0);
               
               % Properties inherited from other system
               if LtiInput,
                  arg = varargin{LtiInput};
                  if isa(arg,'lti')
                     arg = getSettings(arg);
                  end
                  Settings = [Settings , lti.struct2pv(arg)];
               end
               
               % User-defined properties
               Settings = [Settings , varargin(:,PVStart:ni)];
               
               % Apply settings
               if ~isempty(Settings)
                  sys = fastSet(sys,Settings{:});
               end
               
               % Consistency check
               sys = checkConsistency(sys);
               
               % Issue warning if system is complex
               if ~isreal(sys)
                  ctrlMsgUtils.warning('Control:ltiobject:TFComplex')
               end
            catch ME
               throw(ME)
            end
         end
      end
      
      function Value = get.num(sys)
         % GET method for num property
         Data = sys.Data_;
         Value = cell([sys.IOSize_ size(Data)]);
         for ct=1:numel(Data)
            Value(:,:,ct) = Data(ct).num;
         end
      end
      
      function Value = get.den(sys)
         % GET method for den property
         Data = sys.Data_;
         Value = cell([sys.IOSize_ size(Data)]);
         for ct=1:numel(Data)
            Value(:,:,ct) = Data(ct).den;
         end
      end
      
      function sys = set.num(sys,Value)
         % SET method for num property
         Value = checkNumDenData(Value,'N');
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         sv = size(Value);
         if isequal(sv(1:2),sys.IOSize_)
            % No change in I/O size
            for ct=1:numel(Data)
               Data(ct).num = Value(:,:,min(ct,end));
               if sys.CrossValidation_
                  Data(ct) = checkData(Data(ct));  % Quick validation
               end
            end
            sys.Data_ = Data;
            if sys.CrossValidation_
               sys = padNumDen(sys);
            end
         else
            % I/O size changes
            for ct=1:numel(Data)
               Data(ct).num = Value(:,:,min(ct,end));
            end
            sys.Data_ = Data;
            if sys.CrossValidation_
               % Note: Full validation needed when I/O size changes, e.g., in
               % sys = tf(1,[1 2 3]); sys.num = {1 2;3 4};
               sys = checkConsistency(sys);
            end
         end
      end
      
      function sys = set.den(sys,Value)
         % SET method for den property
         % Note: Limited checking because setting DEN only cannot change I/O size
         Value = checkNumDenData(Value,'D');
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            Data(ct).den = Value(:,:,min(ct,end));
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));
            end
         end
         sys.Data_ = Data;
         if sys.CrossValidation_
            sys = padNumDen(sys);
         end
      end
      
      function Value = get.Variable(sys)
         % GET method for Variable property
         Value = sys.Variable_;
         if isempty(Value)
            if getTs_(sys)==0
               Value = 's';
            else
               Value = 'z';
            end
         end
      end
      
      function sys = set.Variable(sys,Value)
         % SET method for Variable property
         if ~(isa(Value,'char') && any(strcmp(Value,{'s';'p';'z';'z^-1';'q'})))
            ctrlMsgUtils.error('Control:ltiobject:setVariableProperty')
         elseif sys.CrossValidation_
            % Check consistency with Ts
            Value = ltipack.checkVariable(sys,Value);
         end
         sys.Variable_ = Value;
         % Drop trailing zeros when switching to z^-1, e.g., in tf([1 2 0],[1 0 0])
         if sys.CrossValidation_ && strcmp(Value,'z^-1')
            sys = padNumDen(sys);
         end
      end
      
      function Value = get.ioDelay(sys)
         % GET method for ioDelay property
         Value = getIODelay(sys);
      end
      
      function Value = get.ioDelayMatrix(sys)
         Value = getIODelay(sys);
      end
      
      function sys = set.ioDelay(sys,Value)
         % SET method for ioDelay property
         sys = setIODelay(sys,Value);
      end
      
      function sys = set.ioDelayMatrix(sys,Value)
         % SET method for ioDelayMatrix property
         sys = setIODelay(sys,Value);
      end
      
   end
   
   %% ABSTRACT SUPERCLASS INTERFACES
   methods (Access=protected)

      function displaySize(~,sizes)
         % Displays SIZE information in SIZE(SYS)
         ny = sizes(1);
         nu = sizes(2);
         if length(sizes)==2,
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeTF1',ny,nu))
         else
            ArrayDims = sprintf('%dx',sizes(3:end));
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeTF2',ArrayDims(1:end-1),ny,nu))
         end
      end
      
      function sys = setTs_(sys,Ts)
         % Implementation of @SingleRateSystem:setTs_
         sys = setTs_@lti(sys,Ts);
         % Check Ts/Variable compatibility
         if sys.CrossValidation_
            sys.Variable_ = ltipack.checkVariable(sys,sys.Variable_);
         end
      end
      
   end
   
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% MODEL CHARACTERISTICS
      function sys = checkDataConsistency(sys)
         % Cross validation of system data. Extends @lti implementation
         % Generic data validation
         sys = checkDataConsistency@lti(sys);
         
         % Check Variable/Ts compatibility
         sys.Variable_ = ltipack.checkVariable(sys,sys.Variable_);
            
         % Pad NUM and DEN with zeros based on variable in use
         sys = padNumDen(sys);
      end

      %% BINARY OPERATIONS
      function boo = hasSimpleInverse_(sys)
         boo = all(iosize(sys)==1);
      end
      
      function [sys1,sys2] = matchAttributes(sys1,sys2)
         % Enforces matching attributes in binary operations (e.g.,
         % sampling time, variable,...). This function can be overloaded
         % by subclasses.
         [sys1,sys2] = matchAttributes@lti(sys1,sys2);
         % Match Variables
         [sys1,sys2] = ltipack.matchVariable(sys1,sys2);
      end      

      %% INDEXING
      function sys = indexref_(sys,indrow,indcol,ArrayIndices)
         % Implements sys(indices)
         sys = indexref_@ltipack.SystemArray(sys,indrow,indcol,ArrayIndices);
         % g400213: reset variable if resulting TF array is empty
         if isempty(sys.Data_)
            sys.Variable_ = [];
         end
      end
            
      function sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask)
         % Data management in SYS(indices) = RHS.
         % ioSize is the new I/O size and ArrayMask tracks which
         % entries in the resulting system array have been reassigned.

         % Construct template initial value for new entries in system array
         n = cell(ioSize); n(:) = {0};
         d = cell(ioSize); d(:) = {1};
         D0 = ltipack.tfdata(n,d,getTs_(sys));
         D0.Delay.Input(:) = NaN;
         D0.Delay.Output(:) = NaN;
         % Update data
         sys.Data_ = indexasgn(sys.Data_,indices,rhs.Data_,ioSize,ArrayMask,D0);
         % g400213: reset variable if resulting TF array is empty
         if isempty(sys.Data_)
            sys.Variable_ = [];
         end
      end
      
      function sys = indexdel_(sys,indices)
         % Data management in SYS(indices) = [].
         sys = indexdel_@ltipack.SystemArray(sys,indices);
         if isempty(sys.Data_)
            sys.Variable_ = [];
         end
      end
      
      %% TRANSFORMATIONS
      function [sys,varargout] = c2d_(sys,Ts,options)
         % Data management for C2D
         [sys,varargout{1:nargout-1}] = c2d_@ltipack.SystemArray(sys,Ts,options);
         sys.Variable_ = [];  % reset to default ('z')
      end
      
      function sys = d2c_(sys,options)
         % Data management for D2C
         sys = d2c_@ltipack.SystemArray(sys,options);
         sys.Variable_ = [];  % reset to default ('s')
      end
      
      function sys = balred_(sys,orders,BalData,Options)
         % Specialization to TF models
         % To avoid introducing internal delays in SS realization, cache
         % delays and zero them out before conversion to SS
         [ny,nu] = iosize(sys);
         Delay = sys.Data_.Delay;
         sys.Data_.Delay = ltipack.utDelayStruct(ny,nu,false);
         % Compute reduced model in state space
         rsys = balred_(ss(sys),orders,BalData,Options);
         % Convert back to TF and restore original delays
         rsys = tf(rsys);
         D = rsys.Data_;
         for ct=1:numel(D)
            D(ct).Delay = Delay;
         end
         sys.Data_ = D; % preserves metadata
      end

      
   end
   
   %% PROTECTED METHODS
   methods (Access=protected)
   
      function S = getSettings(sys)
         % Gets values of public LTI properties. Needed to support tf(num,den,LTI)
         S = getSettings@lti(sys);
         S.ioDelay = sys.ioDelay;
      end
        
      function sys = copyVariable(refsys,sys)
         % Copies Variable property from REFSYS to SYS
         if ~strcmp(refsys.Variable,sys.Variable)
            sys.Variable = refsys.Variable;
         end
      end

   end   
   
   %% HIDDEN METHODS
   methods (Hidden)
      
      function TuningData = getPIDTuningData(G,C,~,index)
         %GETPIDTUNINGDATA returns ltipack.PIDTuningData object that
         %implements RRT tuning method.  By overloading this method PID
         %tuning API/GUI tools now supports designing for @tf class.
         % convert from TFdata to ZPKdata
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
   
   %% PRIVATE METHODS
   methods (Access=private)
      
      function sys = padNumDen(sys)
         % Pad NUM and DEN with zeros based on variable in use
         RightPad = strcmp(sys.Variable_,'z^-1');
         qVar = strcmp(sys.Variable_,'q');
         qWarn = false;
         Data = sys.Data_;
         for ct=1:numel(Data)
            [Data(ct),NeedsPad] = utZeroPad(Data(ct),RightPad);
            qWarn = qWarn || (qVar && NeedsPad);  % see below
         end
         sys.Data_ = Data;
         % Starting in R2009a, q means z rather than z^-1
         if qWarn
            ctrlMsgUtils.warning('Control:ltiobject:qChange')
         end
      end
      
   end
   
   %% STATIC METHODS
   methods(Static, Hidden)
      
      sys = loadobj(s)
            
      function sys = make(D,IOSize)
         % Constructs TF model from ltipack.tfdata instance
         sys = tf;
         sys.Data_ = D;
         if nargin>1
            sys.IOSize_ = IOSize;  % support for empty model arrays
         else
            sys.IOSize_ = iosize(D(1));
         end
      end
      
      function sys = cast(Model)
         % Casts static or dynamic model to @tf
         if isnumeric(Model) || isa(Model,'StaticModel')
            % Work around tf(GENMAT) yielding a GENSS
            sys = tf(double(Model));
         elseif isa(Model,'DynamicSystem')
            % DynamicSystem subclass
            sys = tf(Model);
         else
            ctrlMsgUtils.error('Control:transformation:tf4',class(Model))
         end
      end
      
   end
     
end
