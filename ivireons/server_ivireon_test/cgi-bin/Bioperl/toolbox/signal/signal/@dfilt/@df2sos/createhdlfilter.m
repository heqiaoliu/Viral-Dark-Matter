function hF = createhdlfilter(this)
%

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/18 02:30:27 $

hF = hdlfilter.df2sos;

this.sethdl_abstractsos(hF);

hF.SectionInputSLtype = conv2sltype(this.filterquantizer, 'SectionInputWordLength', 'SectionInputFracLength', true);
hF.SectionOutputSLtype = conv2sltype(this.filterquantizer, 'SectionOutputWordLength', 'SectionOutputfracLength', true);
hF.StateSLtype = conv2sltype(this.filterquantizer, 'StateWordLength', 'StateFracLength');

% [EOF]
