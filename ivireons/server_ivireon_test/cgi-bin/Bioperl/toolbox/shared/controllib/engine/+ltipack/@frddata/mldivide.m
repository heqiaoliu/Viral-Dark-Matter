function D = mldivide(D1,D2)
% Computes D = D1\D2

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:40 $

% RE: square system, no support for scalar division
if hasdelay(D1)
   ctrlMsgUtils.error('Control:combination:divide1','SYS1\SYS2','SYS1')
end
D2 = elimDelay(D2,[],D2.Delay.Output,D2.Delay.IO);
D = D2;

% Response
hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
[ny,nu,nf] = size(D2.Response);
R = zeros(ny,nu,nf);
for ct=1:nf
   m = D1.Response(:,:,ct) \ D2.Response(:,:,ct);
   if hasInfNaN(m)
      R(:,:,ct) = Inf;
   else
      R(:,:,ct) = m;
   end
end
D.Response = R;

