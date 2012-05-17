function Hd2 = todfasymfir(Hd);
%TODFASYMFIR  Convert to antisymmetric FIR.
%   Hd2 = TODFASYMFIR(Hd) converts discrete-time filter Hd to
%   antisymmetric FIR filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:09:50 $
  
if ~isfir(Hd)
  error(generatemsgid('DFILTErr'),'Original must be FIR to convert to direct-form FIR.');
end
[b,a] = tf(Hd);
Hd2 = dfilt.dfasymfir(b/a(1));
