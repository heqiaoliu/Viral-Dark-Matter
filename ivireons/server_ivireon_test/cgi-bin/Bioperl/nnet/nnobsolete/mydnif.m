function d = mydnif(z,n)
%MYDNIF Example custom net input derivative function of MYNIF.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Use this function as a template to write your own function.
%  
%  This function is obselete.
%  Use TEMPLATE_NET_INPUT to design your function.

nnerr.obs_fcn('mynif','Use TEMPLATE_NET_INPUT to design your function.')

%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    dN_dZ = dtansig(Z,N)
%      Z - SxQ matrix of Q weighted input (column) vectors.
%      N - SxQ matrix of Q net input (column) vectors.
%      dN_dZ - SxQ derivative dN/dZ.
%
%  Example
%
%    z1 = rand(4,5);
%    z2 = rand(4,5);
%    z3 = rand(4,5);
%    n = mynif(z1,z2,z3)
%    dn_dz1 = mydnif(z1,n)
%    dn_dz2 = mydnif(z2,n)
%    dn_dz3 = mydnif(z3,n)

% Copyright 1997-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

% ** Replace the following calculation with your
% **  derivative calculation.

d = n.^2 .* z.^2;

% **  Note that you have both the net input Z in question
% **  and output N available to calculate the derivative.
