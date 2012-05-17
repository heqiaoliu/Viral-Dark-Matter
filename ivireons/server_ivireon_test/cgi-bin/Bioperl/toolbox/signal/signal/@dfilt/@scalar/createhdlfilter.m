function hF = createhdlfilter(this)
%CREATHDLFILTER <short description>
%   OUT = CREATHDLFILTER(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/09/18 02:30:46 $

hF = hdlfilter.scalar;
this.sethdl_abstractfilter(hF);
hF.Gain = this.Gain;
[hF.RoundMode, hF.OverflowMode] = conv2hdlroundoverflow(this);
hF.CoeffSLType = conv2sltype(this.filterquantizer, 'CoeffWordLength', 'CoeffFracLength');
% [EOF]
