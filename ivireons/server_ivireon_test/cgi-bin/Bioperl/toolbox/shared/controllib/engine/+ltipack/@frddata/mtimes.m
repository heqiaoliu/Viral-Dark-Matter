function D = mtimes(D1,D2,ScalarFlags)
% Multiplies two FRD models D = D1 * D2

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:43 $
if nargin<3
   ScalarFlags = false(1,2);
end

% Delay management: inner dimension
[Delay,D1,D2] = mtimesDelay(D1,D2,ScalarFlags);

% Compute response
R1 = D1.Response;
R2 = D2.Response;
[ny,nu] = size(Delay.IO);
m = size(R2,1);  % inner size
n = ny*nu*m;
if n==1
   % Special handling of SISO * SISO for performance
   R = R1 .* R2;
else
   nf = size(R1,3);
   R = zeros(ny,nu,nf);
   if ~any(ScalarFlags) && n<30 && nf>30
      % Rely on .* to avoid LAPACK overhead for small matrices (see g????)
      for k=1:m
         for j=1:nu
            for i=1:ny
               R(i,j,:) = R(i,j,:) + R1(i,k,:) .* R2(k,j,:);
            end
         end
      end
   else
      % Loop over frequency
      for ct=1:nf
         R(:,:,ct) = R1(:,:,ct) * R2(:,:,ct);
      end
   end
end
      
D = D1;
D.Response = R;
D.Delay = Delay;
