function setValue(this,Value,Format,units)
% SETVALUE sets the value for the pzgroup based on flag
%

%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2007/12/14 14:28:57 $

if isscalar(Value) && isreal(Value)
    if isempty(this.Pole)
        this.Zero = Value;
    else
        this.Pole =  Value;
    end
else
    ctrlMsgUtils.error('Control:compDesignTask:PZGroupReal1')
end

