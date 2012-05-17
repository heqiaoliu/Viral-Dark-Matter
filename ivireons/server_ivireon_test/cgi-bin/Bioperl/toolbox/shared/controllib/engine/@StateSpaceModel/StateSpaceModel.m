classdef StateSpaceModel < DynamicSystem
   % State-Space Model Interface (abstract class).
   
%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:01 $
   
   % Abstract properties: StateName and StateUnit
            
   % PUBLIC STATE-SPACE METHODS
   methods

      function [sys,xkeep] = sminreal(sys)
         %SMINREAL  Compute a structurally minimal realization.
         %
         %   MSYS = SMINREAL(SYS) eliminates the states of the state-space
         %   model SYS that are not connected to any input or output. The
         %   resulting state-space model MSYS is equivalent to SYS and is
         %   structurally minimal, i.e., minimal when all nonzero entries
         %   of SYS.A, SYS.B, SYS.C, and SYS.E are set to 1.
         %
         %   See also MINREAL.
         if nargout>1 && numsys(sys)~=1
            ctrlMsgUtils.error('Control:transformation:minreal2','sminreal')
         end
         try
            [sys,xkeep] = sminreal_(sys);
         catch E
            ltipack.throw(E,'command','sminreal',class(sys))
         end
      end
      
      function sys = augstate(sys)
         %AUGSTATE  Appends states to the outputs of a state-space model.
         %
         %   ASYS = AUGSTATE(SYS)  appends the states to the outputs of
         %   the state-space model SYS.  The resulting model is:
         %      .                       .
         %      x  = A x + B u   (or  E x = A x + B u for descriptor SS)
         %
         %     |y| = [C] x + [D] u
         %     |x|   [I]     [0]
         %
         %   This command is useful to close the loop on a full-state
         %   feedback gain  u = Kx.  After preparing the plant with
         %   AUGSTATE,  you can use the FEEDBACK command to derive the
         %   closed-loop model.
         %
         %   See also FEEDBACK, SS.
         error(nargchk(1,1,nargin))
         if numsys(sys)==0
            return
         end
         % Update state-space data
         try
            sys = augstate_(sys);
         catch E
            ltipack.throw(E,'command','augstate',class(sys))
         end
         % Update metadata
         StateNames = sys.StateName;
         StateUnits = sys.StateUnit;
         sys = augmentOutput(sys,StateNames,StateUnits,'states');
         sys.IOSize_(1) = sys.IOSize_(1)+length(StateNames);
         sys.Notes_ = [];  sys.UserData = [];
      end

      function sys = xperm(sys,perm)
         %XPERM  Reorder states in state-space models.
         %
         %   SYS = XPERM(SYS,P) reorders the states of the state-space model SYS
         %   according to the permutation P. The vector P should be a permutation
         %   of 1:NX where NX is the number of states in SYS.
         %
         %   Example: To flip the states of a third-order model SYS, type
         %      psys = xperm(sys,[3 2 1])
         %
         %   See also SS.
         Nx = order(sys);
         perm = perm(:);
         if isempty(Nx)
            return
         elseif norm(Nx-Nx(1),1)>0
            ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','xperm')
         elseif ~isnumeric(perm) || ~isequal(sort(perm),(1:Nx(1))')
            ctrlMsgUtils.error('Control:transformation:xperm',Nx(1))
         end
         try
            sys = xperm_(sys,perm);
         catch E
            ltipack.throw(E,'command','xperm',class(sys))
         end         
      end
      
      
      function co = ctrb(sys)
         %CTRB  Compute the controllability matrix.
         %
         %   CO = CTRB(A,B) returns the controllability matrix [B AB A^2B ...].
         %
         %   CO = CTRB(SYS) returns the controllability matrix of the
         %   state-space model SYS with realization (A,B,C,D).  This is
         %   equivalent to CTRB(sys.a,sys.b).
         %
         %   For ND arrays of state-space models SYS, CO is an array with N+2
         %   dimensions where CO(:,:,j1,...,jN) contains the controllability
         %   matrix of the state-space model SYS(:,:,j1,...,jN).
         %
         %   See also CTRBF, SS.
         if numel(size(sys,'order'))>1
            ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','ctrb')
         end
         
         % Extract data
         try
            [a,b] = ssdata(sys);
         catch %#ok<CTCH>
            ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','ctrb')
         end
         
         % Compute controllability matrix for each model
         nx = size(a,1);
         bs = size(b);
         co = zeros([nx bs(2)*nx bs(3:end)]);
         for k=1:prod(bs(3:end)),
            co(:,:,k) = ctrb(a(:,:,k),b(:,:,k));
         end
      end
      
      function ob = obsv(sys)
         %OBSV  Compute the observability matrix.
         %
         %   OB = OBSV(A,C) returns the observability matrix [C; CA; CA^2 ...]
         %
         %   CO = OBSV(SYS) returns the observability matrix of the
         %   state-space model SYS with realization (A,B,C,D).  This is
         %   equivalent to OBSV(sys.a,sys.c).
         %
         %   For ND arrays of state-space models SYS, OB is an array with N+2
         %   dimensions where OB(:,:,j1,...,jN) contains the observability
         %   matrix of the state-space model SYS(:,:,j1,...,jN).
         %
         %   See also OBSVF, SS.
         if numel(size(sys,'order'))>1
            ctrlMsgUtils.error('Control:general:RequiresUniformNumberOfStates','obsv')
         end
         
         % Extract data
         try
            [a,~,c] = ssdata(sys);
         catch %#ok<CTCH>
            ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','obsv')
         end
         
         % Compute controllability matrix for each model
         nx = size(a,1);
         cs = size(c);
         ob = zeros([cs(1)*nx nx cs(3:end)]);
         for k=1:prod(cs(3:end)),
            ob(:,:,k) = obsv(a(:,:,k),c(:,:,k));
         end
      end
      
      function W = gram(sys,type)
         %GRAM  Controllability and observability gramians.
         %
         %   Wc = GRAM(SYS,'c') computes the controllability gramian of
         %   the state-space model SYS (see SS).
         %
         %   Wo = GRAM(SYS,'o') computes its observability gramian.
         %
         %   In both cases, the state-space model SYS should be stable.
         %   The gramians are computed by solving the Lyapunov equations:
         %
         %     *  A*Wc + Wc*A' + BB' = 0  and   A'*Wo + Wo*A + C'C = 0
         %        for continuous-time systems
         %               dx/dt = A x + B u  ,   y = C x + D u
         %
         %     *  A*Wc*A' - Wc + BB' = 0  and   A'*Wo*A - Wo + C'C = 0
         %        for discrete-time systems
         %           x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n].
         %
         %   For arrays of LTI models SYS, Wc and Wo are double arrays
         %   such that
         %      Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .
         %      Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .
         %
         %   Rc = GRAM(SYS,'cf') and Ro = GRAM(SYS,'of') return the Cholesky
         %   factors of gramians (Wc = Rc'*Rc and Wo = Ro'*Ro).
         %
         %   See also SS, BALREAL, CTRB, OBSV.
         
         %   Laub, A., "Computation of Balancing Transformations", Proc. JACC
         %     Vol.1, paper FA8-E, 1980.
         if nargin~=2,
            ctrlMsgUtils.error('Control:foundation:gram1')
         elseif ~ischar(type) || ~any(lower(type(1))=='co')
            ctrlMsgUtils.error('Control:foundation:gram2')
         end
         
         % Compute grammians
         try
            W = gram_(sys,type);
         catch E
            ltipack.throw(E,'command','gram',class(sys))
         end
         if hasdelay(sys)
            % Warn about ignoring delays
            ctrlMsgUtils.warning('Control:analysis:GramIgnoreDelay')
         end
      end
      
   end
end
