function D = utCheckComputability(D,ResponseType,t,x0,u) %#ok<INUSL>
% Checks if requested system response is computable.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:28 $
ios = iosize(D);

switch ResponseType
   case {'step','impulse'}
      % Step and impulse responses
      if ~isproper(D)
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
      elseif ~isreal(D)
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationComplexData')
      end
      % Check consistency of time step with sample time
      checkTimeVector(D,t)
      
   case 'initial'
      % Initial response
      ctrlMsgUtils.error('Control:analysis:utCheckComputability1')
            
   case 'lsim'
      % Linear simulation
      if ~isproper(D)
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationImproperSys')
      elseif ~isreal(D)
         ctrlMsgUtils.error('Control:general:NotSupportedSimulationComplexData')
      elseif nargin>2
         % Validate T,U
         checkTimeVector(D,t)
         if size(u,2)~=ios(2)
            ctrlMsgUtils.error('Control:analysis:lsim1')
         end
      end
      
   case 'rlocus'
      % Root locus
      if any(ios~=1)
          ctrlMsgUtils.error('Control:analysis:utCheckComputability2')
      elseif hasdelay(D)
         throw(ltipack.utNoDelaySupport('rlocus',D.Ts,'all'))
      elseif ~isreal(D)
          ctrlMsgUtils.error('Control:general:NotSupportedRootLocusComplexData')
      end
end
