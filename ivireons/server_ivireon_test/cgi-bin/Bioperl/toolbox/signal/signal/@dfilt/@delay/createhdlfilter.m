function hF = createhdlfilter(this)
%CREATHDLFILTER <short description>
%   OUT = CREATHDLFILTER(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/09/18 02:30:21 $

hF = hdlfilter.delay;
this.sethdl_abstractfilter(hF);
hF.Latency = this.Latency;
% [EOF]
