function [a, b] = d2c(phi, gamma, t)
%D2C  Converts discrete-time dynamic system to continuous time.
%
%   SYSC = D2C(SYSD,METHOD) computes a continuous-time model SYSC that 
%   approximates the discrete-time model SYSD. The string METHOD selects 
%   the conversion method among the following:
%      'zoh'       Zero-order hold on the inputs
%      'tustin'    Bilinear (Tustin) approximation
%      'matched'   Matched pole-zero method (for SISO systems only)
%   The default is 'zoh' when METHOD is omitted.
%
%   D2C(SYSD,OPTIONS) gives access to additional conversion options. Use  
%   D2COPTIONS to create and configure the option set OPTIONS. For example, 
%   you can specify a prewarping frequency for the Tustin method by:
%      opt = d2cOptions('Method','tustin','PrewarpFrequency',0.5);
%      sysc = d2c(sysd,opt);
%
%   See also D2COPTIONS, C2D, D2D, DYNAMICSYSTEM.

%   J.N. Little 4-21-85
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/31 18:13:18 $

error(nargchk(3,3,nargin));
[msg,phi,gamma]=abcdchk(phi,gamma); error(msg);

[m,n] = size(phi);
[m,nb] = size(gamma);

% phi = 1 case cannot be computed through matrix logarithm.  Handle
% as a special case.
if m == 1
    if phi == 1
        a = 0; b = gamma/t;
        return
    end
end

% Remove rows in gamma that correspond to all zeros
b = zeros(m,nb);
nz = 0;
nonzero = [];
for i=1:nb
    if any(gamma(:,i)~=0) 
        nonzero = [nonzero, i];
        nz = nz + 1;
    end
end

% Do rest of cases using matrix logarithm.
[s, exitflag] = logm([[phi gamma(:,nonzero)]; zeros(nz,n) eye(nz)]);
s = s/t;
if exitflag || norm(imag(s),'inf') > sqrt(eps)
   warning('Accuracy of d2c conversion may be poor.')
end
s = real(s);
a = s(1:n,1:n);
if length(b)
   b(:,nonzero) = s(1:n,n+1:n+nz);
end


