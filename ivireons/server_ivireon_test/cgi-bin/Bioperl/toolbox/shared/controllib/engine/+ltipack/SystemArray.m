classdef (Hidden) SystemArray < ltipack.ModelArray & DynamicSystem
   % System Array Interface (abstract class).
   %
   % @SystemArray implements the notion of system arrays as arrays of
   % LTIPACK data containers and translates operations on system arrays
   % as operations on the underlying LTIPACK arrays.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4.2.1 $  $Date: 2010/06/24 19:42:59 $
      
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access = protected)
      
      %% MODEL CHARACTERISTICS
      function boo = isstatic_(sys)
         % Checks if system is static
         D = sys.Data_;
         nD = numel(D);
         if nD==1
            boo = isstatic(D);
         else
            boo = true;
            for ct=1:nD
               boo = boo && isstatic(D(ct));
               if ~boo, break, end
            end
         end
      end

      function ns = order_(sys)
         % Returns order of each array entry
         D = sys.Data_;
         nD = numel(D);
         if nD==1
            ns = order(D);
         else
            ns = zeros(size(D));
            for ct=1:numel(D)
               ns(ct) = order(D(ct));
            end
         end
      end
      
      function boo = hasdelay_(sys)
         % Checks for delays
         D = sys.Data_;
         nD = numel(D);
         if nD==1
            boo = hasdelay(D);
         else
            boo = false;
            for ct=1:nD
               if hasdelay(D(ct))
                  boo = true;    break
               end
            end
         end
      end
      
      function boo = hasInternalDelay_(sys)
         % Checks for internal delays
         D = sys.Data_;
         nD = numel(D);
         if nD==1
            boo = hasInternalDelay(D);
         else
            boo = false;
            for ct=1:nD
               if hasInternalDelay(D(ct));
                  boo = true;    break
               end
            end
         end
      end
      
      function boo = isstable_(sys)
         % Checks stability
         D = sys.Data_;
         boo = false(size(D));
         for ct=1:numel(D)
            sflag = isstable(D(ct));
            if isnan(sflag)
               ctrlMsgUtils.error('Control:analysis:isstable1')
            else
               boo(ct) = (sflag==1);
            end
         end
      end
      
      function [boo,sys] = isproper_(sys,varargin)
         % Checks properness
         D = sys.Data_;
         nD = numel(D);
         if nD==1
            [boo,sys.Data_] = isproper(D,varargin{:});
         else
            if nargout>1
               ctrlMsgUtils.error('Control:analysis:isproper1');
            end
            boo = true;
            for ct=1:nD
               boo = boo && isproper(D(ct));
               if ~boo, break, end
            end
         end
      end
      
      function [a,b,c,d,Ts] = ssdata_(sys,varargin)
         % Quick access to explicit state-space data
         % Select single model
         Data = localSelectSingleModel(sys.Data_,varargin);
         % Convert to state-space and get data
         Data = ss(Data);
         [a,b,c,d] = getABCD(Data);
         Ts = Data.Ts;
      end
         
      function [a,b,c,d,e,Ts] = dssdata_(sys,varargin)
         % Quick access to descriptor state-space data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = ss(Data);
         [a,b,c,d,e] = getABCDE(Data);
         Ts = Data.Ts;
      end      
      
      function [num,den,Ts] = tfdata_(sys,varargin)
         % Quick access to transfer function data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = tf(Data);
         num = Data.num;  den = Data.den;  Ts = Data.Ts;
      end      
      
      function [z,p,k,Ts] = zpkdata_(sys,varargin)
         % Quick access to ZPK data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = zpk(Data);
         z = Data.z;  p = Data.p;  k = Data.k;   Ts = Data.Ts;
      end
      
      function [resp,freq,Ts] = frdata_(sys,varargin)
         % Quick access to FRD data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = frd(Data,sys.Frequency,sys.FrequencyUnit);
         resp = Data.Response;  freq = Data.Frequency;  Ts = Data.Ts;
      end
      
      function [Kp,Ki,Kd,Tf,Ts] = piddata_(sys,varargin)
         % Quick access to PID data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = pid(Data);
         Kp=Data.Kp; Ki=Data.Ki; Kd=Data.Kd; Tf=Data.Tf; Ts=Data.Ts;
      end
      
      function [Kp,Ti,Td,N,Ts] = pidstddata_(sys,varargin)
         % Quick access to PID data
         Data = localSelectSingleModel(sys.Data_,varargin);
         Data = pidstd(Data);
         Kp=Data.Kp; Ti=Data.Ti; Td=Data.Td; N=Data.N; Ts=Data.Ts;
      end
      
      function sys = checkComputability(sys,ResponseType,varargin)
         % Checks if specified response can be computed for SYS
         % Hide warnings, e.g., from ISPROPER
         hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
         D = sys.Data_;
         for ct=1:numel(D)
            D(ct) = utCheckComputability(D(ct),ResponseType,varargin{:});
         end
         sys.Data_ = D;
      end
      
      %% CONVERSIONS
      function sysOut = ss_(sys,optflag)
         % Converts to state-space.
         % Note: @DynamicSystem metadata is not transferred!
         Data = sys.Data_;
         ssData = ltipack.ssdata.array(size(Data));
         SingularFlag = false;
         for ct=1:numel(Data)
            [ssData(ct),sflag] = ss(Data(ct));
            SingularFlag = SingularFlag || sflag;
         end
         % Flag singular algebraic loops in LFT models
         if SingularFlag
            ctrlMsgUtils.warning('Control:lftmodel:SingularAlgebraicLoop','SS')
         end
         % Handle "minimal" and "explicit" flags
         if nargin>1
            switch optflag
               case 'explicit'
                  % Explicit realization
                  for ct=1:numel(Data)
                     [isp,ssData(ct)] = isproper(ssData(ct),'explicit');
                     if ~isp
                        ctrlMsgUtils.error('Control:transformation:ss')
                     end
                  end
               case 'minimal'
                  % Minimal realization
                  hw = ctrlMsgUtils.SuspendWarnings;
                  for ct=1:numel(Data)
                     ssData(ct) = minreal(ssData(ct),sqrt(eps));
                  end
                  delete(hw)
            end
         end
         sysOut = ss.make(ssData,sys.IOSize_);
      end
      
      function sysOut = tf_(sys)
         % Converts to transfer function
         Data = sys.Data_;
         tfData = ltipack.tfdata.array(size(Data));
         for ct=1:numel(Data)
            tfData(ct) = tf(Data(ct));
         end
         sysOut = tf.make(tfData,sys.IOSize_);
      end
      
      function sysOut = zpk_(sys)
         % Converts to zero-pole-gain form
         Data = sys.Data_;
         zpkData = ltipack.zpkdata.array(size(Data));
         for ct=1:numel(Data)
            zpkData(ct) = zpk(Data(ct));
         end
         sysOut = zpk.make(zpkData,sys.IOSize_);
      end
      
      function sysOut = frd_(sys,freq,unit)
         % Converts to FRD
         Data = sys.Data_;
         frData = ltipack.frddata.array(size(Data));
         for ct=1:numel(Data)
            frData(ct) = frd(Data(ct),freq,unit);
         end
         sysOut = frd.make(frData,sys.IOSize_);
      end
      
      function sysOut = pid_(sys,Options)
         % Convert data
         Data = sys.Data_;
         pidData = ltipack.piddataP.array(size(Data));
         for ct=1:numel(Data)
            pidData(ct) = pid(Data(ct),Options);
         end
         sysOut = pid.make(pidData,sys.IOSize_);
      end
      
      function sysOut = pidstd_(sys,Options)
         % Convert data
         Data = sys.Data_;
         pidData = ltipack.piddataS.array(size(Data));
         for ct=1:numel(Data)
            pidData(ct) = pidstd(Data(ct),Options);
         end
         sysOut = pidstd.make(pidData,sys.IOSize_);
      end
      
      function sysOut = genss_(sys)
         % Converts to @genss
         Data = sys.Data_;
         lftData = ltipack.lftdataSS.array(size(Data));
         for ct=1:numel(Data)
            lftData(ct) = genss(Data(ct));
         end
         sysOut = genss.make(lftData,sys.IOSize_);
      end
      
      function sysOut = genfrd_(sys,freq,unit)
         % Converts to @genfrd
         Data = sys.Data_;
         lftData = ltipack.lftdataFRD.array(size(Data));
         for ct=1:numel(Data)
            lftData(ct) = genfrd(Data(ct),freq,unit);
         end
         sysOut = genfrd.make(lftData,sys.IOSize_);
      end
      
      function sysOut = uss_(sys)
         % Converts to @uss
         Data = sys.Data_;
         lftData = ltipack.lftdataSS.array(size(Data));
         for ct=1:numel(Data)
            D = genss(Data(ct));
            lftData(ct) = foldBlocks(D,~logicalfun(@isUncertain,D.Blocks));
         end
         sysOut = uss.make(lftData,sys.IOSize_);
      end
      
      function sysOut = ufrd_(sys,freq,unit)
         % Converts to @ufrd
         Data = sys.Data_;
         lftData = ltipack.lftdataFRD.array(size(Data));
         for ct=1:numel(Data)
            D = genfrd(Data(ct),freq,unit);
            lftData(ct) = foldBlocks(D,~logicalfun(@isUncertain,D.Blocks));
         end
         sysOut = ufrd.make(lftData,sys.IOSize_);
      end

      function sysOut = idss_(sys)
         % Converts to @idss
         Data = sys.Data_;
         sysOut = idss.make(idss(Data),sys.IOSize_);
      end
      
      function sysOut = idpoly_(sys)
         % Converts to @idpoly
         Data = sys.Data_;
         sysOut = idpoly.make(idpoly(Data),sys.IOSize_);
      end

      %% BINARY OPERATIONS
      function [sys,SingularFlag] = connect_(sys,k,feedin,feedout,iu,iy)
         % Generic implementation of CONNECT(SYS,K,...) for two systems
         % of the same type. Can be overloaded by subclasses, e.g., IDMODELs
         % would want to first convert SYS to @ss
         SingularFlag = false;
         Data = sys.Data_;
         for ct=1:numel(Data)
            [Data(ct),warnflag] = connect(Data(ct),k,feedin,feedout,iu,iy);
            SingularFlag = SingularFlag || warnflag;
         end
         sys.Data_ = Data;
      end
      
      %-----------------------------------------------------------
      function sys1 = times_(sys1,sys2,ScalarFlags)
         % Generic implementation of SYS1.*SYS2 for two systems
         % of the same type. Can be overloaded by subclasses.
         % NOTE: This function should not modify SYS.IOSize_
         [sys1,sys2] = matchArraySize(sys1,sys2);   % must come first
         [sys1,sys2] = matchAttributes(sys1,sys2);  % overloadable
         % Combine data
         Data1 = sys1.Data_;  Data2 = sys2.Data_;
         for ct=1:numel(Data1)
            Data1(ct) = times(Data1(ct),Data2(ct),ScalarFlags);
         end
         sys1.Data_ = Data1;
      end
      
      %% ANALYSIS 
      function [g,dceq] = dcgain_(sys)
         % Computes DC gain
         % RE: DCEQ(i,j) = m  if  Hij(s) ~ s^m as s->0
         %     For state-space models, m is set to 0 when g=0.
         %     Used in BODERESP to determine true phase at s=0
         s = size(sys);
         g = zeros(s);
         Data = sys.Data_;
         if nargout>1
            dceq = struct('factor',cell([s(3:end) 1 1]),'power',[]);
            for ct=1:numel(Data)
               [g(:,:,ct),dceq(ct).factor,dceq(ct).power] = dcgain(Data(ct));
            end
         else
            for ct=1:numel(Data)
               g(:,:,ct) = dcgain(Data(ct));
            end
         end
      end
      
      function fresp = evalfr_(sys,s)
         % Computes frequency response at complex frequency
         fresp = zeros(size(sys));
         Data = sys.Data_;
         for ct=1:numel(Data)
            fresp(:,:,ct) = evalfr(Data(ct),s);
         end
      end
      
      function [h,SingularWarn] = freqresp_(sys,w)
         % Computes frequency response over frequency grid
         sizes = size(sys);
         h = zeros([sizes(1:2) , length(w) , sizes(3:end)]);
         SingularWarn = false;
         Data = sys.Data_;
         for ct=1:numel(Data)
            [h(:,:,:,ct),InfResp] = fresp(Data(ct),w);
            SingularWarn = SingularWarn || InfResp;
         end
      end
      
      function s = allmargin_(sys)
         % All stability margins
         D = sys.Data_;
         s = struct(...
            'GainMargin',cell(size(D)),...
            'GMFrequency',[],...
            'PhaseMargin',[],...
            'PMFrequency',[],...
            'DelayMargin',[],...
            'DMFrequency',[],...
            'Stable',[]);
         for ct=1:numel(D)
            s(ct) = allmargin(D(ct));
         end
      end
      
      function fb = bandwidth_(sys,drop)
         % SISO bandwidth
         D = sys.Data_;
         fb = zeros(size(D));
         for ct=1:numel(D)
            fb(ct) = bandwidth(D(ct),drop);
         end
      end
      
      function n = normh2_(sys)
         % H2 norm
         D = sys.Data_;
         n = zeros(size(D));
         for ct=1:numel(D)
            n(ct) = normh2(D(ct));
         end
      end
      
      function [n,fpeak] = norminf_(sys,tol)
         % Linf norm
         D = sys.Data_;
         n = zeros(size(D));
         fpeak = zeros(size(D));
         for ct=1:numel(D)
            [n(ct),fpeak(ct)] = norminf(D(ct),tol);
         end
      end
      
      function p = pole_(sys,varargin)
         % Poles of single system (SYS or SYS(J1,J2,...))
         D = localSelectSingleModel(sys.Data_,varargin);
         p = pole(D);
      end
      
      function [z,g] = zero_(sys,varargin)
         % Zeros of single system (SYS or SYS(J1,J2,...))
         D = localSelectSingleModel(sys.Data_,varargin);
         [z,g] = zero(D);
      end
      
      %% TRANSFORMATIONS
      function sys = repsys_(sys,s)
         % Replicate along I/O dimensions
         sio = s(1:2);
         if any(sio~=1)
            % Data
            Data = sys.Data_;
            for ct=1:numel(Data)
               Data(ct) = iorep(Data(ct),sio);
            end
            sys.Data_ = Data;
         end
         % Replicate along array dimensions
         if length(s)>2
            % First replicate along array dimensions
            sys.Data_ = repmat(sys.Data_,[s(3:end) 1]);
         end
      end
                  
      function [sys,gic] = c2d_(sys,Ts,options)
         % C2D discretization
         if nargout>1
            [sys.Data_,gic] = c2d(sys.Data_,Ts,options);
         else
            Data = sys.Data_;
            for ct=1:numel(Data)
               Data(ct) = c2d(Data(ct),Ts,options);
            end
            sys.Data_ = Data;
         end
      end
      
      function sys = d2c_(sys,options)
         % D2C transformation
         Data = sys.Data_;
         for ct=1:numel(Data)
            if Data(ct).Ts>0
               % Skip static gain with Ts=0
               Data(ct) = d2c(Data(ct),options);
            end
         end
         sys.Data_ = Data;
      end
      
      function sys = d2d_(sys,Ts,options)
         % D2D resampling
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct) = d2d(Data(ct),Ts,options);
         end
         sys.Data_ = Data;
      end
      
      function sys = upsample_(sys,L)
         % Upsampling
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct) = upsample(Data(ct),L);
         end
         sys.Data_ = Data;
      end
      
      function [sys,icmap] = delay2z_(sys)
         % Maps delays to poles in discrete time
         Data = sys.Data_;
         try
            for ct=1:numel(Data)
               [Data(ct),icmap] = elimDelay(Data(ct));
            end
         catch E
            error(E.identifier,strrep(E.message,'elimDelay','delay2z'))
         end
         sys.Data_ = Data;
      end
      
      function sys = pade_(sys,Ni,No,Nf)
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct) = pade(Data(ct),Ni,No,Nf);
         end
         sys.Data_ = Data;
      end
         
      %---------------------
      function [H,H0,varargout] = modsep_(G,N,varargin)
         H = G;   H0 = G;
         [H.Data_,H0.Data_,varargout{1:nargout-2}] = modsep(G.Data_,N,varargin{:});
      end
      
      function [G1,G2,varargout] = stabsep_(G,Options)
         G1 = G;   G2 = G;
         [G1.Data_,G2.Data_,varargout{1:nargout-2}] = stabsep(G.Data_,Options);
      end
   
      %---------------------
      function [sys,varargout] = minreal_(sys,tol,dispflag)
         % Note: DISPFLAG=true only for single state-space models
         no = nargout-1;
         Data = sys.Data_;
         if dispflag
            Nx0 = order(Data);
         end
         for ct=1:numel(Data)
            [Data(ct),varargout{1:no}] = minreal(Data(ct),tol);
         end
         sys.Data_ = Data;
         if dispflag
            % Print number of eliminated states 
            Nrm = Nx0-order(Data);
            if Nrm>0
               if Nrm==1,
                  xchar = 'state';
               else
                  xchar = 'states';
               end
               fprintf('%d %s removed.\n',Nrm,xchar)
            end
         end
      end
      
      function [g,varargout] = hsvd_(sys,Options)
         % Hankel singular values
         [g,varargout{1:nargout-1}] = hsvd(sys.Data_,Options);
      end
      
      function [sys,g,varargout] = balreal_(sys,Options)
         % Balanced realization
         [sys.Data_,g,varargout{1:nargout-2}] = balreal(sys.Data_,Options);
      end
      
      function sys = balred_(sys,orders,BalData,Options)
         % Implementation of BALRED for SS models
         Dss = sys.Data_;
         
         % Compute balancing data if not supplied
         if isempty(BalData)
            try
               [~,BalData] = hsvd(Dss,Options);
            catch E
               error(E.identifier,strrep(E.message,'hsvd','balred'))
            end
         end

         % Stable, nonzero HSV
         nns = BalData.Split(1);  % # unstable modes
         ns = BalData.Split(2);   % # stable modes
         g = BalData.g;
         nx = length(g);
         g = g(nns+1:nns+ns,:);
         nnz = sum(g >= BalData.ZeroTol);  % # stable, nonzero HSV

         % Validate orders
         if any(orders>nx)
            ctrlMsgUtils.error('Control:transformation:balred3',nx)
         end
         orders = orders-nns;  % account for modes eliminated by SMINREAL
         if any(orders<0)
            ctrlMsgUtils.warning('Control:transformation:ModelReductionMinOrder',nns,nns)
         elseif any(orders>nnz)
            ctrlMsgUtils.warning('Control:transformation:ModelReductionMaxOrder',nns+nnz)
         end
         orders = max(0,min(orders,nnz)); % effective orders for stable part
         
         % Reduce
         nout = length(orders);
         Dr = repmat(Dss,nout,1);
         hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
         MatchDC = strcmp(Options.StateElimMethod,'MatchDC');
         for ct=1:nout
            Dr(ct) = balred(Dss,orders(ct),BalData,MatchDC);
         end
         sys.Data_ = Dr;
      end
      
      %-----------------------
      function sys = interp_(sys,w)
         % FRD interpolation
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Response = fresp(Data(ct),w,Data(ct).FreqUnits);
            Data(ct).Frequency = w;
         end
         sys.Data_ = Data;
      end
      
      %% DESIGN
      function [C Info Merit] = pidtune_(G,C,Options)
        % get array size
        ArraySize = getArraySize(G);
        nsys = prod(ArraySize);
        % loop through each linear system and return @pid or @pidstd
        if nsys==1
            % compute PID
            [C.Data_ info] = tune(getPIDTuningData(G,C,Options.NumUnstablePoles),Options);
            % additional loop information
            Info.Stable = info.Stable;
            Info.CrossoverFrequency = info.wc;
            Info.PhaseMargin = info.PM;
            Merit = info.F;
        else
            Dc = repmat(C.Data_(1),ArraySize);
            Info = repmat(struct('Stable',true,'CrossoverFrequency',0,'PhaseMargin',0),ArraySize);
            Merit = zeros(ArraySize);
            for ct=1:nsys
                % compute PID
                [Dc(ct) info] = tune(getPIDTuningData(G,C,Options.NumUnstablePoles,ct),Options);
                % additional loop information
                Info(ct).Stable = info.Stable;
                Info(ct).CrossoverFrequency = info.wc;
                Info(ct).PhaseMargin = info.PM;
                Merit(ct) = info.F;
            end
            C.Data_ = Dc;
        end
      end
      
      
      %% STATE-SPACE MODELS
      function [sys,xkeep] = sminreal_(sys)
         Data = sys.Data_;
         for ct=1:numel(Data)
            [Data(ct),xkeep] = sminreal(Data(ct));
         end
         sys.Data_ = Data;
      end
      
      function sys = augstate_(sys)
         % Augment outputs by states
         D = sys.Data_;
         nx = order(D(1));
         for ct=1:numel(D)
            if order(D(ct))~=nx
               ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','augstate')
            end
            D(ct) = augstate(D(ct));
         end
         sys.Data_ = D;
      end
      
      function sys = ss2ss_(sys,T,l,u,p)
         % Applies state transformation T
         D = sys.Data_;
         Nx = order(D(1));
         if Nx~=size(T,1),
            ctrlMsgUtils.error('Control:transformation:ss2ss1')
         end
         for ct=1:numel(D),
            if order(D(ct))~=Nx
               ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','ss2ss')
            end
            [D(ct),isSingular] = ss2ss(D(ct),T,l,u,p);
            if isSingular
               ctrlMsgUtils.error('Control:transformation:ss2ss2')
            end
         end
         sys.Data_ = D;
      end
      
      function sys = xperm_(sys,perm)
         % Permute state vector
         Data = sys.Data_;
         for ct=1:numel(Data)
            D = Data(ct);
            D.a = D.a(perm,perm);
            D.b = D.b(perm,:);
            D.c = D.c(:,perm);
            if ~isempty(D.e)
               D.e = D.e(perm,perm);
            end
            if ~isempty(D.StateName)
               D.StateName = D.StateName(perm);
            end
            Data(ct) = D;
         end
         sys.Data_ = Data;
      end
      
      function W = gram_(sys,type)
         % Gramian computation
         D = sys.Data_;
         if isempty(D)
            Nx = 0;
         else
            Nx = order(D(1));
         end
         W = zeros([Nx Nx size(D)]);
         FactorFlag = any(type=='f');
         for ct=1:numel(D)
            if ct>1 && order(D(ct))~=Nx
               ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','gram')
            end
            R = gram(D(ct),type);
            if FactorFlag
               W(:,:,ct) = R;
            else
               W(:,:,ct) = R' * R;
            end
         end
      end
      
      function sys = modred_(sys,method,elim)
         % State elimination or reduction
         sys.Data_ = modred(sys.Data_,method,elim);
      end
      
      function [sys,varargout] = canon_(sys,Type,varargin)
         % Canonical realization
         [sys.Data_,varargout{1:nargout-1}] = canon(sys.Data_,Type,varargin{:});
      end
      
      function [p,q] = covar_(sys,w,rw)
         % Output and state covariance
         [Ny,~] = iosize(sys);
         Data = sys.Data_;
         p = zeros([Ny Ny size(Data)]);
         if nargout>1
            if isempty(Data)
               Nx = 0;
            else
               Nx = order(Data(1));
            end
            q = zeros([Nx Nx size(Data)]);
            for ct=1:numel(Data)
               [p(:,:,ct),q(:,:,ct)] = covar(Data(ct),w,rw);
            end
         else
            for ct=1:numel(Data)
               p(:,:,ct) = covar(Data(ct),w,rw);
            end
         end
      end
      
   end
   
   %% STATIC METHODS
   methods (Static)
      
      function Sinfo = getStateInfo(Data,Prop)
         % Helper for get.StateName and get.StateUnit.
         % Returns state names/units when the state dimension is uniform.
         % If the state names or units clash, returns cell of empty strings.
         if isempty(Data)
            Sinfo = cell(0,1);
         else
            S = getStateInfo(Data(1));
            nx = S.nx;
            Sinfo = S.(Prop);
            for ct = 2:numel(Data)
               S = getStateInfo(Data(ct));
               if S.nx~=nx
                  switch Prop
                     case 'StateName'
                        ctrlMsgUtils.error('Control:ltiobject:get2')
                     case 'StateUnit'
                        ctrlMsgUtils.error('Control:ltiobject:get6')
                  end
               end
               [Sinfo, clash] = ltipack.mrgname(Sinfo,S.(Prop));
               if clash
                  Sinfo = [];  break;
               end
            end
            if isempty(Sinfo)
               Sinfo = repmat({''},nx,1);
            end
         end
      end
      
   end
   
   
end

%----------------------------------

function Data = localSelectSingleModel(Data,Indices)
% Single model selection in model array
if nargin>1
   try
      Data = Data(Indices{:});
   catch %#ok<CTCH>
      ctrlMsgUtils.error('Control:ltiobject:access2')
   end
end
if ~isscalar(Data)
   ctrlMsgUtils.error('Control:ltiobject:access1')
end
end
