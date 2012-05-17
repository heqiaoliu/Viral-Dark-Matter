function F = solveForSatAmp(A,L,w,A_r)
% Function to be used by fzero to solve for 
% |1+N_a(A)*L(jw)|*A = A_r for a saturation nonlinearity with slope 1 and
% upper/lower limit of 0.5
%
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/05/23 08:20:50 $

L_w = evalfr(L,1i*w);
N_A = saturationDF(0.5/A);
F = A_r-A*abs(1+N_A*L_w);

