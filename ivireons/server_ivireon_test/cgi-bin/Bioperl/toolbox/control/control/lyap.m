function X = lyap(A, B, C, E)
%LYAP  Solve continuous-time Lyapunov equations.
%
%   X = LYAP(A,Q) solves the Lyapunov matrix equation:
%
%       A*X + X*A' + Q = 0
%
%   X = LYAP(A,B,C) solves the Sylvester equation:
%
%       A*X + X*B + C = 0
%
%   X = LYAP(A,Q,[],E) solves the generalized Lyapunov equation:
%
%       A*X*E' + E*X*A' + Q = 0    where Q is symmetric
%
%   See also LYAPCHOL, DLYAP.

%	Authors: S.N. Bangert 1-10-86
%           JNL 3-24-88, AFP 9-3-95, PG 09-02
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.11.4.9 $  $Date: 2008/01/15 18:47:00 $
%  LYAP is based on the SLICOT routines SB03MD, SG03AD, and SB04MD.
ni = nargin;
error(nargchk(2,4,ni))
if ni<3
   C = [];
end
if ni<4
   E = [];
end

% Validate data 
try
   [A,B,C,E] = lyapcheckin('lyap',ni,A,B,C,E);
catch E
   throw(E)
end

% Balance to minimize spectrum distorsions in Hess/Schur/QZ factorizations
if ni==3
   % Sylvester
   [sA,pA,A] = mscale(A,'fullbal');
   [sB,pB,B] = mscale(B,'fullbal');
   C(pA,pB) = lrscale(C,1./sA,sB);  % TA\C*TB
else
   [A,junk,junk,E,s,p] = aebalance(A,[],[],E,'fullbal');
   B(p,p) = lrscale(B,1./s,1./s);  % T\B/T'
end

% Solve equation
try
   if ni==3
      % Sylvester equation A*X+X*B=-C
      % Call SLICOT routine SB04MD or LAPACK routine ZTRSYL
      X = sylvslv('C',A,B,-C);
      X = lrscale(X(pA,pB),sA,1./sB);  % TA*X/TB
   else
      if isequal(B,B')
         % Lyapunov equation A*X+X*A'=-B or A*X*E'+E*X*A'=-B
         % Call SLICOT routine SB03MD (E=[]) or SG03AD (descriptor, real)
         X = lyapslv('C',A,E,-B);
      else
         % Sylvester equation A*X+X*A'=-B with B non symmetric
         % Call SLICOT routine SB04MD or LAPACK routine ZTRSYL
         X = sylvslv('C',A,A',-B);
      end
      X = lrscale(X(p,p),s,s);  % T*X*T' using T(:,p)=diag(s)
   end
catch E
   throw(E)
end
