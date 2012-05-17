function s = mat2str(x)
%MAT2STR Matrix to string conversion of a gf object

%    Copyright 2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/03/08 21:26:04 $ 

if x.m > 1
  s = sprintf('%s in GF(2^%d)', mat2str(x.x), (x.m));
else
  s = sprintf('%s in GF(2)', mat2str(x.x));
end
  
