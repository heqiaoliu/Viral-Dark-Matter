function setFormattedGain(this,NewValue)
%SETFORMATTEDGAIN  Sets the formatted gain data.
%
%   setFormattedGain(this,NewGain)

%
%   The formatted gain is the ZPK gain divided by the format factor 
%   (see FORMATFACTOR for details).

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2006/06/20 20:01:10 $

if strncmpi(this.Format,'z',1)
    this.setZPKGain(NewValue);
else
    this.Gain = NewValue/formatfactor(this,'t');
end

