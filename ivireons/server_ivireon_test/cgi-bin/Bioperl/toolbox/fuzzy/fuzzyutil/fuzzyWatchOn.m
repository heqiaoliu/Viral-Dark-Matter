function figNumber=fuzzyWatchOn 
% FUZZYWATCHON  Sets the current figure pointer to the watch.
%   figNumber=WATCHON will set the current figure's pointer
%   to a watch.
%
%   See also WATCHOFF.
%
 
% Author(s): Rong Chen 09-Nov-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/12/05 02:01:22 $

% If there are no windows open, just set figNumber to a flag value.
if isempty(get(0,'Children')),
    figNumber=NaN;
else
    figNumber=gcf;
    set(figNumber,'Pointer','watch');
end
