function [s,p,b] = mscale(a,varargin)
%MSCALE  Row/column scaling of 2D matrix.
%
%   [S,P,B] = MSCALE(A) returns the scaled matrix B = T\A*T together
%   with the scaling S and permutation P such that T(:,P) = diag(S).  
%
%   [S,P,B] = MSCALE(A,Option1,Option2,...) specifies additional 
%   options as strings:
%     'perm'      Enables row/column permutation (default)
%     'noperm'    Prevents row/column permutation 
%     'safebal'   Performs regularized row/column balancing (default)
%     'fullbal'   Performs full row/column balancing using BALANCE
%
%   LOW-LEVEL UTILITY.

%   Authors: P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/12/04 22:25:37 $

% Differences with BALANCE:
%  * Use two-step approach when PERM is required to prevent scaling 
%    from operating only on a submatrix (can lead to poor overall 
%    scaling in some cases, see g209996)
%  * Skip permutation when A or A' is upper Hessenberg (g241217)
XPerm = ~any(strcmp('noperm',varargin));    % state permutation enabled?
FullBal = any(strcmp('fullbal',varargin));  % perform full balancing?

% Compute scaling
if FullBal
   [s,junk,b] = balance(a,'noperm');
else
   [rho,s] = matscale(abs(a),0.01);
   b = lrscale(a,1./s,s);
end
   
% Compute permutation
n = size(a,1);
p = (1:n)';
if XPerm
   % Grab permutation from BALANCE algorithm
   % Note: Special handling of upper and lower Hessenberg matrices
   ip = triperm('H',a);
   b = b(ip,ip);
   p(ip) = p;
end
