function D = append(D1,D2)
% Appends inputs and outputs of two models.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:25 $
[ny1,nu1] = size(D1.num);
[ny2,nu2] = size(D2.num);
pad12 = cell(ny1,nu2);
pad21 = cell(ny2,nu1);
pad12(:) = {0};  pad21(:) = {0};
num = [D1.num pad12;pad21 D2.num];
pad12(:) = {1};  pad21(:) = {1};
den = [D1.den pad12;pad21 D2.den];

% Form resulting model
D = ltipack.tfdata(num,den,D1.Ts);
D.Delay = appendDelay(D1,D2);

