function Hd2 = todffir(Hd);
%TODFFIR  Convert to direct-form FIR.
%   Hd2 = TODFFIR(Hd) converts discrete-time filter Hd to direct-form FIR
%   filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:09:51 $
  
if ~isfir(Hd)
  error(generatemsgid('DFILTErr'),'Original must be FIR to convert to direct-form FIR');
end
[b,a] = tf(Hd);
Hd2 = dfilt.dffir(b/a(1));
