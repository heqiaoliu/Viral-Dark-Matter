function hF = createhdlfilter(this)
%CREATEHDLFILTER Returns the corresponding hdlfiltercomp for HDL Code
%generation.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/18 02:30:37 $

hF = hdlfilter.dfsymfir;
this.sethdl_dtffir(hF);

hF.TapsumSLtype = conv2sltype(this.filterquantizer, 'TapsumWordLength', 'TapSumFracLength', true);
% [EOF]
