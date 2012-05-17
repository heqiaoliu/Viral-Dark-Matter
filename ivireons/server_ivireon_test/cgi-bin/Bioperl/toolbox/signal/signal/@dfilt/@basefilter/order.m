function n = order(Hb)
%ORDER Filter order.
%   ORDER(Hb) returns the order of filter Hb.
%
%   See also DFILT.   
  
%   Author: J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2006/06/27 23:33:43 $

n = base_num(reffilter(Hb), 'thisorder');
