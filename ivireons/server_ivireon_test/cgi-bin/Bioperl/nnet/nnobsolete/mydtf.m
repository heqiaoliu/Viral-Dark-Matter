function d = mydtf(n,a)
%MYDTF Example custom transfer derivative function of MYTF.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Use this function as a template to write your own function.
%  
%  This function is obselete.
%  Use TEMPLATE_TRANSFER to design your function.

nnerr.obs_fcn('mytf','Use TEMPLATE_TRANSFER to design your function.')

%  Use this function as a template to write your own function.
%  
%  Syntax
%
%    dA_dN = mydtf(N,A)
%      N - SxQ matrix of Q net input (column) vectors.
%      A - SxQ matrix of Q output (column) vectors.
%      dA_dN - SxQ derivative dA/dN.
%
%  Example
%
%    n = -5:.1:5;
%    a = mytf(n);
%    da_dn = mydtf(n,a);
%    subplot(2,1,1), plot(n,a)
%    subplot(2,1,2), plot(n,da_dn)

% Copyright 1997-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

% **  Replace the following calculation with your
% **  derivative calculation.

d = -8*n.^7.*a.^2;

% **  Note that you have both the transfer functions input N and
% **  output A available, which can often allow a more efficient
% **  calculation of the derivative than with just N.
