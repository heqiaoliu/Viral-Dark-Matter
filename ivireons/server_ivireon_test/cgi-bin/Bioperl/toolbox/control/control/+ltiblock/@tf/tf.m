classdef tf < ltiblock.Parametric
   %LTIBLOCK.TF  Fixed-order parametric transfer function.
   %
   %   BLK = LTIBLOCK.TF(NAME,NZ,NP) creates a parametric SISO transfer 
   %   function BLK with NP poles and at most NZ zeros. The string NAME 
   %   specifies the block name. Note that the leading coefficient of the 
   %   denominator is always fixed to 1.
   %
   %   BLK = LTIBLOCK.TF(NAME,NZ,NP,TS) creates a discrete-time parametric
   %   transfer function with sampling time TS.
   %
   %   BLK = LTIBLOCK.TF(NAME,SYS) uses the transfer function SYS (see TF)
   %   to set the transfer function order, sampling time, and initial
   %   parameter values.
   %
   %   Example: Create a parametric SISO transfer function with two zeros,  
   %   four poles, and at least one integrator:
   %      blk = ltiblock.tf('demo',2,4);
   %      blk.den.Value(end) = 0;     % set last denominator entry to zero
   %      blk.den.Free(end) = false;  % fix it to zero
   %
   %   See also LTIBLOCK.SS, CONTROLDESIGNBLOCK, TF, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2.2.1 $  $Date: 2010/06/28 14:16:55 $

   properties (Access = public, Dependent)   
      % Numerator vector (row vector of parameters).
      %
      % Use this property to read the current value of the vector of numerator
      % coefficients or to initialize, fix, or free specific coefficients in
      % the numerator.
      num
      % Denominator vector (row vector of parameters).
      %
      % Use this property to read the current value of the vector of denominator
      % coefficients or to initialize, fix, or free specific coefficients in
      % the denominator. Note that the leading coefficient (first entry of the
      % vector) is always fixed to the value 1.
      den
   end
   
   properties (Access = protected)
      % Model parameterization (pmodel.tf)
      Parameterization_
   end
   
   properties (Access = protected, Transient)
      Nz_  % caches number of zeros
      Np_  % caches number of poles
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

      function blk = tf(Name,varargin)
         ni = nargin;
         blk.IOSize_ = [1 1];
         if ni==0
            return
         end
         % Validate Name 
         if ~isvarname(Name)
            ctrlMsgUtils.error('Control:lftmodel:BlockName1')
         end
         % Check remaining input arguments
         try
            switch ni
               case 2
                  % ltiblock.tf(name,TFObject)
                  sys = varargin{1};
                  try
                     sys = tf.cast(sys);
                  catch E
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF2')
                  end
                  if ~(nmodels(sys)==1 && issiso(sys))
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF1')
                  end
                  [num,den,Ts] = tfdata(sys,'v');
                  if den(1)==0  % improper
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF3')
                  end
                  idnz = find(num~=0,1);
                  if isempty(idnz)
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF11')
                  else
                     num = num(idnz:end);
                  end
                  nz = numel(num)-1;   np = numel(den)-1;
               case {3,4}
                  % ltiblock.tf(name,nz,np,Ts)
                  if ~all(cellfun(@(x) isnumeric(x) && isscalar(x) && isreal(x) && ...
                        x==floor(x) && x>=0,varargin(1:2)))
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF4')
                  end
                  nz = varargin{1};  np = varargin{2};
                  if nz>np
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockTF10')
                  end
                  if ni==3
                     Ts = 0;
                  else
                     Ts = ltipack.utValidateTs(varargin{3});
                  end
                  [num,den] = ltiblock.tf.defaultND(varargin{1:2},Ts);
               otherwise
                  ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ltiblock.tf','ltiblock.tf')
            end
         catch ME
            throw(ME)
         end
                           
         % Initialize block
         blk.Ts_ = Ts;
         blk.Nz_ = nz;
         blk.Np_ = np;
         blk.Parameterization_ = pmodel.tf(num,den);
         if ni==2
            blk = copyMetaData(sys,blk);
         end
         blk.Name = Name;
      end
      
      function Value = get.num(blk)
         % GET method for NUM property
         try
            Value = blk.Parameterization_.num;
         catch %#ok<*CTCH>
            Value = [];  % ltiblock.tf()
         end
      end
            
      function Value = get.den(blk)
         % GET method for DEN property
         try
            Value = blk.Parameterization_.den;
         catch
            Value = [];
         end
      end
      
      function blk = set.num(blk,Value)
         % SET method for NUM property
         blk.Parameterization_.num = pmodel.checkParameter(...
            Value,'num',getSize(blk.Parameterization_.num));
      end
      
      function blk = set.den(blk,pDen)
         % SET method for DEN property
         pDen = pmodel.checkParameter(...
            pDen,'den',getSize(blk.Parameterization_.den));
         if pDen.Value(1)~=1 || pDen.Free(1)
            % Check constraint on DEN(1)
            ctrlMsgUtils.error('Control:pmodel:monicDen')
         end
         blk.Parameterization_.den = pDen;
      end
      
      %----------------------------------------------
      function blk = init(blk,sys,varargin)
         %INIT  Initializes parametric transfer function block.
         %
         %   BLK = INIT(BLK,SYS) uses the SISO LTI model SYS to initialize   
         %   the parametric transfer function block BLK (see LTIBLOCK.TF).  
         %   SYS is first converted to a transfer function with matching number
         %   of poles and zeros before initializing the block parameters.
         %
         %   BLK = INIT(BLK,SYS,'free') initializes only the free parameters
         %   in BLK.
         %
         %   See also LTIBLOCK.TF.
         Ts = blk.Ts_;  nz = blk.Nz_;  np = blk.Np_;
         if ~(isa(sys,'DynamicSystem') && nmodels(sys)==1 && issiso(sys))
            ctrlMsgUtils.error('Control:lftmodel:ltiblockTF3')
         end
         try
            sys = tf(sys);
         catch E
            ctrlMsgUtils.error('Control:lftmodel:ltiblockTF6')
         end
         if sys.Ts~=Ts
            ctrlMsgUtils.error('Control:lftmodel:ltiblockTF7')
         end

         % Adjust order
         npsys = order(sys);
         if npsys<np
            % Add extra poles
            [naug,daug] = ltiblock.tf.defaultND(0,np-npsys,Ts);
            sys = sys + tf(1e-8*naug,daug);
         elseif npsys>np
            % Use reduced-order approximation
            try
               sys = balred(sys,np);
            catch E
               ctrlMsgUtils.error('Control:lftmodel:ltiblockTF8')
            end
         end
         
         % Discard excess zeros and normalize DEN
         [num,den] = tfdata(sys,'v');
         d1 = den(1);
         if d1==0
            ctrlMsgUtils.error('Control:lftmodel:ltiblockTF9')
         else
            den = den/d1;  num = num/d1;
         end
         % REVISIT: look for smarter scheme
         num = num(np-nz+1:end);
         
         % Initialize parameters
         blkParam = blk.Parameterization_;
         if nargin<3
            blkParam.num.Value = num;
            blkParam.den.Value = den;
         else
            nF = blkParam.num.Free;  
            blkParam.num.Value(nF) = num(nF);
            dF = blkParam.den.Free;
            blkParam.den.Value(dF) = den(dF);
         end
         blk.Parameterization_ = blkParam;
      end
      
   end
   
   
   %% SUPERCLASS INTERFACES
   methods (Access=protected)
      
      function displaySize(blk,~)
         % Display for "size(sys)"
         if isempty(blk.Np_)
            disp(ctrlMsgUtils.message('Control:lftmodel:SizeTF1',0,0))
         else
            disp(ctrlMsgUtils.message('Control:lftmodel:SizeTF1',blk.Nz_,blk.Np_))
         end
      end
      
      % PARAMETRIC BLOCK
      function np = nparams_(blk,varargin)
         % Number of parameters
         if nargin>1
            np = nparams(blk.Parameterization_,varargin{:});
         else
            np = blk.Nz_ + blk.Np_ + 2;
         end
      end
      
      function isf = isfree_(blk)
         % True for free parameters
         isf = isfree(blk.Parameterization_);
      end
      
      function p = getp_(blk,varargin)
         % Get vector of parameter values
         p = getp(blk.Parameterization_,varargin{:});
      end
      
      function blk = setp_(blk,p,varargin)
         % Set vector of parameter values
         blk.Parameterization_ = setp(blk.Parameterization_,p,varargin{:});
      end
      
      function P = randp_(blk,N,varargin)
         % Generates random samples of model parameters.
         Ts = blk.Ts_;
         
         % Generate random samples
         P = zeros(nparams_(blk),N);
         for j=1:N
            [num,den] = ltiblock.tf.randND(blk.Nz_,blk.Np_,Ts);
            P(:,j) = [num.';den.'];
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
         % Returns true if the current value is real
         blkParam = blk.Parameterization_;
         boo = isreal(blkParam.num.Value) && isreal(blkParam.den.Value);
      end
      
      function boo = isstatic_(blk)
         % Block is static if DEN==1 (note: order cannot change after construction)
         boo = (blk.Np_==0);
      end
      
      function ns = order_(blk)
         % Get number of states
         ns = blk.Np_;
      end
   
      function [num,den,Ts] = tfdata_(blk,varargin)
         % Quick access to transfer function data
         blkParam = blk.Parameterization_;
         N = blkParam.num.Value;
         D = blkParam.den.Value;
         num = {[zeros(1,numel(D)-numel(N)) N]};
         den = {D};
         Ts = blk.Ts_;
      end

      %% CONVERSIONS
      function sys = tf_(blk)
         % Converts to @tf
         sys = tf.make(ltipack_tfdata(blk));
      end
       
      function sys = zpk_(blk)
         % Converts to @zpk
         sys = zpk.make(zpk(ltipack_tfdata(blk)));
      end
      
      function sys = pid_(blk,varargin)
         % Converts to @pid
         sys = pid.make(pid(ltipack_tfdata(blk),varargin{:}));
      end
      
      function sys = pidstd_(blk,varargin)
         % Converts to @pidstd
         sys = pidstd.make(pidstd(ltipack_tfdata(blk),varargin{:}));
      end
      
       
      %% ANALYSIS
      function p = pole_(blk)
         p = roots(blk.Parameterization_.den.Value);
      end
  
   end

   
   %% HIDDEN INTERFACES
   methods (Hidden)

      % CONTROLDESIGNBLOCK
      function Offset = getOffset(blk)
         % Get default feedthrough value
         blkParam = blk.Parameterization_;
         num = blkParam.num.Value;
         den = blkParam.den.Value;
         if numel(num)<numel(den)
            Offset = 0;
         else
            Offset = num(1);
         end
      end
      
      
      function D = ltipack_tfdata(blk)
         % Converts to ltipack.tfdata object
         [num,den,Ts] = tfdata_(blk);
         D = ltipack.tfdata(num,den,Ts);
      end
      
      
      function D = ltipack_ssdata(blk,~,S)
         % Converts to ltipack.ssdata object
         D = ss(ltipack_tfdata(blk));
         D.StateName = strseq([getName(blk) '.x'],1:blk.Np_);
         if nargin>1
            D.d = D.d-S;
         end
      end

      function D = ltipack_frddata(blk,freq,unit,~,S)
         % Converts to ltipack.frddata object
         D = frd(ltipack_tfdata(blk),freq,unit);
         if nargin>3
            D.Response = D.Response-S;
         end
      end      

      function str = getDescription(blk,ncopies)
         % Short description for block summary in LFT model display
         str = ctrlMsgUtils.message('Control:lftmodel:ltiblockTF5',...
            getName(blk),blk.Nz_,blk.Np_,ncopies);
      end
      
      % OPTIMIZATION
      function ns = numState(blk)
         % Size of A matrix from p2ss
         ns = blk.Np_;
      end
      
      function [a,b,c,d] = p2ss(blk,p)
         % Constructs realization from parameter vector p
         nz = blk.Nz_;  np = blk.Np_;
         num = p(1:nz+1,:).';   den = p(nz+3:nz+np+2,:).'; % ignore den(1)=1
         % A,B
         a = zeros(np);  b = zeros(np,1);
         if np>0
            a(1,:) = -den;  a(2:np+1:end) = 1;   b(1) = 1;
         end
         if nz<np
            d = 0;
            c = [zeros(1,np-nz-1) num];
         else
            % rel degree is zero
            d = num(1);
            c = num(:,2:np+1) - d * den;
         end
      end
      
      
      %------------------------------------------------
      function gj = gradUV(~,p,u,v,j)
         % Computes the gradient of the inner product
         %    phi(p) = Re(Trace(U'*[A(p) B(p);C(p) D(p)]*V))
         % with respect to the block parameters p(j) where j is a vector
         % of indices. The real or complex matrices U and V must have the
         % same number of columns.
         lden = size(u,1);
         lnum = length(p)-lden;
         w = v(1:lden-1,:);
         if lnum<lden
            g = [v(lden-lnum:lden-1,:) * u(lden,:)' ; 0 ; -w * u(1,:)'];
         else
            % biproper case
            g =  [-p(lnum+2:lnum+lden,:)'*w; w; ...
               zeros(1,size(u,2)) ; -p(1)*w] * u(lden,:)';  % C(p)
            g(1) = g(1) + v(lden,:) * u(lden,:)';  % D(p)
            g(lnum+2:lnum+lden,:) = g(lnum+2:lnum+lden,:) - w * u(1,:)';  % A(p)
         end
         gj = real(g(j));
      end
      
   end
   
   
   % STATIC METHODS FOR INITIALIZATION
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods (Static = true, Access = protected)
      
      % Default initialization of NUM,DEN
      [num,den] = defaultND(nz,np,Ts)
      % Random initialization of NUM,DEN
      [num,den] = randND(nz,np,Ts)
      
   end

   methods (Static, Hidden)
      
      function blk = loadobj(s)
         % Load filter for LTIBLOCK.TF objects
         blk = s;
         % Restore transient properties
         blk.Nz_ = numel(s.Parameterization_.num.Value)-1;
         blk.Np_ = numel(s.Parameterization_.den.Value)-1;
      end
      
   end

end




