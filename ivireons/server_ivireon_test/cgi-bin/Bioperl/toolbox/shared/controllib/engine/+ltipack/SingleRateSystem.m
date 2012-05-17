classdef (Hidden) SingleRateSystem < DynamicSystem
   % Time-invariant, single-rate system.
   %
   %   @SingleRateSystem manages the sample time of single-rate dynamic 
   %   systems.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.3 $  $Date: 2010/03/31 18:35:57 $
      
   properties (Access = public, Dependent)
      % Sampling time (in the unit specified by "TimeUnit")
      %
      % The sampling time should be set to
      %   * zero for continuous-time systems
      %   * the sampling period for discrete-time systems
      %   * -1 for discrete-time systems with unspecified sampling rate.
      % The default value is zero. 
      %
      % Note that changing the value of Ts has no impact on the system data  
      % and does not amount to discretizing or resampling the system dynamics. 
      % Use C2D, D2C, or D2D for sampling rate conversions.
      Ts
   end

   % PUBLIC METHODS
   methods      
      
      function Ts = get.Ts(sys)
         % GET function for Ts property: Delegate to getTs method (implemented
         % by subclasses)
         Ts = getTs_(sys);
      end
      
      function sys = set.Ts(sys,Ts)
         % SET function for Ts property: Validate data and defer to setTs_
         sys = setTs_(sys,ltipack.utValidateTs(Ts));
      end
           
   end
   
   methods (Hidden)
      
      function dispTs(sys,StaticFlag)
         % Displays sampling time info
         % Display sample time (for discrete-time models only)
         Ts = getTs_(sys);
         if ~StaticFlag,
            if Ts<0,
               fprintf('Sampling time: unspecified\n')
            elseif Ts>0,
               fprintf('Sampling time: %0.5g\n',Ts)
            end
         end
      end
  
   end
   
   methods(Access = protected)
      
      function [sys1,sys2] = matchSamplingTime(sys1,sys2)
         % Checks that SYS1 and SYS2 share the same sampling time
         % (ignoring static models). On output, both systems have 
         % the same sampling time. An error is thrown if the sampling 
         % times are incompatible.
         Ts1 = getTs_(sys1);
         Ts2 = getTs_(sys2);
         if Ts1~=Ts2
            DynamicFlag1 = ~isstatic_(sys1);
            DynamicFlag2 = ~isstatic_(sys2);
            HardValue1 = (Ts1>0 || (Ts1==0 && DynamicFlag1));
            HardValue2 = (Ts2>0 || (Ts2==0 && DynamicFlag2));
            if (HardValue1 && HardValue2) || (DynamicFlag1 && DynamicFlag2 && xor(Ts1==0,Ts2==0))
               % Inconsistent when both sample times are fully specified, or both
               % models have dynamics and one is continuous while the other is
               % discrete
               ctrlMsgUtils.error('Control:combination:SampleTimeMismatch')
            elseif Ts1>0 || Ts2>0 || ~(DynamicFlag1 || DynamicFlag2)
               % Note: Ts immaterial when both models are static
               Ts = max(Ts1,Ts2);
            else
               Ts = DynamicFlag1 * Ts1 + DynamicFlag2 * Ts2;
            end
            sys1 = setTs_(sys1,Ts);
            sys2 = setTs_(sys2,Ts);
         end
      end
                        
      function varargout = matchSamplingTimeN(varargin)
         % Checks that SYS1,SYS2,...,SYSN share the same sampling time
         % (ignoring static models). On output, all systems have 
         % the same sampling time. This version of matchSamplingTime is
         % designed for N-ary operations like REPLACEBLOCK. 
         varargout = varargin;
         nsys = length(varargin);
         % Acquire sampling times (performance optimization)
         TsLog = zeros(nsys,1);
         for j=1:nsys
            TsLog(j) = getTs_(varargin{j});
         end
         % Find common sampling time TS if not all equal
         if any(diff(TsLog))
            Ts = TsLog(1);
            DynamicFlag = ~isstatic(varargin{1});
            for j=2:nsys
               Tsj = TsLog(j);
               dfj = ~isstatic(varargin{j});
               if Tsj~=Ts
                  % Reconcile sampling times
                  HardValue = (Ts>0 || (Ts==0 && DynamicFlag));
                  hvj = (Tsj>0 || (Tsj==0 && dfj));
                  if (HardValue && hvj) || (DynamicFlag && dfj && xor(Ts==0,Tsj==0))
                     % Inconsistent when both sample times are fully specified, or both
                     % models have dynamics and one is continuous while the other is
                     % discrete
                     ctrlMsgUtils.error('Control:combination:SampleTimeMismatch')
                  elseif Ts>0 || Tsj>0 || ~(DynamicFlag || dfj)
                     % Note: Ts immaterial when both models are static
                     Ts = max(Ts,Tsj);
                  else
                     Ts = DynamicFlag * Ts + dfj * Tsj;
                  end
               end
               DynamicFlag = DynamicFlag || dfj;
            end
            % Adjust sampling times
            jx = find(TsLog~=Ts);
            for ct=1:numel(jx)
               varargout{jx(ct)} = setTs_(varargin{jx(ct)},Ts);
            end
         end
      end
      
   end
   
end
