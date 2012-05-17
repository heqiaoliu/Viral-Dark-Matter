function e = utBlkDiagE(e1,e2,nx1,nx2)
% Returns compact representation of E = blkdiag(E1,E2)

%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:36:23 $
if isempty(e1) && isempty(e2)
   % Quick handling of non-descriptor case
   e = [];
else
   if isempty(e1)
      e1 = eye(nx1);
   end
   if isempty(e2)
      e2 = eye(nx2);
   end
   e = [e1 zeros(nx1,nx2);zeros(nx2,nx1) e2];
end
