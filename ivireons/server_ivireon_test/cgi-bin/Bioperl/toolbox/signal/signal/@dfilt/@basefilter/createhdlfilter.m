function hF = createhdlfilter(this)
%CREATEHDLFILTER Returns the corresponding hdlfiltercomp for HDL Code
%generation.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/18 02:30:14 $

error(generatemsgid('NotHdlable'), 'HDL generation for the filter structure %s is not supported.',...
                       class(this));
                   

% [EOF]
