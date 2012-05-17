function [A,B,E] = lyapcholcheckin(Caller,A,B,E)
% Validates input arguments to LYAPCHOL and DLYAPCHOL.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/01/29 15:31:36 $
if ~(isnumeric(A) && isnumeric(B) && isnumeric(E))
   ctrlMsgUtils.error('Control:foundation:Lyapunov1',Caller)
end

% Generalized lyap
if ~isempty(E) && ~(isreal(A) && isreal(B) && isreal(E))
    ctrlMsgUtils.error('Control:foundation:Lyapunov3',Caller)
end

% Check sizes
szA = size(A);  szE = size(E);
if length(szA)>2 || szA(1)~=szA(2)
   ctrlMsgUtils.error('Control:foundation:LyapChol1',Caller)
elseif any(szE) && any(szE~=szA(1))
   ctrlMsgUtils.error('Control:foundation:LyapChol2',Caller)
elseif size(B,1)~=szA(1)
   ctrlMsgUtils.error('Control:foundation:LyapChol3',Caller)
end

% Convert to double
A = double(full(A));  B = double(full(B));  E = double(full(E));

% Check for non finite entries
if hasInfNaN(A) || hasInfNaN(B) || hasInfNaN(E)
   ctrlMsgUtils.error('Control:foundation:Lyapunov6',Caller)
end

