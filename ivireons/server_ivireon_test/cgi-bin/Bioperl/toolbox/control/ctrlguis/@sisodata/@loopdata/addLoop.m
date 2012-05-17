function addLoop(this,TunedLoops)
% addLoop  Adds a loop to loopdata and initialized listeners

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2008/09/15 20:36:38 $

% Append Loops to the list
this.L = [this.L; TunedLoops];


% Add listeners to the loops
for ct = 1:length(TunedLoops);
    TunedLoops(ct).addListeners(this);
end
    