classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) c2d < ltioptions.RateConversion
    % Options class for specifying options for C2D command.
    %
    % See also C2DOPTIONS.
    
    % Author: Murad Abu-Khalaf 4-Aug-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.3 $ $Date: 2010/02/08 22:52:38 $
    
    properties
        % Order of the Thiran filters used to approximate fractional delays
        % in the 'tustin' and 'matched' methods. For continuous-time delays
        % TAU that are not multiple of the sampling time TS, the remainder
        % of the division TAU/TS is called the fractional delay. The
        % default approximation order is zero, meaning that fractional
        % delays are rounded to the nearest integer. Nonzero orders result
        % in better phase matching near the DC frequency (Maximally flat
        % phase delay).
        FractDelayApproxOrder = 0;
        
        % When discretizing an identified model, this property controls
        % whether parameter covariance information is propagated to the
        % discrete model (for System Identification Toolbox only).
        % CovarEstimation = 'off';
        
    end
    
    properties (Hidden)
        % Controls whether extra states or internal delays are used to
        % model fractional delays (for state-space models only). The value
        % is either 'state' or 'delay', 'state' being the default.
        FractDelayModeling = 'state';
    end
    
    methods (Access=protected)
       
       function [MethodList,ErrID] = getSupportedMethods(~)
          MethodList = {'zoh','foh','impulse','tustin','matched','prewarp'};
          ErrID = 'Control:transformation:c2d06';
       end
       
       function cmd = getCommandName(~)
          cmd = 'c2d';
       end
       
    end
    
    methods
       
       % SET FractDelayApproxOrder property
       function this = set.FractDelayApproxOrder(this,value)
          if ~(isnumeric(value) && isscalar(value) && value>=0 && rem(value,1)==0)
             % isNonNegativeScalarInteger
             ctrlMsgUtils.error('Control:transformation:c2d14')
          end
          this.FractDelayApproxOrder = double(value);
       end
       
       % SET FractDelayModeling property
       function this = set.FractDelayModeling(this,value)
          M = ltipack.matchKey(value,{'state','delay'});
          if isempty(M)
             ctrlMsgUtils.error('Control:transformation:c2d15')
          else
             this.FractDelayModeling = M;
          end
       end
       
    end

end