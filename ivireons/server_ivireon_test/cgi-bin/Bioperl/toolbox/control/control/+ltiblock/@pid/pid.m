classdef pid < ltiblock.Parametric
   %LTIBLOCK.PID  Parametric 1-DOF PID controller.
   %
   %   BLK = LTIBLOCK.PID(NAME,TYPE) creates the 1-DOF continuous-time PID block
   %       C(s) = Kp + Ki/s + Kd*s/(1+Tf*s)
   %   parameterized by the scalar gains Kp,Ki,Kd and the filter time constant Tf. 
   %   The string NAME specifies the block name and the string TYPE specifies the 
   %   PID structure among the following:
   %      'P'    proportional only control (Ki=Kd=0, Kp free)
   %      'PI'   proportional-integral control (Kd=0, Kp,Ki free)
   %      'PD'   proportional-derivative control (Ki=0, Kp,Kd,Tf free)
   %      'PID'  proportional-integral-derivative control (Kp,Ki,Kd,Tf free)
   % 
   %   BLK = LTIBLOCK.PID(NAME,TYPE,Ts) creates a discrete-time PID block with
   %   sampling time Ts. The discrete PID equations are
   %      C(z) = Kp + Ki * IF(z) + Kd/(Tf + DF(z))
   %   where IF(z) and DF(z) are the discrete integrator formulas for the integral
   %   and derivative terms. The default formulas are 
   %      IF(z) = DF(z) = Ts/(z-1)    (Forward Euler).
   %   To use the Backward Euler or Trapezoidal formulas instead, set the "IFormula" 
   %   and "DFormula" properties of BLK accordingly.
   %
   %   BLK = LTIBLOCK.PID(NAME,SYS) uses the LTI model SYS to set the PID structure,
   %   sampling time, and initial values of Kp, Ki, Kd, Tf. The model SYS must be
   %   compatible with the PID formulas above.
   %
   %   You can modify the PID structure by fixing or freeing any of the parameters
   %   Kp, Ki, Kd, Tf. For example, BLK.Tf.Free = false fixes Tf to its current 
   %   value.
   %
   %   Example:
   %      blk = ltiblock.pid('demo','PD');
   %      blk.Kp.Value = 4;        % initialize Kp to 4
   %      blk.Kd.Value = 0.7;      % initialize Kd to 0.7
   %      blk.Tf.Value = 0.01;     % set parameter Tf to 0.01
   %      blk.Tf.Free = false;     % fix parameter Tf to this value
   %
   %   See also LTIBLOCK.TF, LTIBLOCK.SS, CONTROLDESIGNBLOCK.
   
%   Author(s): R. Chen, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4.2.1 $  $Date: 2010/06/24 19:32:22 $
   
   % Note: The optimization interface uses the parameterization
   %         Kp + Ki * IF + Kd * wf / (1 + wf * DF)
   % where wf = 1/Tf and IF,DF are the integrator formulas for 
   % the I and D terms. This avoid the discontinuity at Tf=0 (PID
   % becomes improper and pole changes sign at Inf)
      
   properties (Access = public, Dependent) 
      % Proportional gain (scalar parameter).
      %
      % Use this property to read the current value of the proportional gain Kp
      % or to initialize, fix, or free this tunable parameter.
      Kp
      % Integral gain (scalar parameter).
      %
      % Use this property to read the current value of the integral gain Ki
      % or to initialize, fix, or free this tunable parameter.
      Ki
      % Derivative gain (scalar parameter).
      %
      % Use this property to read the current value of the derivative gain Kd
      % or to initialize, fix, or free this tunable parameter.
      Kd
      % Time constant for derivative filter (scalar parameter).
      %
      % Use this property to read the current value of the time constant Tf
      % or to initialize, fix, or free this tunable parameter.
      Tf
      % Discrete integrator formula for integral term.
      %
      % Set this property to 'ForwardEuler', 'BackwardEuler' or 'Trapezoidal'
      % to select the formula Ts/(z-1), Ts*z/(z-1), or (Ts/2)*(z+1)/(z-1),
      % respectively.
      IFormula
      % Discrete integrator formula for derivative term.
      %
      % Set this property to 'ForwardEuler', 'BackwardEuler' or 'Trapezoidal'
      % to select the formula Ts/(z-1), Ts*z/(z-1), or (Ts/2)*(z+1)/(z-1),
      % respectively.
      DFormula
   end
      
   properties (Access = protected)
      Kp_
      Ki_
      Kd_
      Tf_
      IFormula_ = 'F';  % default = ForwardEuler
      DFormula_ = 'F';  % default = ForwardEuler
   end
   
   % TYPE MANAGEMENT IN BINARY OPERATIONS
   methods (Static, Hidden)
      
      function T = inferiorTypes()
         T = cell(1,0);
      end
      
      function boo = isCombinable(~)
         boo = false;
      end
      
      function boo = isSystem()
         boo = true;
      end
      
      function boo = isFRD()
         boo = false;
      end
      
      function boo = isStructured()
         boo = true;
      end
      
      function boo = isGeneric()
         boo = true;
      end
      
      function T = toFRD()
         T = 'genfrd';
      end
      
      function T = toCombinable()
         T = 'genss';
      end
      
   end
   

   % CONSTRUCTION, INITIALIZATION, CONVERSION
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      function blk = pid(Name,varargin)
         ni = nargin;
         blk.IOSize_ = [1,1];
         if ni==0
            return
         end
         TypeSpec = (ni==2 || ni==3) && ischar(varargin{1});
         % Validate Name
         if ~isvarname(Name)
            ctrlMsgUtils.error('Control:lftmodel:BlockName1')
         end
         % Parse inputs
         try
            if TypeSpec
               % ltiblock.pid(name,type{,Ts})
               % Validate type
               Type = ltipack.matchKey(varargin{1},{'p','pi','pd','pid'});
               if isempty(Type)
                  ctrlMsgUtils.error('Control:lftmodel:ltiblockPID1')
               end
               if ni==2
                  Ts = 0;
               else
                  Ts = ltipack.utValidateTs(varargin{2});
               end
               [Kp,Ki,Kd,Tf] = localInitParameters(Type,Ts);
            elseif ni==2
               % ltiblock.pid(name,sys)
               sys = varargin{1};
               try
                  sys = pid(sys);
               catch E
                  ctrlMsgUtils.error('Control:lftmodel:ltiblockPID2')
               end
               if nmodels(sys)~=1
                  ctrlMsgUtils.error('Control:lftmodel:ltiblockPID4')
               end
               [Kp,Ki,Kd,Tf,Ts] = piddata(sys);
               if Tf==0
                  % Improper PID not allowed
                  if Kd==0
                     Tf = (Ts==0) + 10*abs(Ts);
                  else
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockPID3')
                  end
               end
            else
               ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ltiblock.pid','ltiblock.pid')
            end
         catch ME
            throw(ME)
         end
         
         % Construct block
         blk.Ts_ = Ts;
         blk.Kp_ = param.Continuous('Kp',Kp);
         blk.Ki_ = param.Continuous('Ki',Ki);
         blk.Ki_.Free = (Ki~=0);
         blk.Kd_= param.Continuous('Kd',Kd);
         blk.Kd_.Free = (Kd~=0);
         blk.Tf_ = param.Continuous('Tf',Tf);
         blk.Tf_.Free = (Kd~=0);    
         if ~TypeSpec
            % Inherit metadata and formulas form PID object
            blk = copyMetaData(sys,blk);
            blk.IFormula = sys.IFormula;  
            blk.DFormula = sys.DFormula;
         end
         blk.Name = Name;
      end
      
      function Value = get.Kp(blk)
         % GET method for Kp property
         Value = blk.Kp_;
      end

      function Value = get.Ki(blk)
         % GET method for Ki property
         Value = blk.Ki_;
      end
      
      function Value = get.Kd(blk)
         % GET method for Kd property
         Value = blk.Kd_;
      end

      function Value = get.Tf(blk)
         % GET method for Tf property
         Value = blk.Tf_;
      end
      
      function Value = get.IFormula(blk)
         % GET method for IFormula property
         Value = ltipack.getPIDFormula(blk.IFormula_,blk.Ts_);
      end
      
      function Value = get.DFormula(blk)
         % GET method for DFormula property
         Value = ltipack.getPIDFormula(blk.DFormula_,blk.Ts_);
      end
      
      function blk = set.Kp(blk,Value)
         % SET method for Kp property
         blk.Kp_ = pmodel.checkParameter(Value,'Kp',[1 1]);
      end
      
      function blk = set.Ki(blk,Value)
         % SET method for Ki property
         blk.Ki_ = pmodel.checkParameter(Value,'Ki',[1 1]);
      end
      
      function blk = set.Kd(blk,Value)
         % SET method for Kd property
         blk.Kd_ = pmodel.checkParameter(Value,'Kd',[1 1]);
      end
      
      function blk = set.Tf(blk,pTf)
         % SET method for Tf property
         pTf = pmodel.checkParameter(pTf,'Tf',[1 1]);
         if pTf.Value==0
            ctrlMsgUtils.error('Control:lftmodel:ltiblockPID5')
         end
         blk.Tf_ = pTf;
      end
            
      function blk = set.IFormula(blk,Value)
         % SET method for IFormula property
         blk.IFormula_ = ltipack.setPIDFormula(Value);
      end
            
      function blk = set.DFormula(blk,Value)
         % SET method for DFormula property
         blk.DFormula_ = ltipack.setPIDFormula(Value);
      end
      
      function T = getType(blk)
         % Controller type
         T = 'P';
         if isempty(blk.Ki_) || blk.Ki_.Free
            T = [T 'I'];
         end
         if isempty(blk.Kd_) || blk.Kd_.Free
            T = [T 'D'];
         end
      end
      
   end
   
   %% SUPERCLASS INTERFACES
   methods (Access=protected)
      
      function displaySize(blk,~)
         % Display for "size(sys)"
         disp(ctrlMsgUtils.message('Control:lftmodel:SizePID1',getType(blk)))
      end
      
      % PARAMETRIC BLOCK
      function np = nparams_(blk,varargin)
         % Number of parameters
         if nargin>1
            np = numel(find(isfree_(blk)));
         else
            np = 4;
         end
      end
      
      function isf = isfree_(blk)
         % True for free parameters
         isf = [blk.Kp_.Free ; blk.Ki_.Free ; blk.Kd_.Free ; blk.Tf_.Free];
      end
      
      function p = getp_(blk,varargin)
         % Get vector of parameter values
         % Note: p set to [Kp.;Ki;Kd;1/Tf] rather than [Kp.;Ki;Kd;Tf]
         p = [blk.Kp_.Value ; blk.Ki_.Value ; blk.Kd_.Value ; 1/blk.Tf_.Value];
         if nargin>1
            p = p([blk.Kp_.Free ; blk.Ki_.Free ; blk.Kd_.Free ; blk.Tf_.Free]);
         end
      end
      
      function blk = setp_(blk,p,varargin)
         % Set vector of parameter values
         np = length(p);
         if nargin==2
            if np~=4
               ctrlMsgUtils.error('Control:pmodel:setp')
            end
            blk.Kp_.Value = p(1);
            blk.Ki_.Value = p(2);
            blk.Kd_.Value = p(3);
            blk.Tf_.Value = 1/p(4);
         else
            try %#ok<TRYNC>
               ip = 0;
               if blk.Kp_.Free
                  ip = ip+1; blk.Kp_.Value = p(ip);
               end
               if blk.Ki_.Free
                  ip = ip+1; blk.Ki_.Value = p(ip); 
               end
               if blk.Kd_.Free
                  ip = ip+1; blk.Kd_.Value = p(ip);
               end
               if blk.Tf_.Free
                  ip = ip+1; blk.Tf_.Value = 1/p(ip);
               end
            end 
            if ip~=np
               ctrlMsgUtils.error('Control:pmodel:setp')
            end
         end
      end
      
      function P = randp_(blk,N,varargin)
         % Generates random samples of model parameters.
         P = [10.^(4*rand(1,N)-2) ; 10.^(2*rand(2,N)-2) ; 20*rand(1,N)];
         % Randomize signs of Kp,Ki,R coefficients
         for ct=1:N
            if rand<.4
               P(1:2,ct) = -P(1:2,ct);  % switch loop sign
            end
            if rand<.3
               P(3,ct) = -P(3,ct);   % switch D sign
            end
         end
         if nargin>2
            P = P(isfree_(blk),:);
         end
      end
      
   end
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% MODEL CHARACTERISTICS
      function boo = isreal_(blk)
         % Returns true if the current values of the PID coefficients are real
         boo = isreal(blk.Kp_.Value) && isreal(blk.Ki_.Value) && ...
            isreal(blk.Kd_.Value) && isreal(blk.Tf_.Value);
      end
      
      function boo = isstatic_(blk)
         % A PID block is static if its current value has no states. This 
         % ensures ISSTATIC returns the same value for BLK and SS(BLK).
         boo = (blk.Ki_.Value==0 && blk.Kd_.Value==0);
      end
      
      function ns = order_(blk)
         % Number of states in current value of the block (same as ORDER(SS(BLK)))
         ns = (blk.Ki_.Value~=0) + (blk.Kd_.Value~=0);
      end
      
      function [a,b,c,d,Ts] = ssdata_(blk,varargin)
         % Explicit state-space data for current block value
         [Kp,Ki,Kd,Tf,Ts] = piddata_(blk);
         Ts = abs(Ts);
         a = []; b = zeros(0,1); c = zeros(1,0); d = Kp; %P
         if Ts==0
            % Continuous time
            if Ki~=0
               a = blkdiag(a, 0);  b = [b; 1];  c = [c Ki];
            end
            if Kd~=0
               wf = 1/Tf;
               a = blkdiag(a, -wf); b = [b; wf]; c = [c -Kd*wf]; d = d + Kd*wf;
            end
         else
            % Discrete time
            alphas = [0 Ts Ts/2];  % for 'F','B','T' formulas
            if Ki~=0
               % integrator: a=1, b=1, c=Ts, d={0,Ts,Ts/2}
               a = blkdiag(a, 1);  b = [b; 1];  c = [c Ts*Ki]; 
               d = d + Ki * alphas(blk.IFormula(1)=='FBT');
            end
            if Kd~=0
               beta = Tf + alphas(blk.DFormula(1)=='FBT');
               aux1 = Ts/beta;
               aux2 = Kd/beta;
               a = blkdiag(a, 1-aux1); b = [b; -aux1]; c = [c aux2];  d = d + aux2;
            end
         end
      end
      
      function [Kp,Ki,Kd,Tf,Ts] = piddata_(blk,varargin)
         % Extract PID coefficients
         Kp = blk.Kp_.Value;
         Ki = blk.Ki_.Value;
         Kd = blk.Kd_.Value;
         Tf = blk.Tf_.Value;
         Ts = blk.Ts_;
      end
      
      %% CONVERSIONS
      function sys = ss_(blk,varargin)
         % Converts current block value to @ss
         sys = ss.make(ltipack_ssdata(blk));
      end
      
      function sys = tf_(blk)
         % Converts to @tf so that TF(BLK) = TF(PID(BLK))
         sys = tf.make(tf(ltipack_piddataP(blk)));
      end
      
      function sys = zpk_(blk)
         % Converts to @zpk so that ZPK(BLK) = ZPK(PID(BLK))
         sys = zpk.make(zpk(ltipack_piddataP(blk)));
      end
            
      function sys = pid_(blk,Options)
         % Converts to @pid
         D = ltipack_piddataP(blk);
         if nargin>1
            D = pid(D,Options);
         end
         sys = pid.make(D);
      end
      
      function sys = pidstd_(blk,varargin)
         % Converts to @pidstd
         sys = pidstd.make(pidstd(ltipack_piddataP(blk),varargin{:}));
      end
      
      %% ANALYSIS
      function p = pole_(blk)
         % Poles of current block value
         p = zeros(0,1);
         Ts = blk.Ts_;
         if blk.Ki_.Value~=0
            p = [p ; (Ts~=0)];
         end
         if blk.Kd_.Value~=0
            Tf = blk.Tf_.Value;
            if Ts==0
               p = [p ; -1/Tf];
            else
               switch blk.DFormula_
                  case 'F'
                     p = [p ; 1-Ts/Tf];
                  case 'B'
                     p = [p ; Tf/(Tf+Ts)];
                  case 'T'
                     p = [p ; (2*Tf-Ts)/(2*Tf+Ts)];
               end
            end
         end
      end
      
   end
   
   
   %% HIDDEN INTERFACES
   methods (Hidden)

      %% CONTROLDESIGNBLOCK
      function Offset = getOffset(blk)
         % Feedthrough value
         Offset = blk.Kp_.Value + blk.Kd_.Value / blk.Tf_.Value;
      end
      
      function D = ltipack_ssdata(blk,~,S)
         % Converts to ltipack.ssdata object
         [a,b,c,d,Ts] = ssdata_(blk);
         if nargin>1
            d = d-S;
         end
         D = ltipack.ssdata(a,b,c,d,[],Ts);
         if ~isempty(a)
            D.StateName = getStateName(blk);
         end
      end
      
      function D = ltipack_frddata(blk,freq,unit,~,S)
         % Converts to ltipack.frddata object
         C = ltipack_piddataP(blk);
         if nargin>3
            C.Kp = C.Kp - S;
         end
         D = frd(C,freq,unit);
      end
      
      function D = ltipack_piddataP(blk)
         % Converts to ltipack.piddataP object
         [Kp,Ki,Kd,Tf,Ts] = piddata_(blk);
         D = ltipack.piddataP(Kp,Ki,Kd,Tf,Ts);
         if Ts~=0
            D.IFormula = blk.IFormula_;
            D.DFormula = blk.DFormula_;
         end
      end
      
      function str = getDescription(blk,ncopies)
         % Short description for block summary in LFT model display
         str = ctrlMsgUtils.message('Control:lftmodel:ltiblockPID6',...
            getName(blk),ncopies);
      end
      
      %% OPTIMIZATION
      function ns = numState(blk)
         % Size of A matrix from p2ss (number of states in current 
         % parameterization)
         ns =(blk.Ki_.Free || blk.Ki_.Value~=0) + ...
            (blk.Kd_.Free || blk.Kd_.Value~=0);
      end
      
      function [a,b,c,d] = p2ss(blk,p)
         % Constructs realization from parameter vector p=[Kp Ki Kd wf]
         % where wf = 1/Tf.
         % Note: Can't use change of variable R=Kd*wf because this would
         % prevent independently fixing Kd and wf.
         Ki = blk.Ki_;
         Kd = blk.Kd_;
         a = []; b = zeros(0,1); c = zeros(1,0); d = p(1);
         nx = 0;
         if Ki.Free || Ki.Value~=0
            % I term
            nx = nx+1;
            if blk.Ts_==0
               a(nx,nx) = 0;  b(nx,1) = 1;  c(1,nx) = p(2);
            else
               % REVISIT
            end
         end
         if Kd.Free || Kd.Value~=0
            % D term
            nx = nx+1;
            if blk.Ts_==0
               aux = p(3)*p(4);
               a(nx,nx) = -p(4);  b(nx,1) = p(4);  c(1,nx) = -aux;  d = d+aux;
            else
               % REVISIT
            end
         end
      end
      
      %------------------------------------------------
      function gj = gradUV(blk,p,u,v,j)
         % Computes the gradient of the inner product
         %    phi(p) = Re(Trace(U'*[A(p) B(p);C(p) D(p)]*V))
         % with respect to the block parameters p(j) where j is a vector
         % of indices. The real or complex matrices U and V must have the
         % same number of columns.
         W = real(u*v');
         nx = size(u,1)-1;
         if nx==0
            % P control
            g = [W;0;0;0];
         elseif nx==2
            % PID control
            aux = W(3,3)-W(3,2);
            g = [W(3,3);W(3,1);p(4)*aux;W(2,3)-W(2,2)+p(3)*aux];
         elseif blk.Ki_.Free || blk.Ki_.Value~=0
            % PI control
            g = [W(2,2);W(2,1);0;0];
         else
            % PD control
            aux = W(2,2)-W(2,1);
            g = [W(2,2);0;p(4)*aux;W(1,2)-W(1,1)+p(3)*aux];
         end
         gj = g(j);
      end
               
   end
   
   
   %% UTILITIES
   methods (Access=protected)
            
      function StateName = getStateName(blk)
         % Returns vector of state names
         StateName = cell(0,1);
         if blk.Ki_.Value~=0
            StateName = [StateName ; {sprintf('%s.Integ',blk.Name)}];
         end
         if blk.Kd_.Value~=0
            StateName = [StateName ; {sprintf('%s.Deriv',blk.Name)}];
         end
      end
         
   end
   
end

%-----------------------------------------------------------
% Utility Functions
%-----------------------------------------------------------
function [Kp,Ki,Kd,Tf] = localInitParameters(Type,Ts)
% Initialize the Value and Free properties of parameters P, I, D, N.
% Shape of PID response is independent of Ts, Kp is set to zero to avoid 
% initial block offset.
Ts = abs(Ts) + (Ts==0);
Tf = Ts;
if any(Type=='i')
   Ki = 0.001/Ts;
else 
   Ki = 0;
end
if any(Type=='d')
   %Kp = 0.01;  Kd = 0.01*Ts;    
   Kp = 0;  Kd = 0.01*Ts;    
else
   Kp = 0;  Kd = 0;
end
end
