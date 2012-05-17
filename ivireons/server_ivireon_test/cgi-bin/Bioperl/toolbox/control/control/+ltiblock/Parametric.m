classdef Parametric < ltipack.SingleRateSystem & ParametricBlock
   % Parametric LTI blocks.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.4 $  $Date: 2010/05/10 16:58:10 $

   % Adds "single-rate system" attribute to ParametricBlock.
   % State-space conversion support:
   %            ssdata_
   %      blk   ------->   A,B,C,D
   %       |                 |
   %       +----->  p  ------+
   %        getp        p2ss
   
   properties (Access = protected)
      % Storage property for sampling time
      Ts_
   end
            
   %% PROTECTED INTERFACES
   methods (Access = protected)
      
      % INDEXING SUPPORT
      function M = subparen(blk,indices)
         % Indexing forces conversion to GENSS
         M = subparen(genss(blk),indices);
      end
      
      % DYNAMICSYSTEM
      function sys = setName_(sys,Value)
         % Force Name to be a variable name
         if isvarname(Value)
            sys.Name_ = Value;
         else
            ctrlMsgUtils.error('Control:lftmodel:BlockName1')
         end
      end
      
      % SINGLERATESYSTEM
      function Ts = getTs_(blk)
         Ts = blk.Ts_;
      end
      
      function blk = setTs_(blk,Ts)
         blk.Ts_ = Ts;
      end
      
   end
   
   
   %% HIDDEN INTERFACES
   methods (Hidden)
            
      % CONTROLDESIGNBLOCK
      function D = ltipack_ssdata(blk,~,S)
         % Converts to ltipack.ssdata object
         [a,b,c,d,Ts] = ssdata_(blk);
         if nargin>1
            d = d-S;
         end
         D = ltipack.ssdata(a,b,c,d,[],Ts);
      end

      function D = ltipack_frddata(blk,freq,unit,varargin)
         % Converts to ltipack.frddata object
         D = frd(ltipack_ssdata(blk,varargin{:}),freq,unit);
      end
      
      function M = numeric_array(blk,~,S)
         % Converts to double array
         [a,~,~,M] = ssdata_(blk);
         if ~isempty(a)
            ctrlMsgUtils.error('Control:lftmodel:double')
         elseif nargin>1
            M = M-S;
         end
      end

   end
   

   %% DATA ABSTRACTION INTERFACE
   % Note: Default implementation geared to blocks with state-space representation
   methods (Access = protected)

      %% MODEL CHARACTERISTICS
      function boo = isstable_(blk)
         % Check stability
         p = pole(blk);
         if blk.Ts_==0
            boo = all(real(p)<0);
         else
            boo = all(abs(p)<1);
         end
         boo = double(boo);
      end
      
      function [a,b,c,d,e,Ts] = dssdata_(blk,varargin)
         % Quick access to descriptor state-space data
         [a,b,c,d] = ssdata_(blk,varargin{:});
         e = eye(size(a));
         Ts = blk.Ts_;
      end
      
      function [num,den,Ts] = tfdata_(blk,varargin)
         % Quick access to transfer function data
         Data = tf(ltipack_ssdata(blk));
         num = Data.num;  den = Data.den;  Ts = blk.Ts_;
      end      
      
      function [z,p,k,Ts] = zpkdata_(blk,varargin)
         % Quick access to ZPK data
         Data = zpk(ltipack_ssdata(blk));
         z = Data.z;  p = Data.p;  k = Data.k;  Ts = blk.Ts_;
      end
      
      function sys = checkComputability(blk,ResponseType,varargin)
         % Treat as state-space model
         sys = checkComputability(ss(blk),ResponseType,varargin{:});
      end
     
      %% INDEXING
      function M = createLHS(~)
         % Creates LHS in assignment. Returns 0x0 GENSS 
         M = genss();
      end
      
      %% ANALYSIS
      function varargout = dcgain_(blk)
         [varargout{1:nargout}] = dcgain_(ss(blk));
      end
      
      function fresp = evalfr_(blk,s)
         fresp = evalfr(ltipack_ssdata(blk),s);
      end
      
      function [h,SingularWarn] = freqresp_(blk,w)
         [h,SingularWarn] = fresp(ltipack_ssdata(blk),w);
      end
      
      function s = allmargin_(blk)
         s = allmargin_(ltipack_ssdata(blk));
      end
      
      function fb = bandwidth_(blk,drop)
         fb = bandwidth(ltipack_ssdata(blk),drop);
      end
      
      function n = normh2_(blk)
         n = normh2(ltipack_ssdata(blk));
      end
      
      function [n,fpeak] = norminf_(blk,tol)
         [n,fpeak] = norminf(ltipack_ssdata(blk),tol);
      end
      
      function [z,g] = zero_(blk,varargin)
         [z,g] = zero(ltipack_ssdata(blk));
      end      
      
      %% TRANSFORMATIONS
      function blk = conj_(blk)
      end
      
      function sys = ctranspose_(blk)
         sys = ctranspose_(ss(blk));
      end
      
      function sys = uminus_(blk)
         sys = uminus_(genss(blk));
      end
      
      function sys = inv_(blk)
         sys = inv_(genss(blk));
      end
      
      function sys = mpower_(blk,k)
         sys = mpower_(genss(blk),k);
      end
      
      function sys = repsys_(blk,s)
         sys = repsys_(genss(blk),s);
      end
      
      function varargout = c2d_(blk,Ts,options)
         [varargout{1:nargout}] = c2d_(ss(blk),Ts,options);
      end
         
      function sys = d2c_(blk,options)
         sys = d2c_(ss(blk),options);
      end
      
      function sys = d2d_(blk,Ts,options)
         sys = d2d_(ss(blk),Ts,options);
      end
      
      function sys = upsample_(blk,L)
         sys = upsample_(ss(blk),L);
      end
      
      function [blk,icmap] = delay2z_(blk)
         if isa(blk,'StateSpaceModel')
            icmap = eye(order(blk));
         else
            icmap = [];
         end
      end
      
      function blk = pade_(blk,varargin)
      end
     
      function varargout = stabsep_(blk,Options)
         [varargout{1:nargout}] = stabsep_(ss(blk),Options);
      end
      
      function varargout = modsep_(blk,varargin)
         [varargout{1:nargout}] = modsep_(ss(blk),varargin{:});
      end
      
      function varargout = minreal_(blk,tol,dispflag)
         [varargout{1:nargout}] = minreal_(ss(blk),tol,dispflag);
      end
      
      function rsys = balred_(blk,orders,BalData,Options)
         rsys = balred_(ss(blk),orders,BalData,Options);
      end
      
      %% STATE-SPACE MODELS
      function [sys,xkeep] = sminreal_(blk)
         [sys,xkeep] = sminreal_(ss(blk));
      end
      
      function W = gram_(blk,type)
         W = gram_(ss(blk),type);
      end
      
      function sys = modred_(blk,method,elim)
         sys = modred_(ss(blk),method,elim);
      end
      
   end
   
   
end
