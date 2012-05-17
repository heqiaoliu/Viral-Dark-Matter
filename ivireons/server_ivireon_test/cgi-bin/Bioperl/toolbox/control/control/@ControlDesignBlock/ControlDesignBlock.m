classdef ControlDesignBlock < InputOutputModel
   % Control Design Block objects.
   %
   %   Control Design blocks are a special type of input/output model designed 
   %   to facilitate specific control design tasks such as compensator tuning 
   %   and robustness analysis. You cannot combine a Control Design block  
   %   with any other model object, but you can use commands like TF or SS to
   %   convert it to a standard transfer function or state-space model for 
   %   further analysis.
   %
   %   All Control Design Block objects derive from the @ControlDesignBlock
   %   superclass. This class is not user-facing and cannot be instantiated. 
   %   User-facing subclasses of @ControlDesignBlock include parametric 
   %   (tunable) blocks such as ltiblock.gain, ltiblock.pid, and ltiblock.ss.
   %
   %   You can use the HINFSTRUCT command in the Robust Control Toolbox to
   %   automatically tune parametric Control Design blocks.
   %
   %   See also LTIBLOCK.GAIN, LTIBLOCK.PID, LTIBLOCK.SS, LTIBLOCK.TF, LTI/HINFSTRUCT.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:15 $

   %   Control Design blocks are non-combinable entities that can be connected 
   %   with systems or matrices to form LFT models.

   % CONTROL DESIGN BLOCK INTERFACE
   methods (Abstract, Hidden)
      % Offset (default static value)
      Offset = getOffset(blk)
      % Low-level recipe for converting to ltipack.ssdata
      D = ltipack_ssdata(blk)
      % Low-level recipe for converting to ltipack.frddata
      D = ltipack_frddata(blk,freq,unit)
      % Low-level recipe for converting to double array
      D = numeric_array(blk,varargin)
      % Block name
      Name = getName(blk)
      % Block description
      str = getDescription(blk,ncopies)
   end   
   
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% CONVERSIONS
      function A = double_(blk)
         A = numeric_array(blk);
      end
      
      function sys = ss_(blk,optflag)
         % Converts to @ss
         sys = ss.make(ltipack_ssdata(blk));
         if nargin>1
            sys = ss(sys,optflag);
         end
      end
      
      function sys = tf_(blk)
         % Converts to @tf
         sys = tf.make(tf(ltipack_ssdata(blk)));
      end
      
      function sys = zpk_(blk)
         % Converts to @zpk
         sys = zpk.make(zpk(ltipack_ssdata(blk)));
      end
      
      function sys = frd_(blk,varargin)
         % Converts to @frd
         sys = frd.make(ltipack_frddata(blk,varargin{:}));
      end
      
      function sys = pid_(blk,varargin)
         % Converts to @pid
         sys = pid.make(pid(ltipack_ssdata(blk),varargin{:}));
      end
      
      function sys = pidstd_(blk,varargin)
         % Converts to @pidstd
         sys = pidstd.make(pidstd(ltipack_ssdata(blk),varargin{:}));
      end
      
      function M = genmat_(blk)
         % Converts to @genmat (only defined for static blocks)
         if isa(blk,'StaticModel')
            [ny,nu] = iosize(blk);
            IC = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
            M = genmat.make(ltipack.lftdataM(IC,ltipack.LFTBlockWrapper(blk)));
         else
            ctrlMsgUtils.error('Control:lftmodel:genmat1')
         end
      end
      
      function M = umat_(blk)
         % Converts to @umat (only defined for uncertain static blocks)
         if isa(blk,'StaticModel')
            if isUncertain(blk)
               [ny,nu] = iosize(blk);
               IC = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
               M = umat.make(ltipack.lftdataM(IC,ltipack.LFTBlockWrapper(blk)));
            else
               % Replace block by its value
               M = umat.make(ltipack.lftdataM(numeric_array(blk),...
                  ltipack.LFTBlockWrapper.emptyBlockList()));
            end
         else
            ctrlMsgUtils.error('Robust:umodel:umat1')
         end
      end
      
      function sys = genss_(blk)
         % Converts to @genss
         [ny,nu] = iosize(blk);
         M = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
         IC = ltipack.ssdata([],zeros(0,ny+nu),zeros(ny+nu,0),M,[],localGetTs(blk));
         sys = genss.make(ltipack.lftdataSS(IC,ltipack.LFTBlockWrapper(blk)));
         sys.Name = getName(blk);
      end
      
      function sys = uss_(blk)
         % Converts to @uss
         if isUncertain(blk)
            [ny,nu] = iosize(blk);
            M = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
            IC = ltipack.ssdata([],zeros(0,ny+nu),zeros(ny+nu,0),M,[],localGetTs(blk));
            sys = uss.make(ltipack.lftdataSS(IC,ltipack.LFTBlockWrapper(blk)));
         else
            % Replace block by its value
            sys = uss.make(ltipack.lftdataSS(ltipack_ssdata(blk),...
                  ltipack.LFTBlockWrapper.emptyBlockList()));
         end
         sys.Name = getName(blk);
      end
      
      function sys = genfrd_(blk,freq,unit)
         % Converts to @genfrd
         [ny,nu] = iosize(blk);
         M = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
         IC = ltipack.frddata(repmat(M,[1 1 numel(freq)]),freq,localGetTs(blk));
         IC.FreqUnits = unit;
         sys = genfrd.make(ltipack.lftdataFRD(IC,ltipack.LFTBlockWrapper(blk)));
         sys.Name = getName(blk);
      end
      
      function sys = ufrd_(blk,freq,unit)
         % Converts to @ufrd
         if isUncertain(blk)
            [ny,nu] = iosize(blk);
            M = [zeros(ny,nu) , eye(ny) ; eye(nu) zeros(nu,ny)];
            IC = ltipack.frddata(repmat(M,[1 1 numel(freq)]),freq,localGetTs(blk));
            IC.FreqUnits = unit;
            sys = ufrd.make(ltipack.lftdataFRD(IC,ltipack.LFTBlockWrapper(blk)));
         else
            % Replace block by its value
            sys = ufrd.make(ltipack.lftdataFRD(ltipack_frddata(blk,freq,unit),...
                  ltipack.LFTBlockWrapper.emptyBlockList()));
         end
         sys.Name = getName(blk);
      end
      
   end
   
   %% PROTECTED UTILITIES
   methods (Access = protected)
      
      function BlockValues = checkBlockValues(M,BlockValues)
         % Validates block replacement values
         BlockSet = struct(M.Name,M);
         [BlockValues,isUsed] = ltipack.utCheckBlockValues(BlockValues,BlockSet);
         BlockValues = BlockValues(isUsed,:);
      end

   end
   
   
   %% HIDDEN UTILITIES
   methods (Hidden)
      
      function blk = replaceB2B_(blk,BlockValues)
         % Block-to-block substitution. BLOCKVALUES is a Nx2 cell array of 
         % block names and values.
         ix = find(strcmp(getName(blk),BlockValues(:,1)));
         if ~isempty(ix)
            blk = BlockValues{ix,2};
         end
      end
                  
      function varargout = hinfstruct(blk,varargin)
         % Extension to support raw blocks as closed-loop spec
         if isa(blk,'ControlDesignBlock')
            try
               [varargout{1:nargout}] = hinfstruct(genss(blk),varargin{:});
            catch ME
               throw(ME)
            end
         else
            % hinfstruct(garbage,blocks)
            ctrlMsgUtils.error('Robust:design:hinfstruct25')
         end
      end
      
   end
   
   
   %% STATIC METHODS
   methods (Static = true)
      % NSOPT support
      [Acl,Bcl,Ccl,Dcl,lftData] = evalLFT(A,B,C,D,pInfo,x)
      g = gradLFT(lftData,pInfo,x,u,v)
   end
   
end

%---------------------------------------------------------------------------
function Ts = localGetTs(blk)
% Get sampling time value for conversions to dynamic system types
if isa(blk,'ltipack.SingleRateSystem')
   Ts = blk.Ts;
else
   Ts = 0;
end
end
