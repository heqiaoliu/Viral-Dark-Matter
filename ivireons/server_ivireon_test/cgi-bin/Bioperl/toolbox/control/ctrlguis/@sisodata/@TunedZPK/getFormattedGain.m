function Gain = getFormattedGain(this,flag)
%GETGAIN  Gets the formatted gain of the TunedZPKdata.
%
%   Gain = getFormattedGain(this)
%   Gain = getFormattedGain(this,'mag')
%   Gain = getFormattedGain(this,'sign')
%
%   The formatted gain is the ZPK gain divided by the format factor 
%   (see FORMATFACTOR for details).

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2006/06/20 20:01:08 $



if strncmpi(this.Format,'z',1)
    Gain = this.getZPKGain;
else
    Gain = this.Gain * formatfactor(this,'t');
end

if nargin==2
    if strcmpi(flag(1),'m')
        % Getting just magnitude
        Gain = abs(Gain);
    else
        % Getting just sign
        Gain = sign(Gain);
    end
end