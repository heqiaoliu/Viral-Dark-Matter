function Hd2 = todfsymfir(Hd);
%TODFSYMFIR  Convert to direct-form symmetric FIR.
%   Hd2 = TODFSYMFIR(Hd) converts discrete-time filter Hd to
%   direct-form symmetric FIR filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:09:53 $
  
if ~isfir(Hd)
  error(generatemsgid('DFILTErr'),'Original must be FIR to convert to direct-form FIR');
end
[b,a] = tf(Hd);
Hd2 = dfilt.dfsymfir(b/a);
