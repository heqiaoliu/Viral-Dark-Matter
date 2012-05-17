function X = conformalForward2(U, t)
% conformalForward2 Forward transformation with negative square root.
%
% Supports conformal transformation demo, ipexconformal.m
% ("Exploring a Conformal Mapping").

% Copyright 2005-2009 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2009/11/09 16:24:46 $

W = complex(U(:,1),U(:,2));
Z = W - sqrt(W.^2 - 1);
X(:,2) = imag(Z);
X(:,1) = real(Z);
