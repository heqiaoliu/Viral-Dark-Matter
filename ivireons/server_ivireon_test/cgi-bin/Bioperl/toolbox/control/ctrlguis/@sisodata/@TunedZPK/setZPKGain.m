function setZPKGain(this,Gain,flag)
%SETZPKGAIN   Sets ZPK model gain.
%
%   SETZPKGAIN(MODEL,GAIN) sets the gain of the ZPK representation of MODEL.
%   SETZPKGAIN(MODEL,GAIN,'mag') sets the magnitude of the ZPK gain.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2006/06/20 20:01:11 $

TunedGain = Gain/formatfactor(this,'z');

if nargin==2
   this.Gain = TunedGain;
else
   if this.Gain==0
      GainSign = 1;
   else
      GainSign = sign(this.Gain);
   end
   this.Gain = GainSign*abs(TunedGain);
end