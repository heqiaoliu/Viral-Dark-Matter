classdef (Hidden = true) ssdata < ltipack.ltidata
   % Class definition for @ssdata (state-space data)

   %   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
   %	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:21 $
   properties
      a
      b
      c
      d
      e
      Scaled = false;  % true if model has been scaled
      StateName
      StateUnit
   end

   methods
      function D = ssdata(a,b,c,d,e,Ts)
         % Constructs @ssdata instance
         if nargin==6
            [ny,nu] = size(d);
            D.a = a;  D.b = b;  D.c = c;  D.d = d;  D.e = e;
            D.Ts = Ts;
            D.Delay = ltipack.utDelayStruct(ny,nu,true);
         end
      end
      
      %-----------------------
      function D = checkData(D)
         % Checks that state-space data is consistent and NaN free. 
         
         % Get dimensions of A,B,C,E matrices
         sa = size(D.a);
         sb = size(D.b);
         sc = size(D.c);
         sd = size(D.d);
         se = size(D.e);
         
         % Determine I/O size for matrix data
         Ny = max(sc(1),sd(1));
         Nu = max(sb(2),sd(2));
         Nx = min(sa);
         Ne = min(se);
         
         % Handle [] shortcuts
         if Nx==0,
            sa = [0 0];  D.a = [];
         end
         if Ne==0,
            se = [0 0];  D.e = [];
         end
         if any(sb==0)
            sb = [Nx Nu];  D.b = zeros(Nx,Nu);
         end
         if any(sc==0)
            sc = [Ny Nx];  D.c = zeros(Ny,Nx);
         end
         if any(sd==0) || isequal(D.d,0)
            % Also allow for scalar expansion when d=0
            % Note: syntax ss([],[],[],0) returns a zero gain system
            sd = [Ny Nu];  D.d = zeros(Ny,Nu);
         end
         
         % Check compatibility of I/O and state dimensions
         if sa(1)~=sa(2) || se(1)~=se(2),
            ctrlMsgUtils.error('Control:ltiobject:ssProperties4')
         elseif Ne>0 && ~isequal(sa,se),
            ctrlMsgUtils.error('Control:ltiobject:ssProperties5')
         elseif Nx~=sb(1),
            ctrlMsgUtils.error('Control:ltiobject:ssProperties1','a','b')
         elseif Nx~=sc(2),
            ctrlMsgUtils.error('Control:ltiobject:ssProperties2','a','c')
         elseif sb(2)~=Nu || sd(2)~=Nu,
            ctrlMsgUtils.error('Control:ltiobject:ssProperties2','b','d')
         elseif sc(1)~=Ny || sd(1)~=Ny,
            ctrlMsgUtils.error('Control:ltiobject:ssProperties1','c','d')
         end
         
         % StateName
         Nx = size(D.a,1);
         if ~isempty(D.StateName)
            if all(strcmp(D.StateName,''))
               D.StateName = [];
            elseif length(D.StateName)~=Nx
               ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateName')
            end
         end
         if ~isempty(D.StateUnit)
            if all(strcmp(D.StateUnit,''))
               D.StateUnit = [];
            elseif length(D.StateUnit)~=Nx
               ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateUnit')
            end
         end
         
         % Checks for NaNs
         if hasInfNaN(D.d)
            D = ltipack.ssdata([],zeros(0,Nu),zeros(Ny,0),nan(Ny,Nu),[],D.Ts);
         end
      end
      
      %-----------------
      function [ny,nu] = iosize(D)
         % Returns I/O size.
         %   [NY,NU] = IOSIZE(SYS)
         %   S = IOSIZE(SYS) returns S = [NY NU].
         [ny,nu] = size(D.d);  % NOTE: Data defines I/O size
         nfd = length(D.Delay.Internal);
         ny = ny-nfd;   nu = nu-nfd;
         if nargout<2
            ny = [ny nu];
         end
      end
      
      %-----------------
      function S = getStateInfo(D)
         % Helper for get.StateName and get.StateUnit
         S = struct('nx',size(D.a,1),...
            'StateName',{D.StateName},'StateUnit',{D.StateUnit});
      end
      
      %-----------------
      function D = zeroInternalDelay(D)
         % Returns model of the SAME order with all internal delays set to zero.
         % This operation may produce an ill-conditioned realization and should
         % be used only when order preservation is critical.
         nfd = length(D.Delay.Internal);
         if nfd>0
            hw = ctrlMsgUtils.SuspendWarnings;
            [a,b1,b2,c1,c2,d11,d12,d21,d22,~] = getBlockData(D); %#ok<*PROP>
            M = [a b1;c1 d11] + [b2;d12] * ((eye(nfd)-d22) \ [c2 d21]);
            if hasInfNaN(M)
               ctrlMsgUtils.error('Control:ltiobject:access3')
            else
               nx = size(a,1);  [ny,nu] = size(d11);
               D.a = M(1:nx,1:nx);
               D.b = M(1:nx,nx+1:nx+nu);
               D.c = M(nx+1:nx+ny,1:nx);
               D.d = M(nx+1:nx+ny,nx+1:nx+nu);
               D.Scaled = false;
            end
         end
      end
      
      %-----------------
      function D = ioperm(D,yperm,uperm)
         % Applies I/O permutations
         D.Delay.Input = D.Delay.Input(uperm);
         D.Delay.Output = D.Delay.Output(yperm);
         nfd = length(D.Delay.Internal);
         if nfd>0
            [ny,nu] = size(D.d);
            yperm = [yperm(:) ; (length(yperm)+1:ny).'];
            uperm = [uperm(:) ; (length(uperm)+1:nu).'];
         end
         D.b = D.b(:,uperm);
         D.c = D.c(yperm,:);
         D.d = D.d(yperm,uperm);
      end
      
      
      
      %----------- LFT support ------------------------
      
      function D = createGain(Dref,G)
         % Wraps static gain into @ssdata object
         [ny,nu] = size(G);
         D = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),G,[],Dref.Ts);
      end
      
      function D = appendGain(D,G)
         % Forms append(D,G) where G is a matrix
         nx = size(D.a,1);
         nfd = length(D.Delay.Internal);
         [ny,nu] = size(D.d);
         [nyG,nuG] = size(G);
         D.d = blkdiag(D.d,G);
         D.b = [D.b , zeros(nx,nuG)];
         D.c = [D.c ; zeros(nyG,nx)];
         D.Delay.Input = [D.Delay.Input ; zeros(nuG,1)];
         D.Delay.Output = [D.Delay.Output ; zeros(nyG,1)];
         if nfd>0
            % Push delay channels to the bottom
            yperm = [1:ny-nfd , ny+1:ny+nyG , ny-nfd+1:ny];
            uperm = [1:nu-nfd , nu+1:nu+nuG , nu-nfd+1:nu];
            D.b = D.b(:,uperm);
            D.c = D.c(yperm,:);
            D.d = D.d(yperm,uperm);
         end
      end
      
      function D = invLFT(D,nyu)
         % Computes Di such that inv(LFT(D,B)) = LFT(Di,B).
         % NYU is the number of external I/Os.
         
         % Error if inverse is not causal
         if any(D.Delay.Input(1:nyu)) || any(D.Delay.Output(1:nyu))
            ctrlMsgUtils.error('Control:transformation:inv1')
         end
         
         % Invert mapping from first NU inputs to first NY outputs
         a = D.a; b = D.b; c = D.c; d = D.d;
         [rs,cs] = size(d);
         nx = size(a,1);
         sw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
         Mi = [a zeros(nx,nyu) b(:,nyu+1:cs); zeros(nyu,nx+cs) ; ...
            c(nyu+1:rs,:) zeros(rs-nyu,nyu) d(nyu+1:rs,nyu+1:cs)] + ...
            [b(:,1:nyu) ; eye(nyu) ; d(nyu+1:rs,1:nyu)] * ...
            (d(1:nyu,1:nyu) \ [-c(1:nyu,:) eye(nyu) -d(1:nyu,nyu+1:cs)]);
         if hasInfNaN(Mi)
            ctrlMsgUtils.error('Control:transformation:invLFT1','REVISIT')
         end
         D.a = Mi(1:nx,1:nx);
         D.b = Mi(1:nx,nx+1:nx+cs);
         D.c = Mi(nx+1:nx+rs,1:nx);
         D.d = Mi(nx+1:nx+rs,nx+1:nx+cs);
         D.Scaled = false;
      end
      
      function [P,pInfo] = hinfstructSetUp(P,B)
         % Constructs LFT and parameterization data for HINFSTRUCT.
         % This function takes
         %   * IC model P (ltipack.ssdata)
         %   * Vector B of ltipack.LFTBlockWrapper objects.
         % Construct pInfo:
         [pInfo,bperm] = HINFSTRUCT_ParamInfo(B);
         % Reflect block permutation in P:
         [rperm,cperm] = getRowColPerm(B,bperm);
         ios = iosize(P);
         nw = ios(2)-length(rperm);
         nz = ios(1)-length(cperm);
         P = ioperm(P,[1:nz nz+cperm],[1:nw nw+rperm]);
      end
      
   end

   methods(Static)
      
      function D = array(size)
         % Create a ssdata array of a given size
         D = ltipack.ssdata.newarray(size);
      end
      
      function D = default()
         % Fast construction of default 0x0 ssdata
         D = ltipack.ssdata;
         D.Ts = 0;   
         D.Delay = ltipack.utDelayStruct(0,0,true);
      end
      
      function D = loadobj(D)
         % Load filter for @ssdata
         if isfield(D.Delay,'IO')
            % Pre-R2009b: Delay structure had IO field for all model types
            D.Delay = rmfield(D.Delay,'IO');
         end
         % R2010a and beyond: store blank state names as []
         if all(strcmp(D.StateName,''))
            D.StateName = [];
         end
      end
      
   end
   
   % Protected methods (utilities)
   methods(Access=protected)

      function [D,rhs] = assignDelay(D,rowIndex,colIndex,rhs)
         % Delay management in D(rowIndex,colIndex) = rhs.
         % Only used to resolve input and output delays in assignments to grow
         % the I/O size
         Din = D.Delay.Input;
         idx = find(isnan(Din));
         if ~isempty(idx)
            [iasgn,~,ib] = intersect(idx,colIndex);
            Din(idx) = 0;
            Din(iasgn) = rhs.Delay.Input(min(ib,end));
            D.Delay.Input = Din;
         end

         Dout = D.Delay.Output;
         idx = find(isnan(Dout));
         if ~isempty(idx)
            [iasgn,~,ib] = intersect(idx,rowIndex);
            Dout(idx) = 0;
            Dout(iasgn) = rhs.Delay.Output(min(ib,end));
            D.Delay.Output = Dout;
         end
      end

      %-------------------------------------------

      function [Delay,fid,fod,ffd] = discretizeDelay(Dc,Ts)
         % Extracts discrete delays for discretization purposes.
         %
         %   [DDELAY,FID,FOD] = DISCRETIZEDELAY(D,TS) extracts the
         %   discrete input and output delays when discretizing D
         %   with sampling interval Ts.  The structure DDELAY contains
         %   the integer-valued discrete delays and the vectors
         %   FID and FOD contain the residual normalized fractional
         %   delays at the inputs and outputs (FID and FOD take value
         %   in [0,1). The internal delays are left untouched.
         %
         %   [DDELAY,FID,FOD,FFD] = DISCRETIZEDELAY(D,TS) also
         %   discretizes the internal delays.

         % Add static method to be included for compiler
         %#function ltipack.splitDelay

         % Compute discrete input and output delays
         Delay = Dc.Delay;
         [Delay.Input,fid] = ltipack.splitDelay(Delay.Input,Ts);
         [Delay.Output,fod] = ltipack.splitDelay(Delay.Output,Ts);
         if nargout<4
            Delay.Internal(:) = 0;
         else
            [Delay.Internal,ffd] = ltipack.splitDelay(Delay.Internal,Ts);
         end
      end % discretizeDelay
      
      %-------------------------------------------
      
      function D = elimZeroDelay(D)
         % Folds zero internal delays into H(s) or H(z) (rational part)
         isZero = (D.Delay.Internal==0);
         idx = find(isZero);
         ndx = length(idx);
         if ndx>0
            % Close all LFT loops associated with zero internal delays
            % NOTE: This may increase the order or produce a NaN model
            Dx = ltipack.ssdata([],zeros(0,ndx),zeros(ndx,0),eye(ndx),[],D.Ts);
            % Push non-appx delays to last row/columns of D.d
            [ny,nu] = iosize(D);
            dperm = [idx ; find(~isZero)];
            yperm = [(1:ny).' ; ny+dperm];
            uperm = [(1:nu).' ; nu+dperm];
            D.b = D.b(:,uperm);
            D.c = D.c(yperm,:);
            D.d = D.d(yperm,uperm);
            D.Delay.Internal(idx,:) = [];
            D.Delay.Input(nu+ndx,1) = 0;
            D.Delay.Output(ny+ndx,1) = 0;
            D = lft(D,Dx,nu+1:nu+ndx,ny+1:ny+ndx,1:ndx,1:ndx);
         end
      end % elimZeroDelay
      
      %-------------------------------------------
      

      function MaxDelay = getMaxDelay(D)
         % Estimates max I/O delay.
         MaxDelay = 0;
         for ct=1:length(D)
            Delay = D(ct).Delay;
            % Note: crude estimate only, does not take into
            % account structure of internal delay model.
            MaxDelay = max(MaxDelay,...
               max([0;Delay.Input]) + max([0;Delay.Output]) + sum(Delay.Internal));
         end
      end

      %-------------------------------------------

      function boo = utIgnoreX(D) %#ok<MANU>
         % True for models without notion of state vector
         % (used by TIMERESP to determine when to compute X output)
         boo = false;
      end

      %-------------------------------------------
      

            
   end

end
