classdef ss < ltiblock.Parametric & StateSpaceModel
   %LTIBLOCK.SS  Fixed-order parametric state-space model.
   %
   %   BLK = LTIBLOCK.SS(NAME,NX,NY,NU) creates a continuous-time parametric  
   %   state-space block BLK with NX states, NY outputs, and NU inputs. 
   %   The string NAME specifies the block name.
   %
   %   BLK = LTIBLOCK.SS(NAME,NX,NY,NU,TS) creates a discrete-time parametric 
   %   state-space block BLK with sampling time TS.
   %
   %   BLK = LTIBLOCK.SS(NAME,NX,NY,NU,...,AS) restricts the A matrix to one 
   %   of the following structures:
   %      AS='tridiag'     A is tridiagonal
   %      AS='full'        A is full (every entry is a free parameter)
   %      AS='companion'   A is in companion form (see CANON).
   %   The default parameterization uses a tridiagonal A matrix. Both 'tridiag' 
   %   and 'companion' are more compact (fewer parameters) than 'full'. Use 
   %   BLK.a.Free, BLK.b.Free,... to specify additional structure or fix 
   %   specific entries of A,B,C,D. For example, set BLK.a.Free(i,j)=true to
   %   designate A(i,j) as a free parameter, or set BLK.a.Free(i,j)=false to
   %   fix A(i,j) to its current value.
   %
   %   BLK = LTIBLOCK.SS(NAME,SYS,AS) uses the dynamic system SYS to dimension 
   %   the block, set its sampling time, and initialize the block parameters.
   %   SYS is first converted to a state-space model with structure AS. If AS
   %   is omitted, SYS is converted to tridiagonal state-space form.
   %
   %   Example: To create a tridiagonal parameterization of 5th-order SISO 
   %   models with zero D matrix, type
   %      blk = ltiblock.ss('demo',5,1,1);
   %      blk.d.Value = 0;      % set D=0
   %      blk.d.Free = false;   % fix D to zero
   %
   %   See also LTIBLOCK.TF, CONTROLDESIGNBLOCK, SS, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4.2.1 $ $Date: 2010/06/28 14:16:54 $

   properties (Access = public, Dependent)
      % A matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the state matrix A,
      % to initialize A, or to fix/free specific entries of A.
      a
      % B matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the input-to-state
      % matrix B, to initialize B, or to fix/free specific entries of B.
      b
      % C matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the state-to-output
      % matrix C, to initialize C, or to fix/free specific entries of C.
      c
      % D matrix (matrix-valued parameter).
      %
      % Use this property to read the current value of the feedthrough
      % matrix D, to initialize D, or to fix/free specific entries of D.
      % For example, you can fix D to zero by typing 
      %    blk.D.Value = 0;  blk.D.Free = false;
      d
      % State names (string vector, default = empty string for all states).
      %
      % You can set this property to:
      %   * A string for first-order models, for example, 'position'
      %   * A string vector for models with two or more states, for example,
      %     {'position' ; 'velocity'}
      % Use the empty string '' for unnamed states.
      StateName
      % State units (string vector, default = empty string for all states).
      %
      % Use this property to keep track of the units each state is expressed in.
      % You can set "StateUnit" to:
      %   * A string for first-order models, for example, 'm/s'
      %   * A string vector for models with two or more states, for example,
      %    {'m' ; 'm/s'}
      StateUnit
   end
   
   properties (Access = protected)
      % Model parameterization (pmodel.ss)
      Parameterization_
   end
   
   properties (Access = protected, Transient)
      Nx_  % caches number of states
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
   
   
   methods
      
      function blk = ss(Name,varargin)
         ni = nargin;
         % Validate Name and detect Structure
         if ni>0
            if ~isvarname(Name)
               ctrlMsgUtils.error('Control:lftmodel:BlockName1')
            end
            ixS = find(cellfun(@ischar,varargin),1);
            if isempty(ixS)
               Structure = 'tridiagonal';  % default
            else
               Structure = ltipack.matchKey(varargin{ixS},{'full','tridiagonal','companion'});
               if isempty(Structure)
                  ctrlMsgUtils.error('Control:lftmodel:ltiblockSS1')
               end
               varargin(:,ixS) = [];  ni = ni-1;
            end
         end
         % Check remaining input arguments
         try
            switch ni
               case 0
                  ny = 0;  nu = 0;  nx = 0;
               case 2
                  % ltiblock.ss(name,SSObject)
                  sys = varargin{1};
                  try
                     sys = ss.cast(sys,'explicit');
                  catch E
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockSS2')
                  end
                  if nmodels(sys)~=1
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockSS3')
                  end
                  [a0,b0,c0,d0,Ts] = ssdata(sys);
                  [ny,nu] = size(d0);   nx = size(a0,1);
                  [a0,b0,c0,d0] = ltiblock.ss.initStruct(Structure,a0,b0,c0,d0);
               case {4,5}
                  % ltiblock.ss(name,nx,ny,nu,Ts)
                  if ~all(cellfun(@(x) isnumeric(x) && isscalar(x) && isreal(x) && ...
                        x==floor(x) && x>=0,varargin(1:3)))
                     ctrlMsgUtils.error('Control:lftmodel:ltiblock1','ss')
                  elseif ni==4
                     Ts = 0;
                  else
                     Ts = ltipack.utValidateTs(varargin{4});
                  end
                  [nx,ny,nu] = deal(varargin{1:3});
                  [a0,b0,c0,d0] = ltiblock.ss.defaultABCD(Structure,nx,ny,nu,Ts);
               otherwise
                  ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ltiblock.ss','ltiblock.ss')
            end
         catch ME
            throw(ME)
         end
         
         % Construct block
         blk.IOSize_ = [ny,nu];
         blk.Nx_ = nx;
         if ni==0
            return
         end
         blk.Ts_ = Ts;
         blk.Parameterization_ = pmodel.ss(a0,b0,c0,d0);
         if ni==2
            blk = copyMetaData(sys,blk);
            blk.StateName = sys.StateName;
            blk.StateUnit = sys.StateUnit;
         end
         blk.Name = Name;
         
         % Set model structure
         switch Structure(1)
            case 'f' % full
               aFree = true(nx);
            case 't' % tridiagonal
               aFree = false(nx);
               aFree([1:nx+1:nx^2,2:nx+1:nx^2,nx+1:nx+1:nx^2]) = true;
            case 'c' % companion
               aFree = false(nx);
               if nx>0
                  aFree(2:nx+1:end) = true;  aFree(1,:) = true;
               end
         end
         blk.Parameterization_.a.Free = aFree;
      end
                  
      function Value = get.a(blk)
         % GET method for A property
         try
            Value = blk.Parameterization_.a;
         catch %#ok<*CTCH>
            Value = [];  % ltiblock.ss()
         end
      end
      
      function Value = get.b(blk)
         % GET method for B property
         try
            Value = blk.Parameterization_.b;
         catch
            Value = [];
         end
      end
      
      function Value = get.c(blk)
         % GET method for C property
         try
            Value = blk.Parameterization_.c;
         catch
            Value = [];
         end
      end
      
      function Value = get.d(blk)
         % GET method for D property
         try
            Value = blk.Parameterization_.d;
         catch
            Value = [];
         end
      end
      
      function Value = get.StateName(blk)
         % GET method for StateName property
         try
            Value = blk.Parameterization_.StateName;
         catch
            Value = [];
         end
         if isempty(Value)
            Value = strseq(sprintf('%s.x',blk.Name),1:blk.Nx_);
         end
      end
      
      function Value = get.StateUnit(blk)
         % GET method for StateUnit property
         try
            Value = blk.Parameterization_.StateUnit;
         catch
            Value = [];
         end
         if isempty(Value)
            Value = repmat({''},[blk.Nx_ 1]);
         end
      end
      
      function blk = set.a(blk,Value)
         % SET method for A property
         blk.Parameterization_.a = pmodel.checkParameter(...
            Value,'a',blk.Nx_([1 1]));
      end
      
      function blk = set.b(blk,Value)
         % SET method for B property
         blk.Parameterization_.b = pmodel.checkParameter(...
            Value,'b',[blk.Nx_ blk.IOSize_(2)]);
      end
      
      function blk = set.c(blk,Value)
         % SET method for C property
         blk.Parameterization_.c = pmodel.checkParameter(...
            Value,'c',[blk.IOSize_(1) blk.Nx_]);
      end
      
      function blk = set.d(blk,Value)
         % SET method for D property
         blk.Parameterization_.d = pmodel.checkParameter(...
            Value,'d',blk.IOSize_);
      end
      
      function blk = set.StateName(blk,Value)
         % SET method for StateName property
         Value = ltipack.checkStateInfo(Value,'StateName');
         if ~(isequal(Value,[]) || numel(Value)==blk.Nx_)
            ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateName')
         end
         blk.Parameterization_.StateName = Value;
      end
      
      function blk = set.StateUnit(blk,Value)
         % SET method for StateUnit property
         Value = ltipack.checkStateInfo(Value,'StateUnit');
         if ~(isequal(Value,[]) || numel(Value)==blk.Nx_)
            ctrlMsgUtils.error('Control:ltiobject:ssProperties3','StateUnit')
         end
         blk.Parameterization_.StateUnit = Value;
      end
      
      
      %----------------------------------------------
      function blk = init(blk,sys,varargin)
         %INIT  Initializes parametric state-space block.
         %
         %   BLK = INIT(BLK,SYS) uses the LTI model SYS to initialize the  
         %   parametric state-space block BLK (see LTIBLOCK.SS). SYS is 
         %   first converted to a state-space model of matching order and
         %   structure before initializing the block parameters.
         %
         %   BLK = INIT(BLK,SYS,'free') initializes only the free parameters
         %   in BLK.
         %
         %   See also LTIBLOCK.SS.
         nx = blk.Nx_;
         Ts = blk.Ts_;
         if ~(isa(sys,'DynamicSystem') && nmodels(sys)==1)
            ctrlMsgUtils.error('Control:lftmodel:ltiblockSS3')
         end
         try
            sys = ss(sys,'explicit');
         catch E
            ctrlMsgUtils.error('Control:lftmodel:ltiblockSS7')
         end
         if ~(isequal(iosize(sys),blk.IOSize_) && sys.Ts==Ts)
            ctrlMsgUtils.error('Control:lftmodel:ltiblockSS8')
         end
         
         % Adjust order
         nxsys = order(sys);
         if nxsys<nx
            % Add extra states
            [a,b,c,d] = ltiblock.ss.defaultABCD('tridiag',nx-nxsys,ny,nu,Ts);
            t = 1e-4;
            sys = sys + ss(a,t*b,t*c,t^2*d);
         elseif nxsys>nx
            % Use reduced-order approximation
            try
               sys = balred(sys,nx);
            catch E
               ctrlMsgUtils.error('Control:lftmodel:ltiblockSS9')
            end
         end
         
         % Transform to desired structure
         [a,b,c,d] = ssdata(sys);
         try
            [a,b,c,d] = ltiblock.ss.initStruct(getStructure(blk),a,b,c,d);
         catch ME
            throw(ME)
         end
         
         % Initialize parameters
         blkParam = blk.Parameterization_;
         if nargin<3
            blkParam.a.Value = a;
            blkParam.b.Value = b;
            blkParam.c.Value = c;
            blkParam.d.Value = d;
         else
            aF = blkParam.a.Free;
            blkParam.a.Value(aF) = a(aF);
            bF = blkParam.b.Free;
            blkParam.b.Value(bF) = b(bF);
            cF = blkParam.c.Free;
            blkParam.c.Value(cF) = c(cF);
            dF = blkParam.d.Free;
            blkParam.d.Value(dF) = d(dF);
         end
         blk.Parameterization_ = blkParam;
      end
   
   
   end
   
   %% SUPERCLASS INTERFACES
   methods (Access=protected)

      function displaySize(blk,sizes)
         % Display for "size(sys)"
         disp(ctrlMsgUtils.message('Control:lftmodel:SizeSS1',sizes(1),sizes(2),blk.Nx_))
      end

      % PARAMETRIC BLOCK
      function np = nparams_(blk,varargin)
         % Number of parameters
         if nargin>1
            np = nparams(blk.Parameterization_,varargin{:});
         else
            np = prod(blk.IOSize_ + blk.Nx_);
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
         nx = blk.Nx_;  ios = blk.IOSize_;
         Astruct = getStructure(blk);
         
         % Generate random samples
         P = zeros(nparams_(blk),N);
         for j=1:N
            [a,b,c,d] = ltiblock.ss.randABCD(Astruct,nx,ios(1),ios(2),blk.Ts_);
            P(:,j) = [a(:);b(:);c(:);d(:)];
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
         [a,b,c,d] = ssdata_(blk);
         boo = isreal(a) && isreal(b) && isreal(c) && isreal(d);
      end
      
      function boo = isstatic_(blk)
         % Block is static if A=[] (note: order cannot change after construction)
         boo = isempty(blk.Parameterization_.a.Value);
      end
      
      function ns = order_(blk)
         % Get number of states
         ns = blk.Nx_;
      end

      function [a,b,c,d,Ts] = ssdata_(blk,varargin)
         % Quick access to explicit state-space data
         blkParam = blk.Parameterization_;
         a = blkParam.a.Value;
         b = blkParam.b.Value;
         c = blkParam.c.Value;
         d = blkParam.d.Value;
         Ts = blk.Ts_;
      end
      
      %% ANALYSIS
      function p = pole_(blk)
         a = blk.Parameterization_.a.Value;
         if hasInfNaN(a)
            p = NaN(size(a,1),1);
         else
            p = eig(a);
         end
      end
      
   end
   
   
   %% HIDDEN INTERFACES
   methods (Hidden)

      % CONTROLDESIGNBLOCK
      function Offset = getOffset(blk)
         % Get default feedthrough value
         Offset = blk.Parameterization_.d.Value;
      end
      
      function D = ltipack_ssdata(blk,~,S)
         % Converts to ltipack.ssdata object
         [a,b,c,d,Ts] = ssdata_(blk);
         if nargin>1
            d = d-S;
         end
         D = ltipack.ssdata(a,b,c,d,[],Ts);
         % Note: Use default names <blkname>.xj when unspecified
         D.StateName = blk.StateName;
         D.StateUnit = blk.Parameterization_.StateUnit;
      end
      
      function str = getDescription(blk,ncopies)
         % Short description for block summary in LFT model display
         nyu = iosize(blk);
         ioSize = sprintf('%dx%d',nyu(1),nyu(2));
         str = ctrlMsgUtils.message('Control:lftmodel:ltiblockSS6',...
            getName(blk),ioSize,blk.Nx_,ncopies);
      end
      
      % OPTIMIZATION
      function ns = numState(blk)
         % Size of A matrix from p2ss
         ns = blk.Nx_;
      end
      
      function [a,b,c,d] = p2ss(blk,p)
         % Constructs realization A(p),B(p),C(p),D(p) from parameter vector p
         nx = blk.Nx_;
         s = blk.IOSize_;  ny = s(1);  nu = s(2);
         i1 = 0;   i2 = nx^2;      a = reshape(p(i1+1:i2),nx,nx);
         i1 = i2;  i2 = i1+nx*nu;  b = reshape(p(i1+1:i2),nx,nu);
         i1 = i2;  i2 = i1+nx*ny;  c = reshape(p(i1+1:i2),ny,nx);
         i1 = i2;  i2 = i1+ny*nu;  d = reshape(p(i1+1:i2),ny,nu);
      end
      
      function gj = gradUV(blk,~,u,v,j)
         % Computes the gradient of the inner product
         %    phi(p) = Re(Trace(U'*[A(p) B(p);C(p) D(p)]*V))
         % with respect to the block parameters p(j) where j is a vector
         % of indices. The real or complex matrices U and V must have the
         % same number of columns.
         Gm = real(u*v');
         [rs,cs] = size(Gm);
         ios = blk.IOSize_;
         ny = ios(1);  nx = rs-ny;
         % Reorder entries
         np = rs*cs;
         k = nx*cs;
         g = zeros(np,1);
         g(1:k) = Gm(1:nx,:);
         g(k+1:np) = Gm(nx+1:nx+ny,:);
         % Select relevant entries
         gj = g(j);
      end
               
   end
   
   
   %% UTILITIES
   methods (Access = protected)

      function s = getStructure(blk)
         % Looks for tridiagonal or companion structure in A matrix
         aF = blk.Parameterization_.a.Free;
         n = size(aF,1);
         aF1 = aF;  aF1([1:n+1:n^2,2:n+1:n^2,n+1:n+1:n^2]) = false;
         aF2 = aF;  aF2(1,:) = false; aF2(2:n+1:n^2) = false;
         if n>2 && ~any(aF1(:))
            s = 'tridiag';
         elseif n>1 && ~any(aF2(:))
            s = 'companion';
         else
            s = 'full';
         end
      end
      
   end
   
   %% STATIC METHODS
   methods (Static, Access = protected)
      
      [a,b,c,d] = defaultABCD(Astruct,nx,ny,nu,Ts)
      [a,b,c,d] = randABCD(Astruct,nx,ny,nu,Ts)
            
      function [a,b,c,d] = initStruct(AStruct,a,b,c,d)
         % Transforms A,B,C,D to the specified structure
         nx = size(a,1);
         switch AStruct(1)
            case 't'
               % Make A tridiagonal if not already
               as = a;  
               as([1:nx+1:nx^2,2:nx+1:nx^2,nx+1:nx+1:nx^2]) = 0;
               if norm(as,1)>0
                  [T,a] = bdschur(a,1e8);
                  b = T\b;
                  c = c*T;
                  % Discard entries above superdiagonal
                  a = tril(a,1);
               end
            case 'c'
               % Make A a companion matrix if not already
               as = a;
               as(1,:) = 0;  as(2:nx+1:nx^2) = 0;
               if norm(as,1)>0
                  ctrlMsgUtils.error('Control:lftmodel:ltiblockSS5')
               end
         end
      end
            
   end
   
   methods (Static, Hidden)
      
      function blk = loadobj(s)
         % Load filter for LTIBLOCK.SS objects
         blk = s;
         % Restore transient property
         blk.Nx_ = size(s.Parameterization_.a.Value,1);
      end
      
   end
      
end

