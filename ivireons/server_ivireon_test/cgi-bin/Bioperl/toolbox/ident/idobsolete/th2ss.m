function [a,b,c,d,k,x0,da,db,dc,dd,dk,dx0]=th2ss(th)
%TH2SS  Transforms a model in THETA-format to state-space.
%   OBSOLETE function. Use SSDATA instead.
%
%   [A,B,C,D,K,X0]=TH2SS(TH)
%
%   TH: The model, defined in the THETA format (see also THETA).
%
%   A,B,C,D,K,X0 : The matrices in the state-space description
%
%   Xn = A X + B u + K e       X0 initial value
%   y  = C X + D u + e
%
%   Here Xn is the derivative of X or the next value of X, depending
%   on whether TH is denoted as continuous or discrete time.
%
%   With [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = TH2SS(TH) also the
%   standard deviations of the matrix elements are computed.
%   See also TH2FF, TH2POLY, TH2TF and TH2ZP.

%   L. Ljung 10-2-90
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2005/12/22 18:12:40 $

if nargin < 1
    disp('Usage: [A,B,C,D,K,X0] = TH2SS(TH)')
    disp('       [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = TH2SS(TH)')
    return
end
if ~isa(th,'idmodel')
    error(sprintf(['The argument to th2ss must be an IDMODEL object.',...
        '\nUse TH2IDO to convert the old THETA-format model to IDMODEL.']))
end
[a,b,c,d,k,x0,da,db,dc,dd,dk,dx0]=ssdata(th);
