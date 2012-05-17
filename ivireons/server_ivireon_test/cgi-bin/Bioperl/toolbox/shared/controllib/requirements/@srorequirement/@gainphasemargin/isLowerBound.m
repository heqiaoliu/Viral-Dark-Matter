function lowerBound = isLowerBound(this)
% ISLOWERBOUND returns lowerbound state of requirement
%

% Author(s): A. Stothert 23-Dec-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:51 $

%Gain and phase margins are always lower bounds
lowerBound = true(size(this));
 
