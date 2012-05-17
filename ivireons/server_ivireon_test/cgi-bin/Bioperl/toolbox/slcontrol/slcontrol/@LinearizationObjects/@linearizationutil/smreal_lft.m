function [Acmr,Bcmr,Ccmr,Ejunk,signalmask] = smreal_lft(this,A,B,C,D,E,F,G)
% SMREAL_LFT  Find the states and the internal inputs and outputs of the
% linearization LFT that can be removed.
%
 
% Author(s): John W. Glass 28-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:26:55 $

nx = size(A,1);
nu = size(B,2);
ny = size(C,1);
nw = size(F,2);
nz = size(G,1);

% Create the concat interconnection
%           ---------
% [x;y;u] ->| Ac Bc |-> [dx/dt;y;u]
%       w ->| Cc Dc |-> z
%           ---------
Ac = [A             sparse(nx,ny)                B;...
      C             sparse(1:ny,1:ny,ones(ny,1)) D;...
    sparse(nu,nx)   E                            sparse(1:nu,1:nu,ones(nu,1))];
Bc = [sparse(nx,nw); sparse(ny,nw); F];
Cc = [sparse(nz,nx) G sparse(nz,nu)];

% Compute the minimal realization
[Acmr,Bcmr,Ccmr,Ejunk,signalmask] = smreal(Ac,Bc,Cc,[]);