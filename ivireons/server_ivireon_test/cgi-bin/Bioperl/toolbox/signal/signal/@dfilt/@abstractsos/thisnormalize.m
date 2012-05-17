function g = thisnormalize(Hd)
%THISNORMALIZE   

%   Author(s): V. Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:52:41 $

sosM = Hd.refsosMatrix;
g = max(abs(sosM(:,1:3)),[],2);
for i=1:length(g),
  sosM(i,1:3) = sosM(i,1:3)/g(i);
end
Hd.refsosMatrix= sosM;

% [EOF]
