function setValue(this,Value,Format,units)
% SETVALUE sets the value for the pzgroup based on flag
%
% Format = 1,  Value =  [zero;pole]
% Format = 2,  Value =  [PhaseMax;Wmax]


%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:28:56 $

if ~isreal(Value)
    ctrlMsgUtils.error('Control:compDesignTask:PZGroupLeadLag1')
end

if Format == 1

    this.Zero = Value(1);
    this.Pole =  Value(2);

else
    
    if nargin < 4
        units.FrequencyUnits = 'rad/s';
        units.PhaseUnits = 'rad';
    end
    Phasem = unitconv(Value(1),units.PhaseUnits,'rad');
    Wm = unitconv(Value(2),units.FrequencyUnits,'rad/s');
    
    maxphasevalue = asin(1-eps); % Range imposed on valid phase inputs Phasem < pi/4
    if (abs(Phasem) > maxphasevalue)
        ZeroLoc = NaN;
        PoleLoc = NaN;
    else
        % Zero = alpha * Pole
        alpha = (1-sin(Phasem))/(1+sin(Phasem));

        ZeroLoc = -Wm*sqrt(alpha);
        PoleLoc = ZeroLoc/alpha;
        
        Ts = this.Parent.Ts;
        if (Ts ~= 0)
            ZeroLoc = exp(ZeroLoc*Ts);
            PoleLoc = exp(PoleLoc*Ts);
        end
    end
    this.Zero = ZeroLoc;
    this.Pole =  PoleLoc;

end
