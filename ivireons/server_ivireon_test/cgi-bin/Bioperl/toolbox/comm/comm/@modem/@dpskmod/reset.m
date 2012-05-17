function reset(h)
%RESET Reset the modulator object H to its initial state. 

% @modem/@dpskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:20 $

h.PrivPhaseState = h.InitialPhase;