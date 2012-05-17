function TestFcn = utCheckSeparability(a,b,c,d,Ts,AbsTol,RelTol)
% Creates test function to check if modal decomposition error
% exceeds user-defined required accuracy.
%
%   Inputs:
%      A,B,C,D           Original transfer function H(s)
%                        (A is in real Schur form)
%      TS                Sample time.
%      ABSTOL, RELTOL    Decomposition error should not exceed 
%                        ABSTOL + RTOL * |H(s)|
%
%   LOW-LEVEL UTILITY.

%   Authors: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2006/11/17 13:26:12 $

nx = size(a,1);
ny = size(c,1);
nu = size(b,2);
Ts = abs(Ts);

% Select test frequencies
e = ordeig(a);
if Ts==0
   w = abs(e);   
else
   w = abs(log(e(e~=0))/Ts);
   w = w(w<pi/Ts);
end
w = sort(w(w>0));

% Pick one test freq per decade inside the frequency range
% associated with the modes of A
if isempty(w)
   dmin = 0;
   dmax = 0;
else
   dmin = floor(log10(w(1)))-1;
   if Ts==0
      % Keep error small while rolling off (see sys1 in hstabsep for motivation)
      dmax = ceil(log10(w(end)))+2;
   else
      dmax = floor(log10(pi/Ts));
   end
end
w = 10.^(dmin:dmax).';
nw = length(w);

% Form vector of s/z test points
if Ts==0
   s = 1i * w;
else
   s = exp((1i*Ts)*w);
end
   
% Make A upper triangular
[u,a] = rsf2csf(eye(nx),a);
b = u'*b;
c = c*u;

% Precompute max allowable error for each I/O pair at the 
% test frequencies W
MaxError = zeros(ny,nu,nw);
errA = eps * norm(a,1);
errB = eps * sum(abs(b),1);
errC = eps * sum(abs(c),2);
for ct=1:nw
   [h,beta,gamma] = frkernel(a,b,c,d,[],s(ct));
   if hasInfNaN(h)
      % Response is singular at test frequency
      w(ct) = NaN;
   else
      beta = sum(abs(beta),1);
      gamma = sum(abs(gamma),2);
      %[w(ct) errA * gamma * beta , gamma * errB , errC * beta]
      % AbsAccuracy: numerical accuracy of H(s)
      AbsAccuracy = errA * gamma * beta + gamma * errB + errC * beta; 
      MaxError(:,:,ct) = AbsAccuracy + AbsTol + RelTol * abs(h);
   end
end

% Return test function
TestFcn = @localTestFcn;

%-------------------- Nested function --------------------------------------------------

   function Pass = localTestFcn(a11,b1,c1,a22,b2,c2,t)
      % Estimate max error resulting from splitting 
      %   H(s) = [c1 c2] * (sI - [a11 a12;0 a22]) \ [b1 ; b2]
      % into H1(s) + H2(s) where 
      %   H1(s) = c1 * (sI-a11) \ (b1-t*b2)
      %   H2(s) = (c2+c1*t) * (sI-a22) \ b2
      %   t is the computed solution of a11 * t - t * a22 + a12 = 0
      nx1 = size(a11,1);
      nx2 = size(a22,1);
      
      % Compute frequencies of modes of A11, A22
      e12 = [ordeig(a11) ; ordeig(a22)];
      if Ts==0
         w12 = abs(e12);
      else
         w12 = abs(log(e12(e12~=0))/Ts);
      end
      
      % Identify nearest test frequencies
      idxtest = min(round(log10(w12(w12>0)))-dmin+1,nw);
      % Eliminate singular frequencies and always include first & last test
      % frequencies (see sys1 in hstabsep for motivation)
      idxtest = unique([1;idxtest(isfinite(w(idxtest)));nw]);
      if isempty(idxtest)
         idxtest = 1;
      end

      % Make A11 and A22 upper triangular
      [u1,a11] = rsf2csf(eye(nx1),a11);  
      b1 = u1' * b1;  c1 = c1 * u1;
      [u2,a22] = rsf2csf(eye(nx2),a22);  
      b2 = u2' * b2;  c2 = c2 * u2;
      
      % Compute residual bound and error bounds for B1-T*B2 and C2+C1*T
      abst = abs(u1' * t * u2);
      R = eps * (nx1 * abs(a11) * abst + nx2 * abst * abs(a22));
      errB1 = eps * (abs(b1) + abst * abs(b2));
      errC2 = eps * (abs(c2) + abs(c1) * abst);
      
      % Compute error bound for H->H1+H2 decomposition
      Pass = true;
      for ct1=1:length(idxtest)
         idxw = idxtest(ct1);
         sct = s(idxw);
         gamma1 = abs(c1 / (sct*eye(nx1)-a11));
         beta2 = abs((sct*eye(nx2)-a22) \ b2);
         %[abs(sct) gamma1*R*beta2 , gamma1*errB1 , errC2*beta2]
         % See g317619 for justification 
         wcError = gamma1 * R * beta2 + gamma1 * errB1 + errC2 * beta2;
         %w(idxw), wcError./MaxError(:,:,idxw)
         TolExceeded = (wcError>MaxError(:,:,idxw));
         if any(TolExceeded(:))
            Pass = false;  break
         end
      end      
   end

end