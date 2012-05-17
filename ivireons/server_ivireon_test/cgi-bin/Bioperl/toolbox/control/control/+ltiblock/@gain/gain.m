classdef gain < ltiblock.Parametric
   %LTIBLOCK.GAIN  Parametric static gain.
   %
   %   BLK = LTIBLOCK.GAIN(NAME,NY,NU) creates a parametric gain block BLK  
   %   with NY outputs and NU inputs. The string NAME specifies the block name.
   %
   %   BLK = LTIBLOCK.GAIN(NAME,G) uses the gain value G to dimension the  
   %   block and initialize the block parameters.
   %
   %   Use the BLK.Gain.Free field to specify additional structure or fix 
   %   specific entries in MIMO gains G. For example, BLK.Gain.Free(1,2)=true
   %   designates G(1,2) as a free parameter, and BLK.Gain.Free(1,2)=false 
   %   fixes G(1,2) to its current value.
   %
   %   Example: To parameterize 2-by-2 gain matrices of the form [g1 0;0 g2], 
   %   type
   %      blk = ltiblock.gain('g',zeros(2));
   %      blk.Gain.Free = [1 0;0 1];   % fix off-diagonal entries to zero
   %
   %   See also LTIBLOCK.SS, LTIBLOCK.TF, CONTROLDESIGNBLOCK.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:11 $
   
   properties (Access = public, Dependent)   
      % Gain matrix (scalar- or matrix-valued parameter).
      %
      % Use this property to interact with the tunable parameters of
      % parametric gains. For example, you can initialize parameters, 
      % access their current values, and fix or free some parameters.
      Gain
   end
   
   properties (Access = protected)
      % Storage properties
      Gain_  % param.Continuous
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

      function blk = gain(Name,varargin)
         ni = nargin;
         % Validate Name
         if ni>0 && ~isvarname(Name)
            ctrlMsgUtils.error('Control:lftmodel:BlockName1')
         end
         % Check remaining input arguments
         try
            switch ni
               case 0
                  ny = 0;  nu = 0;
               case 2
                  % ltiblk.ss(name,GainMatrix)
                  g0 = varargin{1};
                  if ~(isnumeric(g0) && ndims(g0)==2)
                     ctrlMsgUtils.error('Control:lftmodel:ltiblockGain1')
                  end
                  [ny,nu] = size(g0);
                  g0 = double(g0);
               case 3
                  % ltiblk.gain(name,ny,nu)
                  if ~all(cellfun(@(x) isnumeric(x) && isscalar(x) && isreal(x) && ...
                        x==floor(x) && x>=0,varargin))
                     ctrlMsgUtils.error('Control:lftmodel:ltiblock1','gain')
                  end
                  ny = varargin{1};  nu = varargin{2};
                  g0 = zeros(ny,nu);
               otherwise
                  ctrlMsgUtils.error('Control:general:InvalidSyntaxForCommand','ltiblock.gain','ltiblock.gain')
            end
         catch ME
            throw(ME)
         end
         
         % Initialize block
         blk.IOSize_ = [ny,nu];
         if ni==0
            return
         end
         blk.Gain_ = param.Continuous('Gain',g0);
         blk.Ts_ = 0;
         blk.Name = Name;
      end
      
      function Value = get.Gain(blk)
         % GET method for Gain property
         Value = blk.Gain_;
      end
            
      function blk = set.Gain(blk,Value)
         % SET method for Gain property
         blk.Gain_ = pmodel.checkParameter(Value,'Gain',blk.IOSize_);
      end
      
      %----------------------------------------------
      function blk = init(blk,sys,varargin)
         %INIT  Initializes parametric gain block.
         %
         %   BLK = INIT(BLK,M) uses the matrix M to initialize the parametric 
         %   gain block BLK (see LTIBLOCK.GAIN).
         %
         %   BLK = INIT(BLK,SYS) uses the DC gain of the LTI model SYS to 
         %   initialize BLK.
         %
         %   BLK = INIT(BLK,...,'free') initializes only the free parameters
         %   in BLK.
         %
         %   See also LTIBLOCK.GAIN.
         if isnumeric(sys)
            dc = sys;
         else
            try
               dc = dcgain(sys);
            catch E
               ctrlMsgUtils.error('Control:lftmodel:ltiblockGain2')
            end
         end
         
         % Validate DC gain
         if hasInfNaN(dc)
            ctrlMsgUtils.error('Control:lftmodel:ltiblockGain3')
         elseif ~isequal(size(dc),iosize(blk))
            ctrlMsgUtils.error('Control:lftmodel:ltiblockGain4')
         end
         
         % Set parameters
         if nargin<3
            blk.Gain_.Value = dc;
         else
            gF = blk.Gain_.Free;
            blk.Gain_.Value(gF) = dc(gF);
            % Warn if some entries of SYS were dropped
            if any(dc(~gF)~=blk.Gain_.Value(~gF))
               ctrlMsgUtils.warning('Control:lftmodel:ltiblockGain5')
            end
         end
         
      end
      
      
   end
   

   %% SUPERCLASS INTERFACES
   methods (Access=protected)

      function displaySize(blk,sizes)
         % Display for "size(sys)"
         disp(ctrlMsgUtils.message('Control:lftmodel:SizeGAIN1',sizes(1),sizes(2)))
      end
      
      % PARAMETRICBLOCK
      function np = nparams_(blk,varargin)
         % Number of parameters
         if nargin>1
            % Number of free parameters
            np = numel(find(blk.Gain_.Free));
         else
            np = prod(blk.IOSize_);
         end
      end
      
      function isf = isfree_(blk)
         % True for free parameters
         isf = blk.Gain_.Free(:);
      end
      
      function p = getp_(blk,varargin)
         % Get vector of parameter values
         g = blk.Gain_;
         if nargin>1
            p = g.Value(g.Free);
         else
            p = g.Value;
         end
         p = p(:);
      end
      
      function blk = setp_(blk,p,varargin)
         % Set vector of parameter values
         ni = nargin;
         g = blk.Gain_;
         if ni>2
            np = numel(find(g.Free));
         else
            np = prod(blk.IOSize_);
         end
         if np~=length(p)
            ctrlMsgUtils.error('Control:pmodel:setp')
         elseif ni>2
            g.Value(g.Free) = p;
         else
            g.Value(:) = p;
         end
         blk.Gain_ = g;
      end
      
      function P = randp_(blk,N,varargin)
         % Generates random samples of model parameters.
         [ny,nu] = iosize(blk);
         if ny==1 && nu==1
            % SISO case: make sure to generate random samples with positive and negative signs
            P = 10.^(4*rand(1,N)-2);
            P(2:2:N) = -P(2:2:N);
         else
            P = sign(rand(ny*nu,N)-.5) .* 10.^(4*rand(ny*nu,N)-2);
         end
         if nargin>2
            P = P(isfree(blk),:);
         end
      end
            
   end
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% MODEL CHARACTERISTICS
      function boo = isreal_(blk)
         % Returns true if the current value is real
         boo = isreal(blk.Gain_.Value);
      end
      
      function boo = isstatic_(~)
         % Gains are always static
         boo = true;
      end
      
      function ns = order_(blk) %#ok<*MANU>
         ns = 0;
      end
      
      function [a,b,c,d,Ts] = ssdata_(blk,varargin)
         % Quick access to explicit state-space data
         d = blk.Gain_.Value;
         [ny,nu] = size(d);
         a = [];  b = zeros(0,nu);  c = zeros(ny,0);
         Ts = blk.Ts_;
      end      

      %% CONVERSIONS
      function sys = ss_(blk,varargin)
         % Converts to @ss
         [a,b,c,d,Ts] = ssdata_(blk);
         sys = ss(a,b,c,d,Ts);
      end

      %% ANALYSIS
      function p = pole_(blk)
         p = zeros(0,1);
      end

   end

         
   %% HIDDEN INTERFACES
   methods (Hidden)
      
      % CONTROLDESIGNBLOCK INTERFACE
      function Offset = getOffset(blk)
         % Get default feedthrough value
         Offset = blk.Gain_.Value;
      end
      
      function D = ltipack_ssdata(blk,~,S)
         % Converts to ltipack.ssdata object
         [a,b,c,d,Ts] = ssdata_(blk);
         if nargin>1
            d = d-S;
         end
         D = ltipack.ssdata(a,b,c,d,[],Ts);
      end
      
      function str = getDescription(blk,ncopies)
         % Short description for block summary in LFT model display
         nyu = iosize(blk);
         ioSize = sprintf('%dx%d',nyu(1),nyu(2));
         str = ctrlMsgUtils.message('Control:lftmodel:ltiblockGain5',...
            getName(blk),ioSize,ncopies);
      end
      
      % OPTIMIZATION INTERFACE
      function ns = numState(blk) %#ok<*MANU>
         ns = 0;
      end
      
      function [a,b,c,d] = p2ss(M,p)
         % Constructs realization A(p),B(p),C(p),D(p) from parameter vector p
         ios = M.IOSize_;  ny = ios(1);  nu = ios(2);
         a = [];
         b = zeros(0,nu);
         c = zeros(ny,0);
         d = reshape(p,[ny nu]);
      end
      
      function gj = gradUV(~,~,u,v,j)
         % Computes the gradient of the inner product
         %    phi(p) = Re(Trace(U'*[A(p) B(p);C(p) D(p)]*V))
         % with respect to the block parameters p(j) where j is a vector
         % of indices. The real or complex matrices U and V must have the
         % same number of columns.
         G = real(u*v');
         gj = reshape(G(j),[numel(j) 1]);
      end
         
   end


end




