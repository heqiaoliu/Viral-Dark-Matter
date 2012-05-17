function R = dlyapchol(A, B, E, varargin)
%DLYAPCHOL  Square-root solver for discrete-time Lyapunov equations.
%
%   R = DLYAPCHOL(A,B) computes a Cholesky factorization X = R'*R of 
%   the solution X to the Lyapunov matrix equation:
%
%       A*X*A'- X + B*B' = 0
%
%   All eigenvalues of A must lie in the open unit disk for R to exist.
%
%   R = DLYAPCHOL(A,B,E) computes a Cholesky factorization X = R'*R of
%   X solving the generalized Lyapunov equation:
%
%       A*X*A' - E*X*E' + B*B' = 0
%
%   All generalized eigenvalues of (A,E) must lie in the open unit disk 
%   for R to exist.
%
%   See also DLYAP, LYAPCHOL.

%	Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	$Revision: 1.1.6.10 $  $Date: 2008/01/15 18:46:56 $

%  DLYAPCHOL is based on the SLICOT routines SB03OD and SG03BD.
ni = nargin;
error(nargchk(2,4,ni))
if ni<3
   E = [];
end
DoScaling = (ni<4);

% Validate data 
try
   [A,B,E] = lyapcholcheckin('dlyapchol',A,B,E);
catch E
   throw(E)
end

% Transpose data (solver works on A',E',B')
A = A';  E = E';  C = B';

% Balance to minimize spectrum distorsions in Schur/QZ factorizations
if DoScaling
   [A,junk,junk,E,s] = aebalance(A,[],[],E,'noperm','fullbal');  % T\A*T, T\E*T
   C = lrscale(C,[],s);  % C = C*T
end

% Solve equation
try 
   % Call SLICOT routine SB03OD (E=[]) or SG03BD (descriptor, real)
   % or equivalent complex routines (see ZUTIL.C)
   R = hlyapslv('D',A,E,C);
catch E
   switch E.identifier
      case 'Control:foundation:hlyapslv4'
         ctrlMsgUtils.error('Control:foundation:LyapChol5')
      otherwise
         throw(E)
   end
end

% Undo scaling
if DoScaling
   R = lrscale(R,[],1./s);   % R->R/T
end
