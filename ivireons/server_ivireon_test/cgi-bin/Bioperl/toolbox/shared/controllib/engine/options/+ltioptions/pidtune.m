classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) pidtune < ltioptions.Generic
    % Options class for specifying PID design options
    %
    % See also PIDOPTIONS.
    
    %   Author(s): Rong Chen
    %   Copyright 2009-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.8.3 $  $Date: 2010/04/30 00:39:47 $
    
    properties
        CrossoverFrequency  = []
        PhaseMargin  = 60
        NumUnstablePoles = 0
    end
    
    methods (Access = protected)
       function cmd = getCommandName(~)
          cmd = 'pidtune';
       end       
    end
    
    methods
               
        function this = set.CrossoverFrequency(this,Value)
            this.CrossoverFrequency = checkWC(Value);
        end
        
        function this = set.PhaseMargin(this,Value)
            this.PhaseMargin = checkPM(Value);
        end
        
        function this = set.NumUnstablePoles(this,Value)
            this.NumUnstablePoles = checkNUP(Value);
        end
        
    end
    
end

% check whether value is valid for Formulas
function value = checkWC(value)
    if isempty(value)
        value = [];
    elseif isreal(value) && isscalar(value) && value>0 && value<inf
        value = double(value);
    else
        ctrlMsgUtils.error('Control:design:pidtune7');
    end
end
        
function value = checkPM(value)
    if isreal(value) && isscalar(value) && value>=0 && value<=90
        value = double(value);
    else
        ctrlMsgUtils.error('Control:design:pidtune8');
    end
end
        
function value = checkNUP(value)
    if isreal(value) && isscalar(value) && value>=0 && value<inf && (value-floor(value))==0
        value = double(value);
    else
        ctrlMsgUtils.error('Control:design:pidtune9');
    end
end

