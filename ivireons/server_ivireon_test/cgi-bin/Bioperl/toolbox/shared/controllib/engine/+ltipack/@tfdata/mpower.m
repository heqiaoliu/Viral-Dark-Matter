function Dm = mpower(D,m)
% Integer powers of TF models.
% Note: m can be positive or negative.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:51 $
M = abs(m);
Dm = D;
if m==0
   n = size(D.num,1);
   Dm.num = num2cell(eye(n));
   Dm.den(:) = {1};
   Dm.Delay.Input = zeros(n,1);
   Dm.Delay.Output = zeros(n,1);
   Dm.Delay.IO = zeros(n);
elseif isequal(D.num,{[1 0]}) && isequal(D.den,{[0 1]}),
   % Special handling of SYS = s,z for performance
   Dm.num{1} = [D.num{1} zeros(1,M-1)];
   Dm.den{1} = [zeros(1,M-1) D.den{1}];
   Dm.Delay.IO = M*D.Delay.IO + (M-1)*(D.Delay.Input+D.Delay.Output);
else
   % Perform M-1 products
   for j=2:M
      Dm = mtimes(Dm,D);
   end
end

% Invert result if m<0
if m<0
   Dm = inv(Dm);
end

