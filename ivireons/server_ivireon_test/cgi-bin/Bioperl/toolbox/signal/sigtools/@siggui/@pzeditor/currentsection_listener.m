function currentsection_listener(hObj, eventData)
%CURRENTSECTION_LISTENER Listener to the CurrentSection property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/22 20:33:15 $

if nargin > 1 && isstruct(eventData),
    allroots = eventData;
    roots = allroots(hObj.CurrentSection).roots;
else
    allroots = get(hObj, 'AllRoots');
    roots = get(hObj, 'Roots');
end
if isempty(allroots)
    return
end
allroots = [allroots.roots];

% Make sure that the non-currentsection roots are disabled and the
% currentsection roots are enabled.
set(setdiff(allroots, roots), 'Enable', 'Off', 'Current', 'Off');
set(roots, 'Enable', hObj.Enable);

updatelimits(hObj);

h = get(hObj, 'Handles');
set(h.gain, 'string', num2str(hObj.Gain))

% [EOF]
