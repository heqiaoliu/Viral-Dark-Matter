classdef RateConversion < ltioptions.Generic
    % Shared options for C2D, D2C, and D2D.
    
    % Copyright 1986-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:52:35 $
    
    properties
        % Rate conversion method (string, default = 'zoh')
        Method = 'zoh';
        
        % Prewarp frequency in rad/s (for 'tustin' method only). The default 
        % value is zero which corresponds to the standard Tustin method.
        PrewarpFrequency = 0;  
    end
    
    methods (Abstract, Access=protected)
       [MethodList,ErrID] = getSupportedMethods(this)
    end
    
    methods
       
       function this = set.Method(this,value)
          % SET method for Method property
          [MethodList,ErrID] = getSupportedMethods(this);
          M = ltipack.matchKey(value,MethodList);
          if isempty(M)
             ctrlMsgUtils.error(ErrID)
          else
             if strcmp(M,'prewarp')
                ctrlMsgUtils.error('Control:transformation:RateConversion1',getCommandName(this))
             end
             this.Method = M;
          end
       end
       
       function this = set.PrewarpFrequency(this,value)
          % SET method for PrewarpFrequency property
          if ~(isnumeric(value) && isscalar(value) && value>=0) % isNonNegativeScalar
             ctrlMsgUtils.error('Control:transformation:RateConversion2',getCommandName(this))
          end
          this.PrewarpFrequency = double(value);
       end
       
    end
    
end