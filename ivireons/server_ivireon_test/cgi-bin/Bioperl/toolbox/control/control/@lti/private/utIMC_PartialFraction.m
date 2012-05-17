function [R,P,Residue] = utIMC_PartialFraction(Num,Den,Poles,tol)
% IMC Tuning Subroutines (Continuous).
% partial-fraction expansion modified from 'residue' function

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:21:54 $

% Num , Den and Poles have to be row vectors
Residue =[];
f = find(Num ~= 0);
if length(f), Num = Num(f(1):length(Num)); end
f = find(Den ~= 0);
if length(f), Den = Den(f(1):length(Den)); end
% Normalize.
Num = Num ./ Den(1); 
Den = Den ./ Den(1);   
if length(Num) >= length(Den)
    [Residue,Num] = deconv(Num,Den); 
end
if isempty(Poles)
  R = zeros(0,0,superiorfloat(Num,Den)); 
  P = zeros(0,0,class(Den)); 
  return
end
[mults,i]=mpoles(Poles,tol,1);
p=Poles(i);
% For P and multiplicity.
q = zeros(2,length(p),superiorfloat(Num,Den));   
q(1,1) = p(1); q(2,1) = 1; j = 1;
repeated = 0;
for i = 2:length(p)
   av = q(1,j) ./ q(2,j);
   if abs(av - p(i)) <= tol    % Treat as repeated root.
      q(1,j) = q(1,j) + p(i);   % Sum for average value.
      q(2,j) = q(2,j) + 1;
      repeated = 1;
     else
      j = j + 1; q(1,j) = p(i); q(2,j) = 1;
   end
end
q(1,1:j) = q(1,1:j) ./ q(2,1:j);   % Multiple root average.
% Set desired = 1 if you want the output multiple P
% to be averaged.
desired = 1;
if repeated && desired
   indx = 0;
   for i = 1:j
      for ii = 1:q(2,i), indx = indx+1; p(indx) = q(1,i); end
   end
end
P = p(:);  % Rename.
% get coefficients for each term
R = zeros(length(p),1,superiorfloat(Num,Den)); 
if repeated   % Section for repeated root problem.
   Den = poly(p);
   next = 0;
   for i = 1:j
      pole = q(1,i); n = q(2,i);
      for indx = 1:n
         next = next + 1;
         R(next) = resi2(Num,Den,pole,n,indx);
      end
   end
  else   % No repeated roots.
   for i = 1:j
      temp = poly(p([1:i-1, i+1:j]));
      R(i) = polyval(Num,p(i)) ./ polyval(temp,p(i));
   end
end

