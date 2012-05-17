function D = append(D1,D2)
% Appends inputs and outputs of two models.

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:12 $

% Sizes
[ny1,nu1,nf] = size(D1.Response); %#ok<NASGU>
[ny2,nu2,nf] = size(D2.Response); %#ok<NASGU>
R = D1.Response;
R(ny1+1:ny1+ny2,nu1+1:nu1+nu2,:) = D2.Response;

% From resulting model
D = ltipack.frddata(R,D1.Frequency,D1.Ts);
D.FreqUnits = D1.FreqUnits;
D.Delay = appendDelay(D1,D2);
