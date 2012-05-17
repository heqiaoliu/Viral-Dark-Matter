function [A,B,C,E] = lyapcheckin(Caller,ni,A,B,C,E)
% Validates input arguments to LYAP and DLYAP.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/01/29 15:31:34 $
if ~(isnumeric(A) && isnumeric(B) && isnumeric(C) && isnumeric(E))
   ctrlMsgUtils.error('Control:foundation:Lyapunov1',Caller)
end

% Generalized lyap
if ~isempty(E)
   if ~isequal(B,B')
      ctrlMsgUtils.error('Control:foundation:Lyapunov2',Caller)
   elseif ~(isreal(A) && isreal(B) && isreal(E))
      ctrlMsgUtils.error('Control:foundation:Lyapunov3',Caller)
   end
end

if ni==3
   % Sylvester
   A = double(full(A));  B = double(full(B));  C = double(full(C));
   szA = size(A);  szB = size(B);  szC = size(C);
   if length(szA)>2 || length(szB)>2 || szA(1)~=szA(2) || szB(1)~=szB(2)
      ctrlMsgUtils.error('Control:foundation:Sylvester1',Caller)
   elseif length(szC)>2 || szC(1)~=szA(1) || szC(2)~=szB(1)
      ctrlMsgUtils.error('Control:foundation:Sylvester2',Caller)
   elseif hasInfNaN(A) || hasInfNaN(B) || hasInfNaN(C)
      ctrlMsgUtils.error('Control:foundation:Lyapunov6',Caller)
   end
else
   % Lyapunov
   A = double(full(A));  B = double(full(B));  E = double(full(E));
   szA = size(A);  szB = size(B);  szE = size(E);
   if length(szA)>2 || length(szB)>2 || szA(1)~=szA(2) || szB(1)~=szB(2) || szA(1)~=szB(1)
      ctrlMsgUtils.error('Control:foundation:Lyapunov4',Caller)
   elseif any(szE) && any(szE~=szA(1))
      ctrlMsgUtils.error('Control:foundation:Lyapunov5',Caller)
   elseif hasInfNaN(A) || hasInfNaN(B) || hasInfNaN(E)
      ctrlMsgUtils.error('Control:foundation:Lyapunov6',Caller)
   end
end
