function Hd2 = tolatticearma(Hd);
%TOLATTICEARMA  Convert to lattice ARMA.
%   Hd2 = TOLATTICEARMA(Hd) converts discrete-time filter Hd to lattice ARMA
%   filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:52:34 $
  
[b,a] = tf(Hd);
[k,v] = tf2latc(b,a);
Hd2 = dfilt.latticearma(k,v);