function [A,B,dA,dB] = arxdata(M)
%ARXDATA returns the ARX-polynomials for a SISO IDPOLY model.
%
%   [A,B] = ARXDATA(M)
%
%   M: The IDPOLY model object. See help IDPOLY.
%
%   A, B : corresponding ARX polynomials
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%   With [A,B,dA,dB] = ARXDATA(M), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also IDARX, IDPOLY and ARX, POLYDATA, SSDATA.

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $ $Date: 2009/12/05 02:03:19 $


if M.nc + M.nd + M.nf ~= 0
  ctrlMsgUtils.error('Ident:analysis:arxdataCheck2')
end
 
[A,B,~,~,~,dA,dB] = polydata(M,1);
 
