classdef zpk < lti
   %ZPK  Constructs zero-pole-gain model or converts to zero-pole-gain format.
   %
   %  Construction:
   %    SYS = ZPK(Z,P,K) creates a continuous-time zero-pole-gain (ZPK) model 
   %    SYS with zeros Z, poles P, and gains K. SYS is an object of class @zpk.
   %
   %    SYS = ZPK(Z,P,K,Ts) creates a discrete-time ZPK model with sampling
   %    time Ts (set Ts=-1 if the sampling time is undetermined).
   %
   %    S = ZPK('s') specifies H(s) = s (Laplace variable).
   %    Z = ZPK('z',TS) specifies H(z) = z with sample time TS.
   %    You can then specify ZPK models directly as expressions in S or Z, 
   %    for example,
   %       z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
   %
   %    SYS = ZPK creates an empty zero-pole-gain model.
   %    SYS = ZPK(D) specifies a static gain matrix D.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = zpk(1,2,3,'Variable','p','DisplayFormat','freq')
   %    also sets the variable and display format. Type "properties(zpk)" 
   %    for a complete list of model properties, and type 
   %       help zpk.<PropertyName>
   %    for help on a particular property. For example, "help zpk.ioDelay" 
   %    provides information about the "ioDelay" property.
   %
   %  Data format:
   %    For SISO models, Z and P are the vectors of zeros and poles (set
   %    Z=[] when there are no zeros) and K is the scalar gain.
   %
   %    For MIMO systems with NY outputs and NU inputs,
   %      * Z and P are NY-by-NU cell arrays where Z{i,j} and P{i,j}
   %        specify the zeros and poles of the transfer function from
   %        input j to output i
   %      * K is the 2D matrix of gains for each I/O channel.
   %    For example,
   %       H = zpk( {[];[2 3]} , {1;[0 -1]} , [-5;1] )
   %    specifies the two-output, one-input ZPK model
   %       [    -5 /(s-1)      ]
   %       [ (s-2)(s-3)/s(s+1) ]
   %
   %  Arrays of zero-pole-gain models:
   %    You can create arrays of ZPK models by using ND cell arrays for Z,P
   %    and a ND double array for K. For example, if Z,P,K are 3D arrays
   %    of size [NY NU 5], then
   %       SYS = ZPK(Z,P,K)
   %    creates the 5-by-1 array of ZPK models
   %       SYS(:,:,m) = ZPK(Z(:,:,m),P(:,:,m),K(:,:,m)),   m=1:5.
   %    Each of these models has NY outputs and NU inputs.
   %
   %    To pre-allocate an array of zero ZPK models with NY outputs and NU
   %    inputs, use the syntax
   %       SYS = ZPK(ZEROS([NY NU k1 k2...])) .
   %
   %  Conversion:
   %    SYS = ZPK(SYS) converts any dynamic system SYS to the ZPK
   %    representation. The resulting SYS is of class @zpk.
   %
   %  See also ZPK/EXP, ZPKDATA, ZPK, SS, FRD, DYNAMICSYSTEM.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.24.4.12 $  $Date: 2010/04/30 00:36:18 $
   
   % Add static method to be included for compiler
   %#function ltipack.utValidateTs
   %#function zpk.loadobj
   
   % Public properties with restricted value
   properties (Access = public, Dependent)
      % System zeros (cell array of column vectors).
      %
      % The "z" property stores the transfer function zeros. For SISO models,
      % set "z" to the vector of zeros (roots of the numerator). For MIMO 
      % models with Ny outputs and Nu inputs, set "z" to the Ny-by-Nu cell 
      % array of zero vectors for each I/O pair. For example, 
      %    z = {-3 , [-1+2i -1-2i]}
      %    p = {[-1 -2] , [0 -10]}
      %    k = [1 , 1];
      %    H = zpk(z,p,k)
      % specifies the two-input, one-output transfer function:
      %    [  (s+3)/(s+1)/(s+2) ,  (s^2 + 2s + 5)/s/(s+10)  ]
      z
      % System poles (cell array of column vectors).
      %
      % The "p" property stores the transfer function poles. For SISO models,
      % set "p" to the vector of poles (roots of the denominator). For MIMO 
      % models with Ny outputs and Nu inputs, set "p" to the Ny-by-Nu cell 
      % array of pole vectors for each I/O pair. For example, 
      %    z = {-3 , [-1+2i -1-2i]}
      %    p = {[-1 -2] , [0 -10]}
      %    k = [1 , 1];
      %    H = zpk(z,p,k)
      % specifies the two-input, one-output transfer function:
      %    [  (s+3)/(s+1)/(s+2) ,  (s^2 + 2s + 5)/s/(s+10)  ]
      p
      % System gains (double array).
      %
      % The "k" property stores the transfer function gains. For models with 
      % Ny outputs and Nu inputs, set "k" to the Ny-by-Nu matrix of gains 
      % for each I/O pair. For example,
      %    z = cell(2);
      %    p = {-1 -2;-3 -4}
      %    k = [1 2;3 4];
      %    H = zpk(z,p,k)
      % specifies the two-input, two-output transfer function:
      %    [  1/(s+1)  2/(s+2)  ;  3/(s+3)  4/(s+4)  ]
      k
      % Pole/zero display format (string, default = 'roots').
      %
      % You can set this property to 'roots', 'time constant', or 'frequency'.
      % The 'roots' format shows the factored form of the numerator and
      % denominator polynomials. The 'time constant' format shows the damping
      % and time constants of each pole and zero, for example:
      %     0.1 (1+0.5 s) 
      %    ---------------
      %    (1+0.7s) (1+2s)
      % The 'frequency' format shows the damping and natural frequency of each
      % pole and zero, for example:
      %     3.2 (1 + 0.1(s/2) + (s/2)^2)
      %     -----------------------------
      %         (1+s/1.4) (1+s/0.5)
      %
      % In discrete time, the 'time constant' and 'frequency' formats are 
      % written it terms of w=(z-1)/Ts to preserve the continuous-time 
      % interpretation of time constants and natural frequencies. Note that
      % these two formats cannot be used with Variable='z^-1'.
      DisplayFormat
      % Transfer function variable (string, default = 's' or 'z').
      %
      % You can set this property to either 's' or 'p' in continuous time,
      % and to 'z', 'q', or 'z^-1' in discrete time. Note that s and p are
      % equivalent and so are z and q. This property only affects how the 
      % ZPK model is displayed.
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
      % For MIMO systems with Ny outputs and Nu inputs, set "ioDelay" to a
      % Ny-by-Nu matrix. You can also set this property to a scalar value 
      % to apply the same delay to all I/O pairs.
      %
      % Example: sys.ioDelay = [0 , 1.2 ; 0.5 , 0] specifies nonzero
      % transport delays from input 1 to output 2 and from input 2 to
      % output 1.
      ioDelay
   end

   properties (Access = protected)
      % Storage for DisplayFormat property
      DisplayFormat_   % type = string
      % Storage for Variable property
      Variable_  % type = string
   end
   
   % OBSOLETE PROPERTIES
   properties (Access = public, Dependent, Hidden)
      % Shortened to ioDelay
      ioDelayMatrix
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = {'pidstd','pid','tf'};
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
      
      function sys = zpk(varargin)
         ni = nargin;
         % Handle conversion ZPK(SYS) where SYS is a ZPK object
         if ni>0 && strcmp(class(varargin{1}),'zpk')
            if ni>1,
               ctrlMsgUtils.error('Control:ltiobject:construct1','zpk')
            end
            sys = varargin{1};   return
         end
                  
         % Trap the syntax ZPK('s',...) or ZPK('z',Ts,...)
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
            ni = 4+length(varargin);
            varargin = [{0 [] 1 Ts} varargin];
         end
          
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
               ctrlMsgUtils.error('Control:ltiobject:construct3','zpk')
            elseif ni>0
               ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','zpk','zpk')
            end
         elseif DataInputs>4
            ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','zpk','zpk')
         end
         
         % Process numerical data
         try
            switch DataInputs,
               case 0
                  if ni
                     ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','zpk','zpk')
                  else
                     z = {};  p = {};  k = [];
                  end
                  
               case 1
                  % Gain matrix
                  kmat = varargin{1};
                  if ~isnumeric(kmat),
                     ctrlMsgUtils.error('Control:ltiobject:construct2','zpk')
                  end
                  z = cell(size(kmat));
                  z(:) = {zeros(0,1)};
                  p = z;
                  k = double(full(kmat));
                  
               case 2
                  ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','zpk','zpk')
                  
               otherwise
                  % Z,P,K specified
                  z = checkZPKData(varargin{1},'z');
                  p = checkZPKData(varargin{2},'p');
                  k = checkZPKData(varargin{3},'k');
            end
            
            % Sample time
            if DataInputs==4
               % Discrete SS
               Ts = ltipack.utValidateTs(varargin{4});
            else
               Ts = 0;
            end
         catch ME
            throw(ME)
         end
         
         % Determine I/O and array size
         if ni>0
            Ny = size(k,1);
            Nu = size(k,2);
            ArraySize = ltipack.getLTIArraySize(2,z,p,k);
            if isempty(ArraySize)
               ctrlMsgUtils.error('Control:ltiobject:zpk1')
            end
         else
            Ny = 0;  Nu = 0;  ArraySize = [1 1];
         end
         Nsys = prod(ArraySize);
         sys.IOSize_ = [Ny Nu];
            
         % Create @zpkdata object array
         % RE: Inlined for optimal speed
         if Nsys==1
            Data = ltipack.zpkdata(z,p,k,Ts);
         else
            Data = ltipack.zpkdata.array(ArraySize);
            Delay = ltipack.utDelayStruct(Ny,Nu,false);
            for ct=1:Nsys
               Data(ct).z = z(:,:,min(ct,end));
               Data(ct).p = p(:,:,min(ct,end));
               Data(ct).k = k(:,:,min(ct,end));
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
                  ctrlMsgUtils.warning('Control:ltiobject:ZPKComplex')
               end
            catch ME
               throw(ME)
            end
         end
      end
      
      function Value = get.z(sys)
         % GET method for z property
         Data = sys.Data_;
         Value = cell([sys.IOSize_ size(Data)]);
         for ct=1:numel(Data)
            Value(:,:,ct) = Data(ct).z;
         end
      end
      
      function Value = get.p(sys)
         % GET method for p property
         Data = sys.Data_;
         Value = cell([sys.IOSize_ size(Data)]);
         for ct=1:numel(Data)
            Value(:,:,ct) = Data(ct).p;
         end
      end
      
      function Value = get.k(sys)
         % GET method for k property
         Data = sys.Data_;
         Value = zeros([sys.IOSize_ size(Data)]);
         for ct=1:numel(Data)
            Value(:,:,ct) = Data(ct).k;
         end
      end
      
      function sys = set.z(sys,Value)
         % SET method for z property (cannot change I/O size)
         Value = checkZPKData(Value,'z');
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            Data(ct).z = Value(:,:,min(ct,end));
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
      
      function sys = set.p(sys,Value)
         % SET method for p property (cannot change I/O size)
         Value = checkZPKData(Value,'p');
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            Data(ct).p = Value(:,:,min(ct,end));
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
      
      function sys = set.k(sys,Value)
         % SET method for k property (cannot change I/O size)
         Value = checkZPKData(Value,'k');
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            Data(ct).k = Value(:,:,min(ct,end));
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));
            end
         end
         sys.Data_ = Data;
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
         if sys.CrossValidation_
            % Check consistency with DisplayFormat
            sys.DisplayFormat_ = ltipack.checkDisplayFormat(sys,sys.DisplayFormat_);
         end
      end
      
      function Value = get.DisplayFormat(sys)
         % GET method for DisplayFormat property
         Value = sys.DisplayFormat_;
         if isempty(Value)
            Value = 'roots';
         end
      end
      
      function sys = set.DisplayFormat(sys,Value)
         % SET method for DisplayFormat property
         if ~(ischar(Value) && any(strncmpi(Value,{'r','t','f'},1)))
            ctrlMsgUtils.error('Control:ltiobject:setZPK1')
         else
            Formats = {'roots','time constant','frequency'};
            Value = Formats{lower(Value(1))=='rtf'};
         end
         if sys.CrossValidation_
            % Check consistency with Ts
            Value = ltipack.checkDisplayFormat(sys,Value);
         end
         sys.DisplayFormat_ = Value;
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
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeZPK1',ny,nu))
         else
            ArrayDims = sprintf('%dx',sizes(3:end));
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeZPK2',...
               ArrayDims(1:end-1),ny,nu))
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
   methods (Access = protected)
      
      %% MODEL CHARACTERISTICS
      function sys = checkDataConsistency(sys)
         % Cross validation of system data. Extends @lti implementation
         % Generic data validation
         sys = checkDataConsistency@lti(sys);
         
         % Variable/Ts compatibility
         sys.Variable_ = ltipack.checkVariable(sys,sys.Variable_);
         
         % Variable/DisplayFormat compatibility
         sys.DisplayFormat_ = ltipack.checkDisplayFormat(sys,sys.DisplayFormat_);
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
         % Match DisplayFormat
         [sys1,sys2] = ltipack.matchDisplayFormat(sys1,sys2);
      end

      %% INDEXING AND ARRAY MANIPULATIONS
      function sys = indexref_(sys,indrow,indcol,ArrayIndices)
         % Implements sys(indices)
         sys = indexref_@ltipack.SystemArray(sys,indrow,indcol,ArrayIndices);
         % g400213: reset variable if resulting ZPK array is empty
         if isempty(sys.Data_)
            sys.Variable_ = [];
         end
      end
      
      function sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask)
         % Data management in SYS(indices) = RHS.
         % ioSize is the new I/O size and ArrayMask tracks which
         % entries in the resulting system array have been reassigned.

         % Construct template initial value for new entries in system array
         c = cell(ioSize);  c(:) = {zeros(0,1)};
         D0 = ltipack.zpkdata(c,c,zeros(ioSize),getTs_(sys));
         D0.Delay.Input(:) = NaN;
         D0.Delay.Output(:) = NaN;
         % Update data
         sys.Data_ = indexasgn(sys.Data_,indices,rhs.Data_,ioSize,ArrayMask,D0);
         % g400213: reset variable if resulting ZPK array is empty
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
         % Specialization to ZPK models
         % To avoid introducing internal delays in SS realization, cache
         % delays and zero them out before conversion to SS
         [ny,nu] = iosize(sys);
         Delay = sys.Data_.Delay;
         sys.Data_.Delay = ltipack.utDelayStruct(ny,nu,false);
         % Compute reduced model in state space
         rsys = balred_(ss(sys),orders,BalData,Options);
         % Convert back to ZPK and restore original delays
         rsys = zpk(rsys);
         D = rsys.Data_;
         for ct=1:numel(D)
            D(ct).Delay = Delay;
         end
         sys.Data_ = D;  % preserves metadata
      end
      
   end
   
   %% PROTECTED METHODS
   methods (Access=protected)
      
      function S = getSettings(sys)
         % Gets values of public LTI properties. Needed to support zpk(z,p,k,LTI)
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
          %tuning API/GUI tools now supports designing for @zpk class.
          % use ZPKdata directly
          if nargin<=3
              Gdata = G.Data_;
          else
              Gdata = G.Data_(index);
          end
          if ischar(C)
              C = ltipack.getPIDfromType(C,getTs(G));
          end
          % obtain PIDTuningData
          TuningData = ltipack.PIDTuningData(Gdata,C);
      end
      
   end
   
   %% STATIC METHODS
   methods(Static, Hidden)
      sys = loadobj(s)     
      
      function sys = make(D,IOSize)
         % Constructs ZPK model from ltipack.zpkdata instance
         sys = zpk;
         sys.Data_ = D;
         if nargin>1
            sys.IOSize_ = IOSize;  % support for empty model arrays
         else
            sys.IOSize_ = iosize(D(1));
         end
      end
   end
   
end
