function D = times(D1,D2,ScalarFlags)
% Element-by-element multiplication of
% two transfer functions D = D1 .* D2

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:57 $
if nargin<3
   ScalarFlags = false(1,2);
end
D = D1;

% Delay management: inner dimension
D.Delay = timesDelay(D1,D2);

% Compute response
if ScalarFlags(1)
   s = size(D2.Response);
else
   s = size(D1.Response);
end
R = zeros(s);
for ct=1:s(3)
   R(:,:,ct) = D1.Response(:,:,ct) .* D2.Response(:,:,ct);
end
D.Response = R;
