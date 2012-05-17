function calcEyeOpeningHor(this, Ts)
%CALCJITTERRJDJTJ Calculate horizontal eye opening.
%   The horizontal eye opening defined as eye opening on the horizontal axis
%   (time) at given BER (BERThreshold), which is also 1-TJ UI.

%   @commscope/@eyemeasurements
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:40 $


this.EyeOpeningHorizontal = Ts - this.JitterTotal;

%-------------------------------------------------------------------------------
% [EOF]
