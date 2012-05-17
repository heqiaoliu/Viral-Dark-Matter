function hF = createhdlfilter(this)
%

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/18 02:30:23 $

hF = hdlfilter.df1sos;

this.sethdl_abstractsos(hF);

hF.NumStateSLtype = conv2sltype(this.filterquantizer, 'NumStateWordLength', 'NumStateFracLength');
hF.DenStateSLtype = conv2sltype(this.filterquantizer, 'DenStateWordLength', 'DenStateFracLength');

% [EOF]
