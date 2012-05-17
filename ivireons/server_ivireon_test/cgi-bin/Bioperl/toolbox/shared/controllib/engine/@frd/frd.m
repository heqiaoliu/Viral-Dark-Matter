classdef (SupportClassFunctions=true) frd < lti & FRDModel
   %FRD  Constructs or converts to Frequency Response Data model.
   %
   %   Frequency Response Data (FRD) models store the frequency response of
   %   LTI systems, for example, experimental data collected with a frequency
   %   analyzer.
   %
   %  Construction:
   %    SYS = FRD(RESPONSE,FREQS) creates an FRD model SYS with response data
   %    RESPONSE specified at the frequency points in FREQS. The output SYS 
   %    is an object of class @frd.
   %
   %    SYS = FRD(RESPONSE,FREQS,TS) creates a discrete-time FRD model with
   %    sampling time TS (a positive value).
   %
   %    SYS = FRD creates an empty FRD model.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = frd(1:10,1:10,'FrequencyUnit','Hz')
   %    further specifies that the frequency vector is given in Hz. Type 
   %    "properties(frd)" for a complete list of model properties, and type 
   %       help frd.<PropertyName>
   %    for help on a particular property. For example, "help frd.ioDelay" 
   %    provides information about the "ioDelay" property.
   %
   %  Data format:
   %    For SISO models, FREQS is a vector of real frequencies, and RESPONSE 
   %    is a vector of frequency response values at these frequencies.
   %
   %    For MIMO FRD models with NY outputs, NU inputs, and NF frequency points,
   %    RESPONSE is a double array of size [NY NU NF] where RESPONSE(i,j,k) 
   %    specifies the frequency response from input j to output i at the 
   %    frequency point FREQS(k).
   %
   %    By default, FRD assumes that the frequencies FREQS are specified in 
   %    'rad/s'. To specify frequencies in Hz, set the "FrequencyUnit" property 
   %    to 'Hz'. To change the frequency unit from rad/s to Hz and convert
   %    the frequency values accordingly, use CHGUNITS.
   %
   %  Arrays of FRD models:
   %    You can create arrays of FRD models by using an ND array for RESPONSE.
   %    For example, if RESPONSE is an array of size [NY NU NF 3 4], then
   %       SYS = FRD(RESPONSE,FREQS)
   %    creates the 3-by-4 array of FRD models, where
   %       SYS(:,:,k,m) = FRD(RESPONSE(:,:,:,k,m),FREQS),  k=1:3,  m=1:4.
   %    Each of these FRD models has NY outputs, NU inputs, and data at
   %    the frequencies FREQS.
   %
   %  Conversion:
   %    SYS = FRD(SYS,FREQS,UNIT) converts any dynamic system SYS to the FRD
   %    representation by computing the system response at each frequency
   %    point in the vector FREQS.  The frequencies FREQS are expressed in
   %    the unit specified by the string UNIT ('rad/s' or 'Hz'). The default
   %    is 'rad/s' if UNIT is omitted. The resulting SYS is of class @frd.
   %
   %  See also FRDATA, CHGUNITS, TF, ZPK, SS, DYNAMICSYSTEM.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4 $  $Date: 2010/04/30 00:39:43 $
   
   % Add static method to be included for compiler
   %#function ltipack.utValidateTs
   %#function frd.loadobj

   % Public properties with restricted value
   properties (Access = public, Dependent)
      % Frequency response data (numeric array).
      %
      % The "ResponseData" property stores the frequency response data as
      % a 3D array of complex numbers. For SISO systems, set "ResponseData" 
      % to the vector of frequency response values at the specified 
      % frequency points (see "Frequency" property). For MIMO systems with 
      % NU inputs and NY outputs, set "ResponseData" to an array of size 
      % [NY NU NW] where NW is the number of frequency points (the frequency 
      % runs along the third dimension). 
      %
      % For example,
      %    w = logspace(-2,2,50)
      %    h = freqresp(rss(5,2,3),w)  % h is 2x3x50
      %    sys = frd(h,w)   
      % creates an FRD model with 3 inputs, 2 outputs, and 50 frequency 
      % points. 
      ResponseData
      % Vector of frequency points.
      %
      % This property stores the frequency points (vector of positive real 
      % numbers). The frequencies should be expressed in the units specified
      % by the "FrequencyUnit" property (default = rad/s).
      Frequency
      % Frequency unit (default = rad/s).
      %
      % This property specifies in what unit the frequency vector is expressed 
      % (see "Frequency" property). "FrequencyUnit" can be set to 'rad/s' 
      % or 'Hz' and is used for plotting and analysis purposes.
      FrequencyUnit
      % Transport delays (numeric array, default = all zeros).
      %
      % The "ioDelay" property specifies a separate time delay for each 
      % I/O pair. For continuous-time systems, specify I/O delays in
      % the time unit stored in the "TimeUnit" property. For discrete-
      % time systems, specify I/O delays as integer multiples of the
      % sampling period "Ts", for example, ioDelay=2 to mean a delay
      % of two sampling periods.
      %
      % For MIMO systems with Ny outputs and Nu inputs, set "ioDelay" to
      % a Ny-by-Nu matrix. You can also set "ioDelay" to a scalar value to 
      % apply the same delay to all I/O pairs.
      %
      % While delays can be specified as part of the frequency response 
      % data ("ResponseData" property), keeping them separate results in 
      % more accurate phase plots by preventing drifts due to phase 
      % wrapping and the limited frequency grid resolution.
      ioDelay
   end

   % OBSOLETE PROPERTIES
   properties (Access = public, Dependent, Hidden)
      % Shortened to ioDelay
      ioDelayMatrix
      % Renames to Unit
      Units
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = {'tf','zpk'};
      end
      
      function boo = isCombinable(~)
         boo = true;
      end
      
      function boo = isSystem()
         boo = true;
      end
      
      function boo = isFRD()
         boo = true;
      end
      
      function boo = isStructured()
         boo = false;
      end
      
      function boo = isGeneric()
         boo = true;
      end
      
      function T = toStructured(uflag)
         if uflag
            T = 'ufrd';
         else
            T = 'genfrd';
         end
      end
      
   end
   
   methods
      
      function sys = frd(varargin)
         ni = nargin;
         
         % Handle conversion FRD(SYS,...) where SYS is a FRD object
         if ni>0 && strcmp(class(varargin{1}),'frd')
            try
               [sys,~,unit] = FRDModel.parseFRDInputs('frd',varargin);
            catch ME
               throw(ME)
            end
            sys = chgunits(sys,unit);
            return
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
               ctrlMsgUtils.error('Control:ltiobject:construct3','frd')
            elseif ni>0
               ctrlMsgUtils.error('Control:ltiobject:construct3','frd')
            end
         elseif DataInputs>3
            ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','frd','frd')
         end
         
         % Process numerical data
         try
            switch DataInputs,
               case 0
                  if ni,
                     ctrlMsgUtils.error('Control:ltiobject:construct4','frd')
                  else
                     freq = zeros(0,1);  resp = zeros(0,0,0);
                  end
               case 1
                  ctrlMsgUtils.error('Control:ltiobject:frd2')
               otherwise
                  % FREQS and RESPONSE specified
                  resp = ltipack.utCheckFRDData(varargin{1},'r');
                  freq = ltipack.utCheckFRDData(varargin{2},'f');
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
            rsize = [size(resp) 1 1 1];
            Nf = length(freq);
            fdim = find(Nf==rsize(1:min(3,end)));
            if ~isempty(fdim)
               rsize = [ones((Nf>0),3-fdim(end)) rsize]; % watch for frd([],[])
               resp = reshape(resp,rsize); % g347287
            end
            Ny = rsize(1);
            Nu = rsize(2);
            ArraySize = rsize(4:end);
         else
            Ny = 0;  Nu = 0;  ArraySize = [1 1];
         end
         Nsys = prod(ArraySize);
         sys.IOSize_ = [Ny Nu];
         
         % Create @frddata object array
         % RE: Inlined for optimal speed
         if Nsys==1
            Data = ltipack.frddata(resp,freq,Ts);
         else
            Data = ltipack.frddata.array(ArraySize);
            Delay = ltipack.utDelayStruct(Ny,Nu,false);
            for ct=1:Nsys
               Data(ct).Frequency = freq;
               Data(ct).Response = resp(:,:,:,min(ct,end));
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
            catch ME
               throw(ME)
            end
         end
      end
      
      function Value = get.ResponseData(sys)
         % GET method for ResponseData property
         Data = sys.Data_;
         if isempty(Data)
            Value = zeros([sys.IOSize_,0,size(Data)]);
         else
            Value = zeros([sys.IOSize_,length(Data(1).Frequency),size(Data)]);
         end
         for ct=1:numel(Data)
            Value(:,:,:,ct) = Data(ct).Response;
         end
      end
            
      function sys = set.ResponseData(sys,Value)
         % SET method for ResponseData property
         Value = ltipack.utCheckFRDData(Value,'r');
         nf = length(sys.Frequency);
         if size(Value,3)~=nf
            % Look for frequency dimension among first two
            rsize = size(Value);
            fdim = find(rsize==nf);
            if ~isempty(fdim)
               Value = reshape(Value,[ones(1,3-fdim(1)) rsize]);
            end
         end
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,3);
         sv = size(Value);
         if isequal(sv(1:2),sys.IOSize_)
            % No change in I/O size
            for ct=1:numel(Data)
               Data(ct).Response = Value(:,:,:,min(ct,end));
               if sys.CrossValidation_
                  Data(ct) = checkData(Data(ct));  % Quick validation
               end
            end
            sys.Data_ = Data;
         else
            % I/O size changes
            for ct=1:numel(Data)
               Data(ct).Response = Value(:,:,:,min(ct,end));
            end
            sys.Data_ = Data;
            if sys.CrossValidation_
               % Note: Full validation needed because a single assignment can change I/O size,
               % e.g., sys = frd(1:10,1:10); sys.resp = randn(2,2,10);
               sys = checkConsistency(sys);
            end
         end
      end
            
      function Value = get.Frequency(sys)
         % GET method for Frequency property
         if isempty(sys.Data_)
            Value = zeros(0,1);
         else
            Value = sys.Data_(1).Frequency;
         end
      end
      
      function sys = set.Frequency(sys,Value)
         % SET method for Frequency property
         Value = ltipack.utCheckFRDData(Value,'f');
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Frequency = Value;
            if sys.CrossValidation_
               Data(ct) = checkData(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
      
      function Value = get.FrequencyUnit(sys)
         % GET method for FrequencyUnit property
         if isempty(sys.Data_)
            Value = 'rad/s';  % default
         else
            Value = sys.Data_(1).FreqUnits;
         end
      end
      
      function sys = set.FrequencyUnit(sys,Value)
         % SET method for FrequencyUnit property
         Unit = ltipack.matchKey(Value,{'rad/s','Hz'});
         if isempty(Unit)
            ctrlMsgUtils.error('Control:ltiobject:setFRD1')
         end
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).FreqUnits = Unit;
         end
         sys.Data_ = Data;
      end
      
      function Value = get.Units(sys)
         Value = sys.FrequencyUnit;
      end      
      function sys = set.Units(sys,Value)
         sys.FrequencyUnit = Value;
      end
      
      function Value = get.ioDelay(sys)
         % GET method for ioDelay property
         Value = getIODelay(sys);
      end
      
      function sys = set.ioDelay(sys,Value)
         % SET method for ioDelay property
         sys = setIODelay(sys,Value);
      end
      
      function Value = get.ioDelayMatrix(sys)
         Value = getIODelay(sys);
      end     
      function sys = set.ioDelayMatrix(sys,Value)
         sys = setIODelay(sys,Value);
      end
      
   end
   
   %% ABSTRACT SUPERCLASS INTERFACES
   methods (Access=protected)

      % INPUTOUTPUTMODEL
      function displaySize(sys,sizes)
         % Displays SIZE information in SIZE(SYS)
         ny = sizes(1);
         nu = sizes(2);
         nf = length(sys.Frequency);
         if length(sizes)==2,
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeFRD1',ny,nu,nf))
         else
            ArrayDims = sprintf('%dx',sizes(3:end));
            disp(ctrlMsgUtils.message('Control:ltiobject:SizeFRD2',...
               ArrayDims(1:end-1),ny,nu,nf))
         end
      end
      
      % FRDMODEL
      function sys = fcat_(sys,sys2)
         % FCAT(SYS,SYS2) for two FRD systems.
         [sys,sys2] = matchArraySize(sys,sys2);   % must come first
         [sys,sys2] = matchSamplingTime(sys,sys2);
         % Combine data
         sys.Data_ = fcat(sys.Data_,sys2.Data_);
      end
            
      function sys = fselect_(sys,index)
         % Select portion of frequency vector in FRD model
         freqs = sys.Frequency(index,:);
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Response = Data(ct).Response(:,:,index);
            Data(ct).Frequency = freqs;
         end
         sys.Data_ = Data;
      end
      
      function sys = fdel_(sys,ind2remove)
         % Delete portion of frequency vector in FRD model
         freqs = sys.Frequency;
         freqs(ind2remove) = [];
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Response(:,:,ind2remove) = [];
            Data(ct).Frequency = freqs;
         end
         sys.Data_ = Data;
      end
      
      function sys = chgunits_(sys,newUnits)
         % Change frequency units for FRD
         D = sys.Data_;
         nD = numel(D);
         if nD>0
            freqs = unitconv(D(1).Frequency,D(1).FreqUnits,newUnits);
            for ct=1:nD
               D(ct).Frequency = freqs;
               D(ct).FreqUnits = newUnits;
            end
            sys.Data_ = D;
         end
      end
      
      function sys = frdfun_(sys,fhandle)
         % Applies scalar-valued function to response data
         D = sys.Data_;
         for ct=1:numel(D)
            D(ct) = fhandle(D(ct));
         end
         sys.Data_ = D;
      end
      
      function sysfn = fnorm_(sys,ntype)
         % Frequency-wise norm
         Data = sys.Data_;
         freqs = sys.Frequency;
         unit = sys.FrequencyUnit;
         nf = length(freqs);
         nrm = zeros([1 1 nf size(Data)]);
         for ct=1:numel(Data)
            D = Data(ct);
            if hasdelay(D)
               h = fresp(D,freqs,unit);  % because of delays
            else
               h = D.Response;
            end
            for ctf=1:nf
               nrm(1,1,ctf,ct) = norm(h(:,:,ctf),ntype);
            end
         end
         sysfn = frd(nrm,freqs,sys.Ts);
         sysfn.FrequencyUnit = unit;
      end
      
      % SINGLERATESYSTEM
      function sys = setTs_(sys,Ts)
         % Implementation of @SingleRateSystem:setTs_
         if Ts==-1
            ctrlMsgUtils.warning('Control:ltiobject:frdAmbiguousRate1')
         end            
         sys = setTs_@lti(sys,abs(Ts));
      end
      
   end
   
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% MODEL CHARACTERISTICS
      function sys = checkDataConsistency(sys)
         % Cross validation of system data. Extends @lti implementation
         sys = checkDataConsistency@lti(sys);         
         % Sampling time restriction
         if getTs_(sys)==-1
            % Ts=-1 is ambiguous for FRD models and may lead to
            % inconsistencies, e.g., if sys1.Ts=-1 and sys2.Ts=.1,
            % frd(sys1,w)+frd(sys2,w) and frd(sys1+sys2,w) differ
            % because the response in frd(sys1,w) is effectively
            % evaluated for Ts=1. Similar problems arise when
            % absorbing delays with Ts=-1. Force Ts=1 and warn.
            ctrlMsgUtils.warning('Control:ltiobject:frdAmbiguousRate1')
            sys = setTs_(sys,1);
         end
      end
      
      %% BINARY OPERATIONS
      function sys1 = mldivide_(sys1,sys2)
         % SYS1\SYS2 for two FRD systems.
         % NOTE: This function should not modify SYS.IOSize_
         [sys1,sys2] = matchArraySize(sys1,sys2);   % must come first
         [sys1,sys2] = matchAttributes(sys1,sys2);  % overloadable
         % Combine data
         Data1 = sys1.Data_;  Data2 = sys2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = mldivide(Data1(ct),Data2(ct));
         end
         sys1.Data_ = Data1;
      end

      function sys1 = mrdivide_(sys1,sys2)
         % SYS1/SYS2 for two FRD systems.
         % NOTE: This function should not modify SYS.IOSize_
         [sys1,sys2] = matchArraySize(sys1,sys2);   % must come first
         [sys1,sys2] = matchAttributes(sys1,sys2);  % overloadable
         % Combine data
         Data1 = sys1.Data_;  Data2 = sys2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = mrdivide(Data1(ct),Data2(ct));
         end
         sys1.Data_ = Data1;
      end
      
      function [sys1,sys2] = matchAttributes(sys1,sys2)
         % Enforces matching attributes in binary operations (e.g.,
         % sampling time, variable,...). This function can be overloaded
         % by subclasses.
         [sys1,sys2] = matchAttributes@lti(sys1,sys2);
         % Match frequency vectors and units
         [sys1,sys2] = matchFrequency(sys1,sys2);
      end

      %% INDEXING
      function sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask)
         % Data management in SYS(indices) = RHS.
         % ioSize is the new I/O size and ArrayMask tracks which
         % entries in the resulting system array have been reassigned.
         Data = sys.Data_;
         % Construct template initial value for new entries in system array
         if isempty(Data)
            D0 = ltipack.frddata(zeros([ioSize 0]),zeros(0,1),getTs_(sys));
         else
            freqs = Data(1).Frequency;
            D0 = ltipack.frddata(zeros([ioSize length(freqs)]),freqs,getTs_(sys));
            D0.FreqUnits = Data(1).FreqUnits;
         end
         D0.Delay.Input(:) = NaN;
         D0.Delay.Output(:) = NaN;
         % Update data
         sys.Data_ = indexasgn(Data,indices,rhs.Data_,ioSize,ArrayMask,D0);
      end
      
   end
   

   %% HIDDEN METHODS
   methods (Hidden)
      
      function TuningData = getPIDTuningData(G,C,NUP,index)
          %GETPIDTUNINGDATA returns ltipack.PIDTuningData object that
          %implements RRT tuning method.  By overloading this method PID
          %tuning API/GUI tools now supports designing for @frd class.
          % ensure the unit is rad/sec
          if nargin<=3
              Gdata = G.Data_;
          else
              Gdata = G.Data_(index);
          end
          if ischar(C)
              C = ltipack.getPIDfromType(C,getTs(G));
          end
          freqs = unitconv(Gdata.Frequency,Gdata.FreqUnits,'rad/s');
          Gdata.Frequency = freqs;
          Gdata.FreqUnits = 'rad/s';
          % obtain PIDTuningData
          TuningData = ltipack.PIDTuningData(Gdata,C,NUP);
      end
      
   end
   
   %% PROTECTED METHODS
   methods (Access=protected)
      
      function sys = subparen(sys,indices)
         % Implements sys(indices)
         % Trap ('freq',freq_ind) indices for frequency subgrid selection
         % (obsolete syntax)
         [indices,freqIndices] = getfreqindex(sys,indices);
         sys = subparen@DynamicSystem(sys,indices);
         if ~isempty(freqIndices)
            sys = fselect(sys,freqIndices{1});
         end
      end
      
      function sys = indexasgn(sys,indices,rhs)
         % Implements sys(indices)=rhs
         % Trap sys(...,'freq',freq_ind)=rhs (no longer supported)
         hw = ctrlMsgUtils.SuspendWarnings;  %#ok<NASGU>
         [indices,freqIndices] = getfreqindex(sys,indices);
         hw = [];  %#ok<NASGU>
         if isempty(freqIndices)
            sys = indexasgn@DynamicSystem(sys,indices,rhs);
         else
            ctrlMsgUtils.error('Control:ltiobject:subsasgn7')
         end
      end      
      
      function S = getSettings(sys)
         % Gets values of public LTI properties. Needed to support frd(R,w,LTI)
         S = getSettings@lti(sys);
         S.ioDelay = sys.ioDelay;
      end
      
   end
   
   
   %% STATIC METHODS
   methods(Static)
      sys = loadobj(s)
      
      function sys = make(D,IOSize)
         % Constructs FRD model from ltipack.frddata array
         sys = frd;
         sys.Data_ = D;
         if nargin>1
            sys.IOSize_ = IOSize;  % support for empty model arrays
         else
            sys.IOSize_ = iosize(D(1));
         end
      end
      
   end
   
end
