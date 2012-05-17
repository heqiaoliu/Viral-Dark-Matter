function boo = isExplicitODE(D)
% Checks whether DDAE can be reduced to ODE.
% Automatically true for non state-space models.

%	 Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:19 $
boo = true;