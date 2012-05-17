classdef (Hidden = true) frddata < ltipack.ltidata
   % Class definition for @frddata (frequency response data)

   %   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
   %	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:36:09 $
   properties
      Frequency            % frequency vector
      FreqUnits = 'rad/s'; % frequency units
      Response             % response data
   end

   % RE: In FRDDATA objects, Delay.IO is used for I/O delays and
   %     Delay.Internal is never used. Delays that cannot be
   %     represented as I/O delays are absorbed into the data.

   methods
      
      function D = frddata(resp,freqs,Ts)
         % Constructs @frddata instance
         if nargin==3
            [ny,nu,nf] = size(resp);
            D.Frequency = freqs;
            D.Response  = resp;
            D.Ts = Ts;
            D.Delay = ltipack.utDelayStruct(ny,nu,false);
         end
      end
      
      %-----------------------
      function D = checkData(D)
         % Checks FRD data consistency.
         nf = length(D.Frequency);
         rsize = size(D.Response);
         if nf==0 && length(rsize)==2,
            % Special case for FREQ=[]
            D.Response = zeros([rsize nf]);
         else
            fdim = find(nf==[rsize 1]);
            if isempty(fdim) || fdim(end)>3
               ctrlMsgUtils.error('Control:ltiobject:frdProperties3',nf,size(D.Response,3))
            end
            fdim = fdim(end);
            if fdim<3
               rsize(fdim) = [];
               if ~all(rsize==1)
                  ctrlMsgUtils.error('Control:ltiobject:frdProperties4')
               else
                  D.Response = reshape(D.Response,[1,1,nf]);
               end
            end
         end
         
         % Sort by frequency
         [D.Frequency,isort] = sort(D.Frequency);
         D.Response = D.Response(:,:,isort);
      end
      
      %-----------------
      function [ny,nu] = iosize(D)
         % Returns I/O size of dynamical systems.
         %
         %   [NY,NU] = IOSIZE(SYS)
         %   S = IOSIZE(SYS) returns S = [NY NU].
         [ny,nu,~] = size(D.Response);  % NOTE: Data defines I/O size
         if nargout<2
            ny = [ny nu];
         end
      end
      
      %-----------------
      function D = ioperm(D,yperm,uperm)
         % Applies I/O permutations
         D.Delay.Input = D.Delay.Input(uperm);
         D.Delay.Output = D.Delay.Output(yperm);
         D.Delay.IO = D.Delay.IO(yperm,uperm);
         D.Response = D.Response(yperm,uperm,:);
      end
      
      %-----------------
      function D = createGain(Dref,G)
         % Wraps static gain into @frddata object
         freq = Dref.Frequency;
         D = ltipack.frddata(repmat(G,[1 1 numel(freq)]),freq,Dref.Ts);
         D.FreqUnits = Dref.FreqUnits;
      end
      
      %-----------------
      function D = appendGain(D,G)
         % Forms append(D,G) where G is a matrix
         R = D.Response;
         [rs,cs,nf] = size(R);
         [nyG,nuG] = size(G);
         RG = zeros(rs+nyG,cs+nuG,nf);
         RG(1:rs,1:cs,:) = R;
         for ct=1:nf
            RG(rs+1:rs+nyG,cs+1:cs+nuG,ct) = G;
         end
         D.Response = RG;
         D.Delay.Input = [D.Delay.Input ; zeros(nuG,1)];
         D.Delay.Output = [D.Delay.Output ; zeros(nyG,1)];
         D.Delay.IO = blkdiag(D.Delay.IO , zeros(nyG,nuG));
      end
      
      %----------- LFT support ------------------------
      function D = invLFT(D,nyu)
         % Computes Di such that inv(LFT(D,B)) = LFT(Di,B).
         % NYU is the number of external I/Os.
         if hasdelay(D)
            % Error if inverse is not causal
            ctrlMsgUtils.error('Control:transformation:inv1')
         end
         
         % Invert mapping from first NU inputs to first NY outputs
         R = D.Response;
         [rs,cs,nf] = size(R);
         sw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
         SingularFlag = false(nf,1);
         for ct=1:nf
            IC = R(:,:,ct);
            ICi = blkdiag(zeros(nyu),IC(nyu+1:rs,nyu+1:cs)) + ...
               [eye(nyu) ; IC(nyu+1:rs,1:nyu)] * ...
               (IC(1:nyu,1:nyu) \ [eye(nyu) , -IC(1:nyu,nyu+1:cs)]);
            SingularFlag(ct) = hasInfNaN(ICi);
            R(:,:,ct) = ICi;
         end
         
         if all(SingularFlag)
            ctrlMsgUtils.error('Control:transformation:invLFT1','REVISIT')
         end
         D.Response = R;
      end
            
      %--------------------------------
      function varargout = c2d(D,varargin) %#ok<*STOUT,*MANU>
         % Default = not supported
         ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','c2d','frd')
      end

      function varargout = d2c(D,varargin)
         % Default = not supported
         ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','d2c','frd')
      end

      function varargout = d2d(D,varargin)
         % Default = not supported
         ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','d2d','frd')
      end

   end
   
   methods(Access=protected)

      function [w,Focus] = parseFreqSpec(D,wspec)
         % Interprets W argument of BODE, NYQUIST,...
         f = unitconv(D.Frequency,D.FreqUnits,'rad/s');
         f = f(f>=0,:);
         if iscell(wspec)
            % Include FRD data in specified frequency range. Grid W covers
            % the intersection of [F(1),F(END)] with [WMIN,WMAX]
            wmin = wspec{1};  wmax = wspec{2};
            w = f(f>wmin & f<wmax,:);
            if ~isempty(f)
               % Add WMIN,WMX if straddled by FRD data
               if f(1)<=wmin && f(end)>=wmin, w = [wmin;w]; end
               if f(1)<=wmax && f(end)>=wmax, w = [w;wmax]; end
            end
         elseif isempty(wspec)
            % No grid or range specified: use FRD grid
            w = f;
         else
            % User-defined frequency vector
            w = wspec(:);
         end
         
         % Focus on the intersection of the ranges [w(1),w(end)] and [f(1),f(end)]
         if isempty(f) || isempty(w)  % no data to show
            Focus = [1 -1];  % for further processing below...
         else
            Focus = [max(w(1),f(1)),min(w(end),f(end))];
         end
      end

   end
   
   % Static methods
   methods(Static)
      function D = array(size)
         % Create a frddata array of a given size
         D = ltipack.frddata.newarray(size);
      end
      
      function D = default()
         % Fast construction of default 0x0 frddata
         D = ltipack.frddata;
         D.Frequency = zeros(0,1);
         D.Response = zeros(0,0,0);
         D.Ts = 0;   
         D.Delay = ltipack.utDelayStruct(0,0,false);
      end
      
      function D = loadobj(D)
         % Load filter for @ssdata
         if isfield(D.Delay,'Internal')
            % Pre-R2009b: Delay structure had Internal field for all model types
            D.Delay = rmfield(D.Delay,'Internal');
         end
      end
   end

   % Protected static methods
   methods(Static=true, Access=protected)
      
      function FocusInfo = fSetFocus(focus)
         % Used by frequency response functions
         % Adjust FOCUS when empty or a single point
         if focus(1)>focus(2)
            % No data in [w(1),w(end)]: use arbitrary focus
            focus = [.1 1];
            FocusInfo = struct('Focus',focus,'DynRange',focus,'Soft',true);
         else
            if focus(1)==focus(2)
               % single data point: focus around it
               df = 10^.5;
               focus = [focus(1)/df,focus(1)*df];
            end
            FocusInfo = struct('Focus',focus,'DynRange',focus,'Soft',false);
         end
      end
      
   end

end
