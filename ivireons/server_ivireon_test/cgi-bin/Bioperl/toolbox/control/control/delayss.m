function sys = delayss(a0,b0,c0,d0,varargin)
%DELAYSS  Creates state-space model with delayed terms.
%
%   SYS = DELAYSS(A,B,C,D,DELAYTERMS) constructs a continuous-time
%   state-space model of the form:
%
%     dx/dt = A x(t) + B u(t) + Sum { Aj x(t-tj) + Bj u(t-tj) }
%      y(t) = C x(t) + D u(t) + Sum { Cj x(t-tj) + Dj u(t-tj) }
%
%   where tj, j=1,..,N are time delays expressed in seconds. DELAYTERMS 
%   must be a struct array with fields:
%      a, b, c, d, delay
%   where DELAYTERMS(j) specifies the values of tj, Aj, Bj, Cj, Dj.
%   Zero values for Aj, Bj, Cj, Dj can be specified as []. The resulting 
%   model SYS is a state-space model with internal delays (@ss class).
%
%   SYS = DELAYSS(A,B,C,D,TS,DELAYTERMS) constructs the discrete-time
%   counterpart:
%
%      x[k+1] = A x[k] + B u[k] + Sum { Aj x[k-Nj] + Bj u[k-Nj] }
%        y[k] = C x[k] + D u[k] + Sum { Cj x[k-Nj] + Dj u[k-Nj] }
%
%   where Nj, j=1,..,N are time delays expressed as integer multiples
%   of the sampling period TS.
%
%   Example: To specify the model:
%      dx/dt = - x(t) - x(t-1.2) + 2 u(t-0.5)
%       y(t) = x(t-0.5) + u(t)
%   type
%      DelayT = struct('delay',{0.5;1.2},'a',[],'b',[],'c',[],'d',[]);
%      DelayT(1).b = 2;   DelayT(1).c = 1;
%      DelayT(2).a = -1;
%      sys = delayss(-1,0,0,1,DelayT);
%
%   See also SS, SS/GETDELAYMODEL.

%	Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	$Revision: 1.1.8.5 $  $Date: 2010/03/31 18:12:47 $
ni = nargin;
error(nargchk(5,6,ni))
if ni==5
   Ts = 0;
   DelayTerms = varargin{1};   
else
   Ts = varargin{1};
   DelayTerms = varargin{2};
end

% Check inputs
nx = size(a0,1);
nu = max(size(b0,2),size(d0,2));
ny = max(size(c0,1),size(d0,1));
% A0,B0,C0,D0
try
    a0 = localMakeFullDoubleMatrix(a0,'A');
    b0 = localMakeFullDoubleMatrix(b0,'B');
    c0 = localMakeFullDoubleMatrix(c0,'C');
    d0 = localMakeFullDoubleMatrix(d0,'D');
catch E
    throw(E)
end

if isequal(d0,0)
   % Accept scalar zero value for D0 (consistency with SS)
   d0 = zeros(ny,nu);
end
if ~(isequal(size(a0),[nx nx]) && ...
     isequal(size(b0),[nx nu]) && ...
     isequal(size(c0),[ny nx]) && ...
     isequal(size(d0),[ny nu]))
 ctrlMsgUtils.error('Control:ltiobject:delayss1')
end
% DELAYTERMS
DelayTerms = DelayTerms(:);
if ~isstruct(DelayTerms) || ~isequal(fieldnames(DelayTerms),{'delay';'a';'b';'c';'d'})
    ctrlMsgUtils.error('Control:ltiobject:delayss2')
else
   for ct=1:length(DelayTerms)
      try 
         DelayTerms(ct) = localValidateTerm(DelayTerms(ct),nx,ny,nu,Ts,ct);
      catch E
         throw(E)
      end
   end
end
   
% Eliminate zero and duplicate delays
[delays,is] = sort(cat(1,DelayTerms.delay));
DelayTerms = DelayTerms(is);
% delay=0
ixz = find(delays==0);
for ct=1:length(ixz)
   jz = ixz(ct);
   a0 = a0 + DelayTerms(jz).a;
   b0 = b0 + DelayTerms(jz).b;
   c0 = c0 + DelayTerms(jz).c;
   d0 = d0 + DelayTerms(jz).d;
end
DelayTerms(ixz,:) = [];  delays(ixz,:) = [];
% duplicate delays
if any(diff(delays)==0)
   j = 1;
   while j<length(delays)
      ixdup = j+find(delays(j+1:end)==delays(j));
      for ct=1:length(ixdup)
         jdup = ixdup(ct);
         DelayTerms(j).a = DelayTerms(j).a + DelayTerms(jdup).a;
         DelayTerms(j).b = DelayTerms(j).b + DelayTerms(jdup).b;
         DelayTerms(j).c = DelayTerms(j).c + DelayTerms(jdup).c;
         DelayTerms(j).d = DelayTerms(j).d + DelayTerms(jdup).d;
      end
      DelayTerms(ixdup,:) = [];  delays(ixdup,:) = [];
      j = j+1;
   end
end
         
% Build @ss representation
q = [];
s = [];
b = b0;
c = c0;
tau = zeros(0,1);
n = nx+min(ny,nu);
tolsing = 10*eps;
for ct=1:length(DelayTerms)
   DT = DelayTerms(ct);
   % Factorize [Aj Bj;Cj Dj]
   [u,sv,v] = svd([DT.a DT.b;DT.c DT.d]);
   nr = nx+ny;  sv = sv(1:nr+1:nr*n);  svmax = sv(1);
   rk = length(find(sv>tolsing*svmax));
   sv = sqrt(sv(1:rk));
   u = lrscale(u(:,1:rk),[],sv);
   v = lrscale(v(:,1:rk),[],sv);
   % Enforce u(1:nx,:)*v(1:nx,:)'=0 structurally when Aj=0
   % (ensures isExplicitODE is true for DELAYSS models, see g394456)
   if nx>0 && norm(DT.a,1)==0
      [junk,sv,w] = svd(u(1:nx,:)); % column compression
      sv = sv(1:nx+1:nx*min(nx,rk));
      rho = length(find(sv>tolsing*svmax));
      u = u * w;   u(1:nx,rho+1:rk) = 0;
      v = v * w;   v(1:nx,1:rho) = 0;
   end      
   % Grow internal delay model
   b = [b , u(1:nx,:)];
   q = [q , u(nx+1:nx+ny,:)];
   c = [c ; v(1:nx,:)'];
   s = [s ; v(nx+1:nx+nu,:)'];
   tau(end+1:end+rk,1) = DT.delay;
end

% Create model
sys = ss(a0,b0,c0,d0,Ts);
D = getPrivateData(sys);
D.b = b;
D.c = c;
D.d = [d0 q;s zeros(length(tau))];
D.Delay.Internal = tau;
sys = setPrivateData(sys,D);

%------------

function s = localValidateTerm(s,nx,ny,nu,Ts,ct)
% Validates delayed terms
s.delay = localMakeFullDoubleMatrix(s.delay,sprintf('S(%d).delay',ct));
s.a = localMakeFullDoubleMatrix(s.a,sprintf('S(%d).a',ct));
s.b = localMakeFullDoubleMatrix(s.b,sprintf('S(%d).b',ct));
s.c = localMakeFullDoubleMatrix(s.c,sprintf('S(%d).c',ct));
s.d = localMakeFullDoubleMatrix(s.d,sprintf('S(%d).d',ct));
tau = s.delay;
if ~(isscalar(tau) && tau>=0 && (Ts==0 || tau==round(tau)))
   if Ts==0
       ctrlMsgUtils.error('Control:ltiobject:delayss3',ct,ct)
   else
       ctrlMsgUtils.error('Control:ltiobject:delayss4',ct,ct)
   end
end
if isempty(s.a) || isequal(s.a,0);
   s.a = zeros(nx);
end
if isempty(s.b) || isequal(s.b,0);
   s.b = zeros(nx,nu);
end
if isempty(s.c) || isequal(s.c,0);
   s.c = zeros(ny,nx);
end
if isempty(s.d) || isequal(s.d,0);
   s.d = zeros(ny,nu);
end
if ~(isequal(size(s.a),[nx nx]) && ...
      isequal(size(s.b),[nx nu]) && ...
      isequal(size(s.c),[ny nx]) && ...
      isequal(size(s.d),[ny nu]))
  ctrlMsgUtils.error('Control:ltiobject:delayss5',ct,ct,ct,ct,ct)
end

%------------

function x = localMakeFullDoubleMatrix(x,matrixstr)
% Check 
if ndims(x)>2 || ~(isnumeric(x) || islogical(x))
   ctrlMsgUtils.error('Control:ltiobject:delayss6',matrixstr)
else
   x = full(double(x));
end
