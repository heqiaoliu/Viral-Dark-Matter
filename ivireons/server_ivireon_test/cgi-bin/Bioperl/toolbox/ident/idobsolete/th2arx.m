function [A,B,dA,dB]=th2arx(eta)
%TH2ARX converts a THETA-format model to an ARX-model.
%   OBSOLETE function. Use ARXDATA instead.
%
%   [A,B]=TH2ARX(TH)
%
%   TH: The model structure defined in the THETA-format (See also TEHTA.)
%
%   A, B : Matrices defining the ARX-structure:
%
%          y(t) + A1 y(t-1) + .. + An y(t-n) =
%          = B0 u(t) + ..+ B1 u(t-1) + .. Bm u(t-m)
%
%          A = [I A1 A2 .. An],  B=[B0 B1 .. Bm]
%
%
%   With [A,B,dA,dB] = TH2ARX(TH), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also ARX2TH, and ARX

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2005/12/22 18:12:37 $

if nargin < 1
    disp('Usage: [A,B,dA,dB] = TH2ARX(TH)')
    return
end
if ~isa(eta,'idmodel')
    error(sprintf(['The argument to th2arx must be an IDMODEL object.',...
        '\nUse TH2IDO to convert the old THETA-format model to IDMODEL.']))
end

[A,B,dA,dB] = arxdata(eta);
