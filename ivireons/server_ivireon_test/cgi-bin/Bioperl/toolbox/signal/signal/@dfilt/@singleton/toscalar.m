function Hd2 = toscalar(Hd);
%TOSCALAR  Convert to scalar.
%   Hd2 = TOSCALAR(Hd) converts discrete-time filter Hd to scalar filter Hd2. 

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:09:58 $
  
if ~isscalar(Hd)
  error(generatemsgid('DFILTErr'),'The filter to convert must be scalar.');
end
  
[b,a] = tf(Hd);
Hd2 = dfilt.scalar(b/a(1));
