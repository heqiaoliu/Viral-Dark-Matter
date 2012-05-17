function T = popundo(r)
%POPUNDO  Pops last transaction in Undo stack.

%   Author: P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:17:05 $

% Get last transaction
T = r.Undo(end);

% Remove it from Undo stack
r.Undo = r.Undo(1:end-1);

% Add it to redo stack
r.Redo = [r.Redo ; T];
