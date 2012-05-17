function D = utCheckComputability(D,ResponseType,t,x0,u)
% Checks if requested system response is computable.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:54 $
ni = nargin;
ios = iosize(D);
Ts = D.Ts;

switch ResponseType
   case {'step','impulse','lsim','initial'}
      % Step and impulse responses
      nx = size(D.a,1);
      [isProper,D] = isproper(elimZeroDelay(D),'explicit');
      if ~isProper
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
      elseif strcmp(ResponseType(1),'i') && Ts==0 && ~isExplicitODE(D)
         % Impulse/initial not supported for models with internal delays
         throw(ltipack.utNoDelaySupport(ResponseType,Ts,'internal'))
      elseif ~isreal(D)
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationComplexData')
      end
      % Check consistency of time step with sample time
      if ni>2
         checkTimeVector(D,t)
      end
      % Check consistency of x0 with size of A
      if ni>3
         lx0 = length(x0);
         if lx0>0 && size(D.a,1)<nx
            ctrlMsgUtils.error('Control:general:NotSupportedSimulationSingularE')
         elseif lx0~=size(D.a,1) && (strcmp(ResponseType,'initial') || lx0>0)
            ctrlMsgUtils.error('Control:analysis:utCheckComputability4')
         end
      end
      % Check consistency of u with I/O size
      if ni>4 && size(u,2)~=ios(2)
         ctrlMsgUtils.error('Control:analysis:lsim1')
      end

   case 'rlocus'
      % Root locus
      if any(ios~=1)
         ctrlMsgUtils.error('Control:analysis:utCheckComputability2')
      elseif hasdelay(D)
         throw(ltipack.utNoDelaySupport('rlocus',Ts,'all'))
      elseif ~isreal(D)
          ctrlMsgUtils.error('Control:general:NotSupportedRootLocusComplexData')
      end
end
