function [a,b] = utElimE(a,b,e)
% Helper to go from descriptor to explicit 
% (assuming E is nonsingular)

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:03 $
if ~isempty(e)
   hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   [nx,nu] = size(b);
   x = e\[a,b];
   a = x(:,1:nx);
   b = x(:,nx+1:nx+nu);
end
