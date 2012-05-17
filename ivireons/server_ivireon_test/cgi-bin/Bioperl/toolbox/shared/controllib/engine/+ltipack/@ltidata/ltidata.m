classdef (Hidden = true) ltidata 
   % Class definition for @ltidata

   %   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
   %   $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:13 $
   properties
      Delay  % delay structure
      Ts     % sampling time
      Tags   % tags (struct)
   end

   % Methods
   methods
      
      function Value = get.Tags(D)
         Value = D.Tags;
         if isempty(Value)
            Value = struct;
         end
      end

      function Dlft = genss(D)
         % Conversion to ltipack.lftdataSS
         Dlft = ltipack.lftdataSS(ss(D),ltipack.LFTBlockWrapper.emptyBlockList());
      end
      
      function Dlft = genfrd(D,freqs,units)
         % Converts to ltipack.lftdataFRD
         Dlft = ltipack.lftdataFRD(frd(D,freqs,units),ltipack.LFTBlockWrapper.emptyBlockList());
      end

      function [D,Tdio] = elimDelay(D,id,od,iod)
         % Collects I/O delays to be mapped to 1/z and subtract
         % them from delay structure.
         [ny,nu] = size(D.Delay.IO);
         if nargin==1
            % Map all delays
            Tdio = getIODelay(D,'total');
            % Clear delays
            D.Delay.Input = zeros(nu,1);
            D.Delay.Output = zeros(ny,1);
            D.Delay.IO = zeros(ny,nu);
         else
            Tdio = zeros(ny,nu);
            if any(id(:))
               Tdio = Tdio + id(:,ones(1,ny))';
               D.Delay.Input = D.Delay.Input - id;
            end
            if any(od(:))
               Tdio = Tdio + od(:,ones(1,nu));
               D.Delay.Output = D.Delay.Output - od;
            end
            if any(iod(:))
               Tdio = Tdio + iod;
               D.Delay.IO = D.Delay.IO - iod;
            end
         end
      end % elimDelay
      
      %-------------------------------------------
      function D = checkDelay(D)
         % Checks validity and consistency of delay data.
         % Ny and Nu are the number of outputs and inputs, respectively.
         % RE: Performs only size checks. Type checking is performed
         % by top-level functions for optimal performance in model array case
         % Note: Resizing of D is not allowed with internal delays so their 
         % is no risk of ending up with Nu-nfd<0 or Ny-nfd<0
         Delay = D.Delay;
         [Ny,Nu] = iosize(D);

         % Check InputDelay data
         InputDelay = Delay.Input;
         if length(InputDelay)~=Nu
            if ~any(InputDelay),
               % All zero delays: ignore initial size and set to proper size
               % (needed when a model with zero delays is resized using SET)
               Delay.Input = zeros(Nu,1);
            elseif Nu~=1 && isscalar(InputDelay)
               % Scalar expansion
               Delay.Input = InputDelay(ones(Nu,1),1);
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties01')
            end
         end

         % Check OutputDelay data
         OutputDelay = Delay.Output;
         if length(OutputDelay)~=Ny
            if ~any(OutputDelay),
               Delay.Output = zeros(Ny,1);
            elseif Ny~=1 && isscalar(OutputDelay)
               Delay.Output = OutputDelay(ones(Ny,1),1);
            else
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties02')
            end
         end

         % Check I/O delay data if relevant
         if isfield(Delay,'IO')
            ioDelay = Delay.IO;
            if ~isequal(size(ioDelay),[Ny Nu])
               if ~any(ioDelay(:))
                  Delay.IO = zeros(Ny,Nu);
               elseif (Ny~=1 || Nu~=1) && isscalar(ioDelay)
                  Delay.IO = ioDelay(ones(Ny,1),ones(Nu,1));
               else
                  ctrlMsgUtils.error('Control:ltiobject:ltiProperties03')
               end
            end
         end
         
         % Check delay values for discrete models
         if D.Ts~=0
            rtolint = 1e3*eps;
            % Discrete-time case: all delays should be integer
            id = round(Delay.Input);
            if any(abs(Delay.Input-id)>rtolint*id),
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties04','InputDelay')
            end
            Delay.Input = id;

            od = round(Delay.Output);
            if any(abs(Delay.Output-od)>rtolint*od),
               ctrlMsgUtils.error('Control:ltiobject:ltiProperties04','OutputDelay')
            end
            Delay.Output = od;

            if isfield(Delay,'IO')
               iod = round(Delay.IO);
               NotInt = (abs(Delay.IO-iod)>rtolint*iod);
               if any(NotInt(:)),
                  ctrlMsgUtils.error('Control:ltiobject:ltiProperties04','ioDelay')
               end
               Delay.IO = iod;
            end

            if isfield(Delay,'Internal')
               intd = round(Delay.Internal);
               if any(abs(Delay.Internal-intd)>rtolint*intd),
                  ctrlMsgUtils.error('Control:ltiobject:ltiProperties04','InternalDelay')
               end
               Delay.Internal = intd;
            end
         end
         
         D.Delay = Delay;
      end % checkDelay
      
   end


   % Protected methods (delay management)
   methods(Access=protected)

      %-------------------------------------------

      function MaxDelay = getMaxDelay(D)
         % Estimates max I/O delay.
         MaxDelay = 0;
         for ct=1:length(D)
            Delay = D(ct).Delay; %#ok<*PROP>
            iod = bsxfun(@plus,bsxfun(@plus,Delay.IO,Delay.Output),Delay.Input.');
            MaxDelay = max([MaxDelay;iod(:)]);
         end
      end

      %----------------------------------------------

      function Delay = appendDelay(D1,D2)
         % Delay management in APPEND
         Delay = D1.Delay;  Delay2 = D2.Delay;
         Delay.Input = [Delay.Input ; Delay2.Input];
         Delay.Output = [Delay.Output ; Delay2.Output];
         if isfield(Delay,'IO')
            Delay.IO = blkdiag(Delay.IO,Delay2.IO);
         else
            Delay.Internal = [Delay.Internal ; Delay2.Internal];
         end
      end

      %-------------------------------------------

      function [Delay,D1,D2] = catDelay(D1,D2,dim)
         % Delay management in I/O concatenation
         if dim==1
            % Skip delay folding if D1 or D2 empty
            if isempty(D1.Delay.Output)
               Delay = D2.Delay;
            elseif isempty(D2.Delay.Output)
               Delay = D1.Delay;
            else
               if ~localIsEqual(D1.Delay.Input,D2.Delay.Input)
                  % Absorb mismatched input delays into internal delays
                  cid = min(D1.Delay.Input,D2.Delay.Input);
                  D1 = utFoldDelay(D1,D1.Delay.Input-cid,[]);
                  D2 = utFoldDelay(D2,D2.Delay.Input-cid,[]);
               end
               Delay = D1.Delay;
               Delay.Output = [D1.Delay.Output ; D2.Delay.Output];
               if isfield(Delay,'IO')
                  Delay.IO = [D1.Delay.IO ; D2.Delay.IO];
               else
                  Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
               end
            end
         elseif dim==2
            if isempty(D1.Delay.Input)
               Delay = D2.Delay;
            elseif isempty(D2.Delay.Input)
               Delay = D1.Delay;
            else
               if ~localIsEqual(D1.Delay.Output,D2.Delay.Output)
                  % Absorb mismatched output delays into internal delays
                  cod = min(D1.Delay.Output,D2.Delay.Output);
                  D1 = utFoldDelay(D1,[],D1.Delay.Output-cod);
                  D2 = utFoldDelay(D2,[],D2.Delay.Output-cod);
               end
               Delay = D1.Delay;
               Delay.Input = [D1.Delay.Input ; D2.Delay.Input];
               if isfield(Delay,'IO')
                  Delay.IO = [D1.Delay.IO , D2.Delay.IO];
               else
                  Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
               end
            end
         end
      end % catDelay

      %-------------------------------------------

      function [Delay,D1,D2,ElimFlag] = mtimesDelay(D1,D2,ScalarFlag)
         % Delay management for D=D1*D2
         % RE: Delays of D1,D2 are not updated (not looked up again)
         ElimFlag = false;
         Delay = D1.Delay;
         if ScalarFlag(1) || (~ScalarFlag(2) && utIsIOScaling(D1))
            % Scalar factor D1 or output scaling D1 with nonscalar D2: external delays
            % commute with D1 and can be pushed to the result's outputs
            % RE: Give priority to scalar factor, e.g., in diag([1 0 1]) * tf(1,[1 0])
            Delay.Input = D2.Delay.Input;
            if isfield(Delay,'IO')
               Delay.Output = diag(getIODelay(D1,'total')) + D2.Delay.Output;
               Delay.IO = D2.Delay.IO;
            else
               Delay.Output = D1.Delay.Output + D1.Delay.Input + D2.Delay.Output;
               Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
            end

         elseif ScalarFlag(2) || utIsIOScaling(D2)
            % Scalar factor D2 or input scaling D2 with nonscalar D1: external delays
            % commute with D2 and can be pushed to the result's inputs
            Delay.Output = D1.Delay.Output;
            if isfield(Delay,'IO')
               Delay.Input = diag(getIODelay(D2,'total')) + D1.Delay.Input;
               Delay.IO = D1.Delay.IO;
            else
               Delay.Input = D2.Delay.Input + D2.Delay.Output + D1.Delay.Input;
               Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
            end

         else
            % Full-size factors
            if isfield(Delay,'IO')
               % Transport delays modeled as I/O delays
               % Absorb external delays along inner dimension into I/O delay matrix
               [ny,~] = size(D1.Delay.IO);
               [nin,nu] = size(D2.Delay.IO);
               Dm1 = D1.Delay.IO + repmat(D1.Delay.Input.',[ny 1]);
               Dm2 = D2.Delay.IO + repmat(D2.Delay.Output,[1 nu]);
               
               % D1*D2 is representable as a system with I/O delays if DxDy([Dm1;-Dm2'])=0
               Dm12 = [Dm1;-Dm2'];
               DxDy = diff(diff(Dm12,1,1),1,2);
               if nin==0,
                  Dm = zeros(ny,nu);
               elseif all(abs(DxDy(:))<=1e3*eps*max(Dm12(:))),
                  % Product is representable as LTI model with delays
                  Dm = Dm1(:,ones(1,nu))+Dm2(ones(1,ny),:);
               else
                  % Extract parts of Dm1,Dm2 satisfying DxDy([Dm1;-Dm2'])=0
                  % and try eliminating remaining delays
                  try
                     a = min(Dm1,[],2);
                     b = min(Dm2,[],1);
                     Dm = a(:,ones(1,nu)) + b(ones(1,ny),:);
                     D1 = elimDelay(D1,[],[],Dm1-a(:,ones(1,nin)));
                     D2 = elimDelay(D2,[],[],Dm2-b(ones(1,nin),:));
                     ElimFlag = true;
                  catch  %#ok<*CTCH>
                     ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
                  end
               end
               Delay.Input = D2.Delay.Input;
               Delay.Output = D1.Delay.Output;
               Delay.IO = Dm;
            else
               % Transport delays modeled as internal delays
               % Fold in input and output delays along inner dimension of product
               D2 = utFoldDelay(D2,[],D1.Delay.Input + D2.Delay.Output);
               Delay.Input = D2.Delay.Input;
               Delay.Output = D1.Delay.Output;
               Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
            end
         end
      end % mtimesDelay

      %-------------------------------------------

      function [Delay,D1,D2,ElimFlag] = plusDelay(D1,D2,Zero1,Zero2)
         % Delay management in D=D1+D2.
         % Note: Zero input or output channels and zero I/O pairs are neutral for delay
         %       matching purposes. This ensures, e.g., that APPEND(SYS1,0)+APPEND(0,SYS2)
         %       is the same as APPEND(SYS1,SYS2) (see PARALLEL) and that 0+tf(1,[1 2],'iod',1)
         %       does not throw an error. The ZERO1 and ZERO2 structs flag identically zero input 
         %       channels, output channels, and I/O pairs in D1 and D2.
         ElimFlag = false;
         if ~(isequal(D1.Delay.Input,D2.Delay.Input) && isequal(D1.Delay.Output,D2.Delay.Output))
            % Equalize input delays when the corresponding input channel is zero in D1 or D2
            D2.Delay.Input(Zero2.Input) = D1.Delay.Input(Zero2.Input);
            D1.Delay.Input(Zero1.Input) = D2.Delay.Input(Zero1.Input);
            % Equalize output delays when the corresponding output channel is zero in D1 or D2
            D2.Delay.Output(Zero2.Output) = D1.Delay.Output(Zero2.Output);
            D1.Delay.Output(Zero1.Output) = D2.Delay.Output(Zero1.Output);
            % Equalize remaining input and output delays by turning mismatched delays into 
            % internal delays or states
            cid = min(D1.Delay.Input,D2.Delay.Input);
            cod = min(D1.Delay.Output,D2.Delay.Output);
            D1 = utFoldDelay(D1,D1.Delay.Input-cid,D1.Delay.Output-cod);
            D2 = utFoldDelay(D2,D2.Delay.Input-cid,D2.Delay.Output-cod);
         end

         if isfield(D1.Delay,'IO')
            % Transport delays modeled as I/O delays
            % Equalize I/O delays when the corresponding I/O pair is zero in D1 or D2
            D2.Delay.IO(Zero2.IO) = D1.Delay.IO(Zero2.IO);
            D1.Delay.IO(Zero1.IO) = D2.Delay.IO(Zero1.IO);
            % Equalize remaining I/O delays
            iod1 = D1.Delay.IO;
            iod2 = D2.Delay.IO;
            if norm(iod1-iod2,1)>1e3*eps*(norm(iod1,1)+norm(iod2,1))
               % I/O delay mismatch: try eliminating unmatched delays (may error or warn)
               ElimFlag = true;
               ciod = min(iod1,iod2);
               try
                  D1 = elimDelay(D1,[],[],iod1-ciod);
                  D2 = elimDelay(D2,[],[],iod2-ciod);
               catch  %#ok<*CTCH>
                  ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
               end
            end
            Delay = D1.Delay;
         else
            % Transport delays modeled as internal delays
            Delay = D1.Delay;
            Delay.Internal = [D1.Delay.Internal ; D2.Delay.Internal];
         end
      end % plusDelay

      %-------------------------------------------

      function Delay = timesDelay(D1,D2)
         % Delay management for D=D1.*D2
         Delay1 = D1.Delay;
         Delay2 = D2.Delay;
         Delay = Delay1;
         Delay.Input = Delay1.Input + Delay2.Input;
         Delay.Output = Delay1.Output + Delay2.Output;
         Delay.IO = Delay1.IO + Delay2.IO;
      end

      %-------------------------------------------

      function Delay = transposeDelay(D)
         % Delay management in transpose ops
         Delay = D.Delay;
         if isfield(Delay,'IO')
            Delay.IO = Delay.IO';
         end
         id = Delay.Input;
         Delay.Input = Delay.Output;
         Delay.Output = id;
      end

      %-------------------------------------------

      function [D,rhs] = assignDelay(D,rowIndex,colIndex,rhs)
         % Delay management in D(rowIndex,colIndex) = rhs.
         % Restricted to models without internal delay support.
         [ny,nu] = iosize(D);
         Din = D.Delay.Input;  % tracks input delays to be kept
         Dout = D.Delay.Output;

         % Resolve NaN entries arising when growing I/O size
         idx = find(isnan(Din));
         if ~isempty(idx)
            [iasgn,~,ib] = intersect(idx,colIndex);
            Din(idx) = 0;
            Din(iasgn) = rhs.Delay.Input(min(ib,end));
            D.Delay.Input = Din;
         end

         idx = find(isnan(Dout));
         if ~isempty(idx)
            [iasgn,~,ib] = intersect(idx,rowIndex);
            Dout(idx) = 0;
            Dout(iasgn) = rhs.Delay.Output(min(ib,end));
            D.Delay.Output = Dout;
         end


         % Determine which input and output delays need to be folded
         if ~strcmp(rowIndex,':') && ~isequal(sort(rowIndex(:)),(1:ny)')
            % Partial reassignment of the rows
            % Enforce matching input delays along modified columns
            cid = min(Din(colIndex,:),rhs.Delay.Input);
            Din(colIndex,:) = cid;  % input delays to be kept
         else
            cid = rhs.Delay.Input;
         end

         if ~strcmp(colIndex,':') && ~isequal(sort(colIndex(:)),(1:nu)')
            % Partial reassignment of the columns
            % Enforce matching output delays along modified rows
            cod = min(Dout(rowIndex,:),rhs.Delay.Output);
            Dout(rowIndex,:) = cod;  % input delays to be kept
         else
            cod = rhs.Delay.Output;
         end

         % Fold delays in
         D = utFoldDelay(D,D.Delay.Input-Din,D.Delay.Output-Dout);
         rhs = utFoldDelay(rhs,rhs.Delay.Input-cid,rhs.Delay.Output-cod);

         % Perform assignment for delays
         D.Delay.IO(rowIndex,colIndex) = rhs.Delay.IO;
         D.Delay.Input(colIndex,:) = rhs.Delay.Input;
         D.Delay.Output(rowIndex,:) = rhs.Delay.Output;
      end

      %-------------------------------------------

      function D = elimZeroDelay(D)
         % Nothing to do in general
      end

      %-------------------------------------------

      function Delay = minimizeDelay(D)
         % Minimizes number of delays for state-space realization.
         %
         %   minimizeDelay minimizes the total number of internal delays
         %   in the state-space realization of TF or ZPK models by moving I/O
         %   delays into input and output delays.
         Delay = D.Delay;
         iod = Delay.IO;

         % Minimize delays
         if any(iod(:))
            [ny,nu] = size(iod);
            ZeroThreshold = 1e4*eps*max(iod(:));
            % Extract maximal input+output delay combination
            % and minimize total number of input+output delays
            if ny<nu,
               outdelays = min(iod,[],2);
               iod = iod - outdelays(:,ones(1,nu));
               indelays = min(iod,[],1);
               iod = iod - indelays(ones(1,ny),:);
            else
               indelays = min(iod,[],1);
               iod = iod - indelays(ones(1,ny),:);
               outdelays = min(iod,[],2);
               iod = iod - outdelays(:,ones(1,nu));
            end

            % Zero out small residual delays
            iod(iod<ZeroThreshold) = 0;
            indelays(indelays<ZeroThreshold) = 0;
            outdelays(outdelays<ZeroThreshold) = 0;

            % Update delay properties
            Delay.Input = Delay.Input + indelays(:);
            Delay.Output = Delay.Output + outdelays(:);
            Delay.IO = iod;
         end
      end % minimizeDelay

      %-------------------------------------------

      function [Delay,fiod] = discretizeDelay(Dc,Ts)
         % Extracts discrete delays for discretization purposes.
         %
         %   [DDELAY,FIOD] = DISCRETIZEDELAY(D,TS) extracts the
         %   discrete input, output, and I/O delays when
         %   discretizing D with sampling interval Ts.  The
         %   structure DDELAY contains the integer-valued discrete
         %   delays and FIOD is the matrix of residual normalized
         %   fractional delays (all lumped together as I/O delays).

         % Add static method to be included for compiler
         %#function ltipack.splitDelay

         % Compute discrete input and output delays
         Delay = Dc.Delay;
         [Delay.Input,fid] = ltipack.splitDelay(Delay.Input,Ts);
         [Delay.Output,fod] = ltipack.splitDelay(Delay.Output,Ts);

         % Lump residual fractional delays into continuous I/O delays and
         % decompose I/O delays
         [ny,nu] = size(Delay.IO);
         niod = Delay.IO/Ts + fod(:,ones(1,nu)) + fid(:,ones(1,ny)).'; % normalized I/O delays
         [Delay.IO,fiod] = ltipack.splitDelay(niod,1);

      end

      %----------------------------------------------

      function h = getDelayResp(D,H,s)
         % Evaluates delay contribution to compute overall
         % frequency response. Note:
         % 1) H is the frequency response of H(s) such that
         %    h(s,tau) = LFT(H(s),exp(s*tau))
         % 2) s is the vector of complex numbers at which the
         %    response is evaluated
         [rs,cs,ls] = size(H);

         % Compute equivalent continuous-time frequencies
         if D.Ts~=0
            isZero = (s==0);
            s(isZero) = -Inf;
            idx = find(~isZero);
            s(idx) = log(s(idx));
         end

         % Contribution of internal delays (h = LFT(H,InternalDelays))
         if isfield(D.Delay,'IO')
            % I/O Delays
            h = H;
            Tdio = getIODelay(D,'total');
         else
            Df = D.Delay.Internal;
            nfd = length(Df);
            ny = rs-nfd;
            nu = cs-nfd;
            % Contribution from internal delays
            if nfd>0
               % Sizes
               h = zeros(ny,nu,ls);
               % Finite frequencies
               ix = find(isfinite(s));
               h(:,:,ix) = frdelay(H(:,:,ix),s(ix),Df);
               % NaN frequencies
               h(:,:,isnan(s)) = NaN;
               % Inf frequencies
               ix = find(isinf(s));
               if ~isempty(ix)
                  hinf = localGetInfResp(H(:,:,ix(1)),Df);
                  for ct=1:length(ix)
                     h(:,:,ix(ct)) = hinf;
                  end
               end
            else
               h = H;
            end
            % Contribution from external delays
            Tdio = D.Delay.Input(:,ones(1,ny)).' + D.Delay.Output(:,ones(1,nu));
         end

         % Add contribution of input, output, and I/O delays
         if norm(Tdio,1)>0
            for j=1:ls
               sj = s(j);  hj = h(:,:,j);
               if isfinite(sj)
                  % Finite frequency
                  ix = find(isfinite(hj));
                  hj(ix) = hj(ix) .* exp(-Tdio(ix)*sj);
               else
                  % sj = inf or nan: exp(-s*Tdio(i,j))*hij evaluates to
                  % * hij if hij=0, hij=inf, or Tdio(i,j)=0
                  % * nan otherwise
                  hj(hj~=0 & ~isinf(hj) & Tdio~=0) = NaN;
               end
               h(:,:,j) = hj;
            end
         end
      end% getDelayResp

      %-------------------------------------------

      function boo = utIgnoreX(D) %#ok<MANU>
         % True for models without notion of state vector
         % (used by TIMERESP to determine when to compute X output)
         boo = true;
      end

      %-------------------------------------------

      function checkTimeVector(D,t)
         % Checks time grid is consistent with sample time.
         Ts = D.Ts;
         if length(t)>1 && Ts>0 && abs(t(2)-t(1)-Ts)>1e-4*Ts
            ctrlMsgUtils.error('Control:analysis:CheckTimeVector1');
         end
      end

      %-------------------------------------------

      function [Ni,No,Nf] = checkPadeOrders(D,Ni,No,Nf)
         % Checks that PADE approximation orders are properly sized
         Delay = D.Delay;
         nu = length(Delay.Input);
         ny = length(Delay.Output);

         % Input delays
         Ni = LocalCheckData(Ni,[nu 1]);
         if numel(Ni)~=nu
            ctrlMsgUtils.error('Control:transformation:pade1','pade(SYS,NU,NY,NINT)')
         end

         % Output delays
         No = LocalCheckData(No,[ny 1]);
         if numel(No)~=ny
            ctrlMsgUtils.error('Control:transformation:pade3','pade(SYS,NU,NY,NINT)')
         end

         % Internal delays
         if isfield(Delay,'IO')
            % I/O delays
            Nf = LocalCheckData(Nf,[ny nu]);
            if numel(Nf)~=ny*nu
               ctrlMsgUtils.error('Control:transformation:pade6')
            end
         else
            % Check NF against internal delays
            nfd = length(Delay.Internal);
            Nf = LocalCheckData(Nf,[nfd 1]);
            if numel(Nf)~=nfd
               ctrlMsgUtils.error('Control:transformation:pade5')
            end
         end
      end

      %-------------------------------------------
      
      function [w,Focus] = parseFreqSpec(D,wspec)
         % Interprets W argument of BODE, NYQUIST,...
         w = [];   Focus = [];
         if iscell(wspec)
            % User-defined range
            Focus = [wspec{:}];
            % Override FRANGE if extends beyond Nyquist freq.
            if D.Ts~=0
               nf = pi/abs(D.Ts);
               if Focus(2)>nf
                  Focus = [min(Focus(1),nf/2) , nf];
               end
            end
         elseif ~isempty(wspec)
            % User-defined grid
            w = wspec(:); % e.g., for LTI Viewer when freq. grid defined in Prefs
            nw = length(w);
            if nw==1
               Focus = w * [.5 2];
            else
               Focus = [w(1),w(nw)];
            end
         end
      end

      %-------------------------------------------

   end
   
   methods(Static=true, Access=protected)
      
      function [z,p,k] = fGetDynamics(D)
         % Frequency response commands: 
         % Computes dynamics for each I/O pair
         hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
         [z,p,k] = iodynamics(D);
         if numel(p)>1 && isequal(p{:})
            p = p(1);
         end
      end
      
      %-------------------------------------------
      function w = fAddDecades(w,Ts)
         % Frequency response commands: 
         % Make sure to include 10^k points for [m,p,w]=bode(sys)
         logmin = floor(log10(w(w>0)));
         logmax = ceil(log10(w(end)));
         if Ts>0
            logmax = min(logmax,floor(log10(pi/Ts)));
         end
         w = unique([w;10.^(logmin:logmax).']);
      end
      
      %-------------------------------------------
      function [wout,magout,phout] = fShowPhaseShift(Grade,w,mag,ph,Ts,Td,Focus)
         % Refines frequency grid and interpolates response to track rapid phase
         % changes due to linear delays. Use by BODE, NICHOLS, and NYQUIST.
         newgrid = [];
         switch Grade
            case 1 % Nyquist
               MAXPTS = 2500;
               % Determine interval [0,FMAX] where refined grid is needed
               if ~isempty(Focus)
                  % Note: Focus(2) calculated to show the right amount of detail
                  fmax = Focus(2);
               elseif Ts==0
                  fmax = Inf;
               else
                  fmax = pi/Ts;
               end
               for ct=1:numel(Td)
                  if Td(ct)>0
                     % Find largest freq where gain>0.05
                     wmax = localFindCutOff(w,mag(:,ct),fmax);
                     if isempty(wmax)
                        % Show two cycles
                        newgrid = [newgrid , linspace(0,4*pi/Td(ct),50)]; %#ok<AGROW>
                     else
                        % Grid as many cycles as possible with MAXPTS using 50
                        % points/cycle
                        newgrid = localRefine(newgrid,wmax,Td(ct),MAXPTS);
                     end
                  end
               end
            case {2,3} % Bode/Nichols
               % Determine interval [0,FMAX] where refined grid is needed
               if isempty(Focus)
                  fmax = 20*pi/min(Td(Td>0));
               else
                  fmax = 100 * Focus(2);  % to retain smoothness when rounding/extending freq. limits
               end
               if Ts>0
                  fmax = min(fmax,pi/Ts);
               end
               for ct=1:numel(Td)
                  if Td(ct)>0
                     newgrid = [newgrid , logspace(log10(pi/8),log10(fmax*Td(ct)),50)/Td(ct)]; %#ok<AGROW>
                  end
               end
         end

         % Merge grids
         minpos = pow2(nextpow2(realmin));  % used to prevent log(0)
         wout = sort([w ; newgrid(newgrid>=w(1) & newgrid<=w(end)).']);
         wout = wout([true; diff(log2(wout+minpos))>10*eps]);

         % Interpolate log2(mag) = f(log2(w)) over new grid WOUT.
         % Beware of duplicate entries in log2(w) (causes interp1 failure)
         [xi,iu] = unique(log2(w+minpos));
         yi = log2(mag(iu,:,:)+minpos);
         magout = pow2(interp1(xi,yi,log2(wout+minpos)))-minpos;

         % Interpolate phase
         phout = interp1(w,ph,wout);

      end

      %-------------------------------------------


   end

end


%================ helper functions ======================

function boo = localIsEqual(d1,d2)
% Comparison within o(eps)
rtol = 1e4*eps;
boo = all(abs(d1-d2)<=rtol*(d1+d2));
end


function hinf = localGetInfResp(H,tau)
% Determines the limit of lft(H,exp(-s*tau)) as |s|->Inf
[rs,cs] = size(H);
nfd = length(tau);
ny = rs-nfd;
nu = cs-nfd;
% Determine which delays each I/O pair depends on (structurally)
Depends = iosmreal(H(ny+1:rs,nu+1:cs),H(ny+1:rs,1:nu),H(1:ny,nu+1:cs),[]);
% Close loops with zero delays (other loops can be ignore because
% they either contribute nothing or result in a NaN entry)
hinf = H(1:ny,1:nu);
isNonZero = (tau~=0);
ixz = find(~isNonZero);
nzd = length(ixz);
if nzd>0
   hinf = hinf + H(1:ny,nu+ixz) * ...
      ((eye(nzd)-H(ny+ixz,nu+ixz)) \ H(ny+ixz,1:nu));
end
% Set hinf(i,j) to NaN if it is finite and depends on some nonzero
% internal delay
for ct=1:ny*nu
   if isfinite(hinf(ct)) && any(isNonZero & Depends(:,ct))
      hinf(ct) = NaN;
   end
end
end


function N = LocalCheckData(N,Size)
% Check order specs
N = N(:);
if ~isnumeric(N) || any(N~=round(N)) || any(N<0)
   ctrlMsgUtils.error('Control:transformation:pade7')
elseif isscalar(N)
   N = repmat(double(N),Size);
elseif numel(N)==prod(Size)
   N = reshape(double(N),Size);
end
end

%-----------------------------------------------------------------------

function wmax = localFindCutOff(w,mag,fmax)
% Estimates last frequency where gain > 0.05
idx = find(mag(w<=fmax)>0.05,1,'last');
if isempty(idx) || idx==length(w) || mag(idx+1)>0.05 || mag(idx+1)==0
   wmax = w(idx);
else
   % Use interpolation to get precise estimate (matters when
   % grid is sparse, nyquist(tf(100,[1 0],'iod',.1))
   logmag = log2(mag([idx idx+1]));
   t = (log2(0.05)-logmag(1))/(logmag(2)-logmag(1));
   wmax = w(idx)^(1-t)*w(idx+1)^t;
end
end

%--------------------------------------------------------------

function w = localRefine(w,wmax,Td,MAXPTS)
% Adds 50 points/cycle with MAXPTS constraint on the total number of points
w = unique([0,w]);
period = 2*pi/Td;
dw = period/50;
% First frequency where density less than dw
w0 = w(find(diff(w)>dw,1));
if isempty(w0)
   w0 = w(end);
end

% Refine grid W
npts = round((wmax-w0)/dw);
if npts<=MAXPTS
   w = [w , linspace(w0,wmax,npts)];
else
   MAXPTS2 = MAXPTS/2;
   w2 = dw*MAXPTS2;
   % Use MAXPTS/2 points to grid [0,dw*MAXPTS/2]
   w = [w , linspace(w0,w2,MAXPTS2)];
   % Use logspaced points with monotonic phase to cover the
   % remaining interval (produces desired spiral)
   wx = logspace(log10(w2),log10(wmax),MAXPTS2);
   TargetPhase = repmat(linspace(0,period,50),[1 MAXPTS2/50]);
   w = [w , period * fix(wx/period) + TargetPhase];
end
end

