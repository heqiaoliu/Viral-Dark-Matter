function [z,p,k] = ss2zp(a,b,c,d,iu)
%SS2ZP  State-space to zero-pole conversion.
%   [Z,P,K] = SS2ZP(A,B,C,D,IU)  calculates the transfer function in
%   factored form:
%
%                -1           (s-z1)(s-z2)...(s-zn)
%       H(s) = C(sI-A) B + D =  k ---------------------
%                             (s-p1)(s-p2)...(s-pn)
%   of the system:
%       .
%       x = Ax + Bu
%       y = Cx + Du
%
%   from the single input IU.  The vector P contains the pole 
%   locations of the denominator of the transfer function.  The 
%   numerator zeros are returned in the columns of matrix Z with as 
%   many columns as there are outputs y.  The gains for each numerator
%   transfer function are returned in column vector K.
%
%   See also ZP2SS,PZMAP,TZERO, EIG.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.33.4.2 $  $Date: 2006/12/15 19:27:59 $

error(nargchk(4,5,nargin,'struct'));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,ns] = size(a);

if nargin==4,
    if nx>0,
        [nb,nu] = size(b);
    else
        [ny,nu] = size(d);
    end
    if (nu<=1), 
        iu = 1;
    else
        error('MATLAB:ss2zp:NeedIU',...
              'IU must be specified for systems with more than one input.');
    end
end

% Remove relevant input:
if ~isempty(b), b = b(:,iu); end
if ~isempty(d), d = d(:,iu); end

% Trap gain-only models
if nx==0 && ~isempty(d), z = []; p = []; k = d; return, end

% Do poles first, they're easy:
p = eig(a);

% Compute zeros and gains using transmission zero calculation
% Took out check for tzreduce since that now ships with SP
[ny,nu] = size(d);
z = [];
k = zeros(ny,1);
for i=1:ny
   [zi,gi] = tzero(a,b,c(i,:),d(i,:));
   [mz,nz] = size(z);
   nzi = length(zi);
   if i==1,
      z = zi;
   else
      linf = inf;
      z = [[z; linf(ones(max(0,nzi-mz),1),ones(max(nz,1),1))], ...
          [zi;linf(ones(max(0,mz-nzi),1),1)]];
  end
  k(i) = gi;
end

% end ss2zp.m
