function Hd2 = todffirt(Hd);
%TODFFIRT  Convert to direct-form FIR transposed.
%   Hd2 = (Hd) converts discrete-time filter Hd to direct-form FIR transposed
%   filter Hd2.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:09:52 $
  
if ~isfir(Hd)
  error(generatemsgid('DFILTErr'),'Original must be FIR to convert to direct-form FIR');
end
[b,a] = tf(Hd);
Hd2 = dfilt.dffirt(b/a(1));
