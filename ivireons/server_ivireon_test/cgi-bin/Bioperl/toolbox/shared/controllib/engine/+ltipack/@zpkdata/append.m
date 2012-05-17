function D = append(D1,D2)
% Appends inputs and outputs of two models.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:20 $

% Sizes
[ny1,nu1] = size(D1.k);
[ny2,nu2] = size(D2.k);
pad12 = cell(ny1,nu2);  pad12(:) = {zeros(0,1)};
pad21 = cell(ny2,nu1);  pad21(:) = {zeros(0,1)};

% From resulting model
D = ltipack.zpkdata([D1.z pad12;pad21 D2.z],...
   [D1.p pad12;pad21 D2.p],[D1.k zeros(ny1,nu2) ; zeros(ny2,nu1) D2.k],D1.Ts);
D.Delay = appendDelay(D1,D2);
