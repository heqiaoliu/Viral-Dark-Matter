classdef ss < lti & StateSpaceModel
   %SS  Constructs state-space model or converts model to state space.
   %
   %  Construction:
   %    SYS = SS(A,B,C,D) creates an object SYS of class @ss representing 
   %    the continuous-time state-space model
   %         dx/dt = Ax(t) + Bu(t)
   %          y(t) = Cx(t) + Du(t)
   %    You can set D=0 to mean the zero matrix of appropriate dimensions.
   %    If one or more of the matrices A,B,C,D have uncertainty, SS returns
   %    an uncertain state-space (USS) model (Robust Control Toolbox only).
   %
   %    SYS = SS(A,B,C,D,Ts) creates a discrete-time state-space model with
   %    sampling time Ts (set Ts=-1 if the sampling time is undetermined).
   %
   %    SYS = SS creates an empty SS object.
   %    SYS = SS(D) specifies a static gain matrix D.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = ss(-1,2,1,0,'InputDelay',0.7,'StateName','position')
   %    also sets the input delay and the state name. Type "properties(ss)" 
   %    for a complete list of model properties, and type 
   %       help ss.<PropertyName>
   %    for help on a particular property. For example, "help ss.StateName" 
   %    provides information about the "StateName" property.
   %
   %  Arrays of state-space models:
   %    You can create arrays of state-space models by using ND arrays for
   %    A,B,C,D. The first two dimensions of A,B,C,D define the number of 
   %    states, inputs, and outputs, while the remaining dimensions specify 
   %    the array sizes. For example,
   %       sys = ss(rand(2,2,3,4),[2;1],[1 1],0)
   %    creates a 3x4 array of SISO state-space models. You can also use
   %    indexed assignment and STACK to build SS arrays:
   %       sys = ss(zeros(1,1,2))     % create 2x1 array of SISO models
   %       sys(:,:,1) = rss(2)        % assign 1st model
   %       sys(:,:,2) = ss(-1)        % assign 2nd model
   %       sys = stack(1,sys,rss(5))  % add 3rd model to array
   %
   %  Conversion:
   %    SYS = SS(SYS) converts any dynamic system SYS to state space by 
   %    computing a state-space realization of SYS. The resulting SYS is 
   %    of class @ss.
   %
   %    SYS = SS(SYS,'min') computes a minimal realization of SYS.
   %
   %    SYS = SS(SYS,'explicit') computes an explicit realization (E=I) of SYS.
   %    An error is thrown if SYS is improper.
   %
   %    See also DSS, DELAYSS, RSS, DRSS, SSDATA, TF, ZPK, FRD, DYNAMICSYSTEM.
   
%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.28.4.19 $  $Date: 2010/04/30 00:36:16 $
   
   % Add static method to be included for compiler
   %#function ltipack.utValidateTs
   %#function ss.loadobj
   %#function ss.make
   %#function ss.cast

   % Public properties with restricted value
   properties (Access = public, Dependent)
      % State matrix A.
      %
      % Set this property to a square matrix with as many rows as states, for 
      % example, sys.a = [-1 3;0 -5] for a second-order model "sys".
      a
      % Input-to-state matrix B.
      %
      % Set this property to a matrix with as many rows as states and as many   
      % columns as inputs, for example, sys.b = [0;1] for a single-input, 
      % second-order system "sys".
      b
      % State-to-output matrix C.
      %
      % Set this property to a matrix with as many rows as outputs and as many   
      % columns as states, for example, sys.c = [1 -1] for a single-output, 
      % second-order system "sys".
      c
      % Feedthrough matrix D.
      %
      % Set this property to a matrix with as many rows as outputs and as many   
      % columns as inputs, for example, sys.d = [1 0] for a single-output, 
      % two-input system "sys".
      d
      % E matrix for implicit (descriptor) state-space models.
      %
      % By default E=[], meaning that the state equation is explicit. To 
      % specify an implicit state equation E dx/dt = A x + B u, set this
      % property to a square matrix of the same size as A. Note that E
      % may be singular, for example, when modeling a pure derivative
      % element in state-space form. See DSS for more details on descriptor
      % state-space models.
      e
      % Enables/disables auto-scaling (logical, default = false).
      %
      % When Scaled=false, most numerical algorithms acting on this system
      % automatically rescale the state vector to improve numerical accuracy.
      % You can disable such auto-scaling by setting Scaled=true. See PRESCALE
      % for more details on scaling issues.
      Scaled
      % State names (string vector, default = empty string for all states).
      %
      % This property can be set to:
      %  * A string for first-order models, for example, 'position' 
      %  * A string vector for models with two or more states, for example, 
      %    {'position' ; 'velocity'}
      % Use the empty string '' for unnamed states.
      StateName
      % State units (string vector, default = empty string for all states).
      %
      % Use this property to keep track of the units each state is expressed in.
      % You can set "StateUnit" to: 
      %  * A string for first-order models, for example, 'm/s' 
      %  * A string vector for models with two or more states, for example, 
      %    {'m' ; 'm/s'}
      StateUnit
      % Internal delays (numeric vector, default = [])   .
      %
      % Internal delays arise, for example, when closing feedback loops with
      % delays or connecting delay systems in series or parallel. See the
      % User's Guide for details. For continuous-time systems, internal delays 
      % are expressed in the time unit specified by the "TimeUnit" property. 
      % For discrete-time systems, internal delays are expressed as integer 
      % multiples of the sampling period "Ts", for example, InternalDelay=3  
      % means a delay of three sampling periods.
      %
      % You can modify the values of internal delays but the number of entries
      % in sys.InternalDelay cannot change (structural property of the model).        
      InternalDelay
   end
   
   % OBSOLETE PROPERTIES
   properties (Access = public, Dependent, Hidden)
      % Obsolete property for state-space models.
      ioDelay
      % Obsolete property for state-space models.
      ioDelayMatrix
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = {'pidstd','pid','tf','zpk'};
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
      
      function sys = ss(varargin)
         ni = nargin;
         % Handle conversion SS(SYS) where SYS is a class with constructor named "ss"
         % (no ss() converter can be defined for such class)
         if ni>0 && isa(varargin{1},'StateSpaceModel')
            sys0 = varargin{1};
            switch ni
               case 1
                  if isa(sys0,'ss')  % Optimization for SYS of class @ss
                     sys = sys0;
                  else
                     sys = copyMetaData(sys0,ss_(sys0)); % e.g., ltiblock.ss
                  end
               case 2
                  optflag = ltipack.matchKey(varargin{2},{'minimal','explicit'});
                  sys = copyMetaData(sys0,ss_(sys0,optflag));
               otherwise
                  ctrlMsgUtils.error('Control:ltiobject:construct1','ss')
            end
            return
         end
         
         % Dissect input list
         DataInputs = 0;
         LtiInput = 0;
         PVStart = ni+1;
         for ct=1:ni
            nextarg = varargin{ct};
            if isa(nextarg,'struct') || isa(nextarg,'lti')
               % LTI settings inherited from other model
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
               ctrlMsgUtils.error('Control:ltiobject:construct3','ss')
            elseif ni>0
               ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ss','ss')
            end
         elseif DataInputs>5
            ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ss','ss')
         end
         
         % Process numerical data
         try
            switch DataInputs,
               case 0
                  if ni,
                     ctrlMsgUtils.error('Control:ltiobject:construct4','ss')
                  else
                     % Empty model
                     a = [];  b = [];  c = [];  d = [];
                  end
               case 1
                  % Gain matrix
                  a = [];  b = [];  c = [];
                  d = ltipack.checkABCDE(varargin{1},'d');
               case {2,3}
                  ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ss','ss')
               otherwise
                  % A,B,C,D specified: validate data
                  a = ltipack.checkABCDE(varargin{1},'a');
                  b = ltipack.checkABCDE(varargin{2},'b');
                  c = ltipack.checkABCDE(varargin{3},'c');
                  d = ltipack.checkABCDE(varargin{4},'d');
            end
            
            % Sample time
            if DataInputs==5
               % Discrete SS
               Ts = ltipack.utValidateTs(varargin{5});
            else
               Ts = 0;
            end
         catch ME
            throw(ME)
         end
         
         % Determine I/O and array size
         if ni>0
            Ny = max(size(c,1),size(d,1));
            Nu = max(size(b,2),size(d,2));
            ArraySize = ltipack.getLTIArraySize(2,a,b,c,d);
            if isempty(ArraySize)
               ctrlMsgUtils.error('Control:ltiobject:ss1')
            end
         else
            Ny = 0;  Nu = 0;  ArraySize = [1 1];
         end
         Nsys = prod(ArraySize);
         sys.IOSize_ = [Ny Nu];
         
         % Create @ssdata object array
         % RE: Inlined for optimal speed
         if Nsys==1
            Data = ltipack.ssdata(a,b,c,d,[],Ts);
         else
            Data = ltipack.ssdata.array(ArraySize);
            Delay = ltipack.utDelayStruct(Ny,Nu,true);
            for ct=1:Nsys
               Data(ct).a = a(:,:,min(ct,end));
               Data(ct).b = b(:,:,min(ct,end));
               Data(ct).c = c(:,:,min(ct,end));
               Data(ct).d = d(:,:,min(ct,end));
               Data(ct).e = [];
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
                  % @ss does not inherit internal delays (including ioDelay)
                  if isfield(arg,'ioDelay')
                     arg = rmfield(arg,'ioDelay');
                  end
                  Settings = [Settings , lti.struct2pv(arg)];
               end
               
               % User-defined properties
               [pvpairs,iodSettings] = LocalCheckDelaySettings(varargin(:,PVStart:ni));
               Settings = [Settings , pvpairs];
               
               % Apply settings except ioDelay
               if ~isempty(Settings)
                  sys = fastSet(sys,Settings{:});
               end
               
               % Consistency check
               sys = checkConsistency(sys);
               
               % I/O delay settings. Must be done after data checks to prevent errors in
               % setIODelay when A,B,C are not properly formatted (e.g., A=B=C=[] and D=1)
               if ~isempty(iodSettings)
                  sys = fastSet(sys,iodSettings{:});
               end
            catch ME
               throw(ME)
            end
         end
      end

      %---------------- GET/SET ------------------------------------------
      
      function Value = get.a(sys)
         % GET method for a property
         Value = localGetABCDE(sys.Data_,'a',[0,0]);
      end
      
      function Value = get.b(sys)
         % GET method for b property
         Value = localGetABCDE(sys.Data_,'b',[0,sys.IOSize_(2)]);
      end
      
      function Value = get.c(sys)
         % GET method for c property
         Value = localGetABCDE(sys.Data_,'c',[sys.IOSize_(1),0]);
      end
      
      function Value = get.d(sys)
         % GET method for d property
         Value = localGetABCDE(sys.Data_,'d',sys.IOSize_);
      end
      
      function Value = get.e(sys)
         % GET method for e property
         Value = localGetABCDE(sys.Data_,'e',[0,0]);
      end

      function sys = set.a(sys,Value)
         % SET method for a property
         sys = localSetABCDE(sys,'a',Value);
      end
      
      function sys = set.b(sys,Value)
         % SET method for b property
         sys = localSetABCDE(sys,'b',Value);
      end
      
      function sys = set.c(sys,Value)
         % SET method for c property
         sys = localSetABCDE(sys,'c',Value);
      end
      
      function sys = set.d(sys,Value)
         % SET method for d property
         sys = localSetABCDE(sys,'d',Value);
      end
      
      function sys = set.e(sys,Value)
         % SET method for e property (cannot change state size)
         Value = ltipack.checkABCDE(Value,'e');
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            Data(ct).e = Value(:,:,min(ct,end));
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));  % Quick validation
            end
         end
         sys.Data_ = Data;
      end
      
      function Value = get.Scaled(sys)
         % GET method for Scaled property
         % True if all models are scaled, false otherwise
         Value = true;
         Data = sys.Data_;
         for ct=1:numel(Data)
            if ~Data(ct).Scaled
               Value = false;  break
            end
         end
      end
      
      function sys = set.Scaled(sys,Value)
         % SET method for Scaled property
         if ~(isscalar(Value) && (islogical(Value) || isnumeric(Value)))
            ctrlMsgUtils.error('Control:ltiobject:setSS4')
         end
         Value = logical(Value);
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Scaled = Value;
         end            
         sys.Data_ = Data;
      end
      
      function Value = get.StateName(sys)
         % GET method for StateName property
         Value = ltipack.SystemArray.getStateInfo(sys.Data_,'StateName');
      end
      
      function Value = get.StateUnit(sys)
         % GET method for StateUnit property
         Value = ltipack.SystemArray.getStateInfo(sys.Data_,'StateUnit');
      end
      
      function sys = set.StateName(sys,Value)
         % SET method for StateName property
         Data = sys.Data_;
         nsys = numel(Data);
         if nsys>0
            Value = ltipack.checkStateInfo(Value,'StateName');
            nx = size(Data(1).a,1);
            for ct=1:nsys
               if size(Data(ct).a,1)~=nx,
                  % Not supported for varying state dimension
                  ctrlMsgUtils.error('Control:ltiobject:setSS2')
               end
            end
            for ct=1:nsys
               Data(ct).StateName = Value;
               if sys.CrossValidation_
                  Data(ct) = checkData(Data(ct));
               end
            end
            sys.Data_ = Data;
         end
      end
      
      function sys = set.StateUnit(sys,Value)
         % SET method for StateUnit property
         Data = sys.Data_;
         nsys = numel(Data);
         if nsys>0
            Value = ltipack.checkStateInfo(Value,'StateUnit');
            nx = size(Data(1).a,1);
            for ct=1:nsys
               if size(Data(ct).a,1)~=nx,
                  % Not supported for varying state dimension
                  ctrlMsgUtils.error('Control:ltiobject:setSS5')
               end
            end
            for ct=1:nsys
               Data(ct).StateUnit = Value;
               if sys.CrossValidation_
                  Data(ct) = checkData(Data(ct));
               end
            end
            sys.Data_ = Data;
         end
      end
            
      function Value = get.InternalDelay(sys)
         % GET method for InternalDelay property
         Data = sys.Data_;
         Nsys = numel(Data);
         if Nsys==0
            Value = zeros(0,1);
         elseif Nsys==1
            Value = Data.Delay.Internal;
         else
            RefValue = Data(1).Delay.Internal;
            ndf = length(RefValue);
            Value = zeros([ndf 1 size(Data)]);
            isUniform = true;
            for ct=1:Nsys
               Df = Data(ct).Delay.Internal;
               isUniform = isUniform && isequal(Df,RefValue);
               if length(Df)==ndf
                  Value(:,ct) = Df;
               else
                  ctrlMsgUtils.error('Control:ltiobject:get5')
               end
            end
            if isUniform
               Value = Value(:,1);
            end
         end
      end
      
      function sys = set.InternalDelay(sys,Value)
         % SET method for InternalDelay property
         if ~(isnumeric(Value) && isreal(Value) && all(isfinite(Value(:))) && all(Value(:)>=0))
            ctrlMsgUtils.error('Control:ltiobject:setLTI1','InternalDelay')
         else
            Value = double(full(Value));
         end
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            df = Value(:,:,min(ct,end));
            df = df(:);
            if length(df)~=length(Data(ct).Delay.Internal)
               ctrlMsgUtils.error('Control:ltiobject:setSS3')
            end
            Data(ct).Delay.Internal = df;
            if sys.CrossValidation_
               Data(ct) = checkDelay(Data(ct));
            end
         end
         sys.Data_ = Data;
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
   
   
   methods (Hidden)
      
      function sys = utSimplifyDelay(sys)
         % Replaces internal delays by input or output delays when possible
         % (used by SCD)
         sys.Data_ = simplifyDelay(sys.Data_);
      end
      
      % INTERFACE WITH HINFSTRUCT
      function [P,pInfo] = HINFSTRUCT_Interface(sysP,C)
         % Constructs LFT and parameterization data for HINFSTRUCT.
         % This function takes:
         %   * Plant model sysP (@DynamicSystem)
         %   * Block list C (cell vector of Control Design blocks)
         if ~iscell(C)   
            C = {C};  % Handle single block   
         end 
         for ct=1:numel(C)
            C{ct} = ltipack.LFTBlockWrapper(C{ct});
         end
         C = cat(1,C{:});
         if any(fliplr(iosize(C))>=iosize(sysP))
            ctrlMsgUtils.error('Robust:design:hinfstruct17')
         end
         [P,pInfo] = hinfstructSetUp(sysP.Data_,C);
      end

      % INTERFACE WITH PIDTUNE
      function TuningData = getPIDTuningData(G,C,NUP,index)
          %GETPIDTUNINGDATA returns ltipack.PIDTuningData object that
          %implements RRT tuning method.  By overloading this method PID
          %tuning API/GUI tools now supports designing for @ss class.
          % Note that we convert SSdata to FRDdata when it has internal
          % delay and cannot be represented by ZPKdata, otherwise SSdata is
          % converted to ZPKdata
          if nargin<=3
              Gdata = G.Data_;
          else
              Gdata = G.Data_(index);
          end
          if ischar(C)
              C = ltipack.getPIDfromType(C,getTs(G));
          end
          if hasInternalDelay(Gdata)
              % convert to ZPKdata if possible
              hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
              try
                  % try convert to ZPKdata
                  Gdata = zpk(Gdata);
                  % obtain PIDTuningData
                  TuningData = ltipack.PIDTuningData(Gdata,C);
              catch %#ok<CTCH>
                  % Extract linear I/O delays
                  iod = Gdata.Delay.Input + Gdata.Delay.Output;
                  Gdata.Delay.Input = 0;
                  Gdata.Delay.Input = 0;
                  % Generate frequency grid
                  [z0,p0] = iodynamics(Gdata);
                  w = freqgrid(Gdata,z0,p0,1,[]);
                  w = w(w>0);
                  % FRDdata 
                  Gdata = ltipack.frddata(fresp(Gdata,w),w,Gdata.Ts);
                  Gdata.Delay.IO = iod;
                  % obtain PIDTuningData
                  TuningData = ltipack.PIDTuningData(Gdata,C,NUP);
              end
          else
              % convert to ZPKdata
              Gdata = zpk(Gdata);
              % obtain PIDTuningData
              TuningData = ltipack.PIDTuningData(Gdata,C);
          end
      end
      
   end
   
   
   methods (Access = protected)
      
      %% INPUTOUTPUTMODEL ABSTRACT INTERFACE
      function displaySize(sys,sizes)
         % Displays SIZE information in SIZE(SYS)
         ny = sizes(1);
         nu = sizes(2);
         nx = order(sys);
         if isempty(nx)
            nx = 0;
         end
         if length(sizes)==2,
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeSS1',ny,nu,nx))
         else
            ArrayDims = sprintf('%dx',sizes(3:end));
            if all(nx(:)==nx(1))
               disp(ctrlMsgUtils.message('Control:ltiobject:SizeSS2',...
                  ArrayDims(1:end-1),ny,nu,nx(1)))
            else
               disp(ctrlMsgUtils.message('Control:ltiobject:SizeSS3',...
                  ArrayDims(1:end-1),ny,nu,min(nx(:)),max(nx(:))))
            end
         end
      end
      
      %% DATA ABSTRACTION INTERFACE
      function sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask)
         % Data management in SYS(indices) = RHS.
         % ioSize is the new I/O size and ArrayMask tracks which
         % entries in the resulting system array have been reassigned.

         % Construct template initial value for new entries in system array
         D0 = ltipack.ssdata([],zeros(0,ioSize(2)),zeros(ioSize(1),0),...
            zeros(ioSize),[],getTs_(sys));
         D0.Delay.Input(:) = NaN;
         D0.Delay.Output(:) = NaN;
         % Update data
         sys.Data_ = indexasgn(sys.Data_,indices,rhs.Data_,ioSize,ArrayMask,D0);
      end
      
   end
   
   %% STATIC METHODS
   methods(Static, Hidden)
      
      sys = loadobj(s)
      
      function sys = make(D,IOSize)
         % Constructs SS model from ltipack.ssdata instance
         sys = ss;
         sys.Data_ = D;
         if nargin>1
            sys.IOSize_ = IOSize;  % support for empty model arrays
         else
            sys.IOSize_ = iosize(D(1));
         end
      end
      
      function sys = cast(Model,varargin)
         % Casts static or dynamic model to @ss.
         if isnumeric(Model) || isa(Model,'StaticModel')
            % Work around ss(GENMAT) yielding a GENSS
            sys = ss(double(Model));
         elseif isa(Model,'DynamicSystem')
            % DynamicSystem subclass
            sys = ss(Model,varargin{:});
         else
            ctrlMsgUtils.error('Control:transformation:ss2',class(Model))
         end
      end
      
   end
   
end
   
   
%--------------------- Local Functions --------------------------------

function [pvp,iodpvp] = LocalCheckDelaySettings(pvp)
% Pulls out ioDelay settings, throws error when setting InternalDelays
if any(strncmpi(pvp(1:2:end),'int',3))
    ctrlMsgUtils.error('Control:ltiobject:ss2')
end
idx = find(strncmpi(pvp(1:2:end),'io',2));
iodpvp = cell(1,0);
for ct=length(idx):-1:1
   k = 2*idx(ct)-1;
   iodpvp = [iodpvp , pvp(k:min(k+1:end))]; %#ok<AGROW>
   pvp = [pvp(1:k-1) , pvp(k+2:end)];
end
end


function Value = localGetABCDE(Data,ABCDE,DefaultSize)
% Return nominal values of A, B, C, D, or E
tmp = cell(1,6);
iselect = find(ABCDE=='abcd e');
ArraySize = size(Data);
if isempty(Data)
   % Empty array
   Value = zeros([DefaultSize,ArraySize]);
elseif isscalar(Data)
   [tmp{:}] = getABCDE(Data);
   Value = tmp{iselect};
else
   ValueArray = cell(ArraySize);
   for ct=1:numel(Data)
      [tmp{:}] = getABCDE(Data(ct));
      ValueArray{ct} = tmp{iselect};
   end
   % Replace E=[] by identity of proper size if some E's are non-empty
   if strcmp(ABCDE,'e') && ~all(cellfun(@isempty,ValueArray(:)))
      for ct=1:numel(Data)
         if isempty(ValueArray{ct})
            ValueArray{ct} = eye(size(Data(ct).a));
         end
      end
   end
   % Turn into ND array
   try
      Value = cat(3,ValueArray{:});
      Value = reshape(Value,[size(Value,1) size(Value,2) ArraySize]);
   catch %#ok<CTCH>
       % A,B,C,E cannot be represented as ND arrays
       ctrlMsgUtils.error('Control:ltiobject:get4',ABCDE)
   end
end 
end


%%%%%%%%
function sys = localSetABCDE(sys,Property,Value)
% SET function for A,B,C,D
Value = ltipack.checkABCDE(Value,Property);
% Check compatibility of RHS with model array sizes
Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
sv = size(Value);
SameSize = (~isempty(Data) && isequal(sv(1:2),size(Data(1).(Property))));
for ct=1:numel(Data)
   if isempty(Data(ct).Delay.Internal)
      Data(ct).(Property) = Value(:,:,min(ct,end));
   else
      ctrlMsgUtils.error('Control:ltiobject:setSS1',Property)
   end
   if SameSize && sys.CrossValidation_
      Data(ct) = checkData(Data(ct));  % Quick validation
   end
end
sys.Data_ = Data;
if ~SameSize && sys.CrossValidation_
   % Note: Full validation needed because a single assignment can change I/O size,
   % e.g., sys = ss; sys.a = [1 2;3 4]
   %       sys = ss(1); sys.d = [1 2;3 4]
   %       sys = ss(1,[],[],[]); sys.b = 1;
   sys = checkConsistency(sys);
end
end
