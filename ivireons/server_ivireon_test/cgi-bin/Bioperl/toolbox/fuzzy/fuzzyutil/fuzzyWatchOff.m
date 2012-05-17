function fuzzyWatchOff(figNumber)
% FUZZYWATCHOFF  Sets the current figure pointer to the arrow.
%   WATCHOFF(figNumber) will set the figure figNumber's pointer
%   to an arrow. If no argument is given, figNumber is taken to
%   be the current figure.
%
%   See also WATCHON.

% Author(s): Rong Chen 09-Nov-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/01/25 21:37:38 $

% If watchon is used before a window has been opened, it will 
% set the figNumber to the flag NaN, which is why the next line
% checks to make sure that the figNumber is not NaN before resetting
% the pointer.
if nargin<1,
    figNumber=gcf;
end
if ishghandle(figNumber)
    set(figNumber,'Pointer','arrow');
end
