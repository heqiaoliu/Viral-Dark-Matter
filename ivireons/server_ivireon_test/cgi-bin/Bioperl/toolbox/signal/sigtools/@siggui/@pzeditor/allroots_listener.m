function allroots_listener(hObj, eventData)
%ALLROOTS_LISTENER Listener to the allroots property

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2008/08/22 20:33:14 $

if nargin > 1,
    
    allroots = get(eventData, 'NewValue');
    if isempty(allroots)
        allnew = [];
    else
        allnew = [allroots.roots];
    end
    
    oldroots = get(hObj, 'AllRoots');
    if ~isempty(oldroots)
        oldroots = [oldroots.roots];
    end
    
    % Delete the old poles and zeros that have been removed.
    oldpnzs = setdiff(oldroots, allnew);
    if ~isempty(oldpnzs),
        for indx = 1:length(oldpnzs),
            unrender(oldpnzs(indx));
        end
    end
    
    % Draw any new poles or zeros that might have been added.
    newpnzs = setdiff(allnew, hObj.Roots);
    fixcurrentpz(hObj, allnew);
    if ~isempty(newpnzs),
        draw(hObj, newpnzs);
    end
    updatelimits(hObj, allnew);
    currentsection_listener(hObj, get(eventData, 'NewValue'));
    h = get(hObj, 'Handles');
    delete(h.numbers);
    if isempty(allnew)
        h.numbers = [];
    else
        h.numbers = drawpznumbers(double(allnew, 1), h.axes);
    end
    set(hObj, 'Handles', h);
else
    allroots = get(hObj, 'AllRoots');
end

if length(allroots) == 1,
    enabState = 'Off';
else
    enabState = 'On';
end

h = get(hObj, 'Handles');

if isempty(allroots), allroots = 1; end
set(h.currentsection, 'String', [1:length(allroots)]);

setenableprop(h.currentsection, enabState);

% --------------------------------------------------------
function fixcurrentpz(hObj, apz)

cpz = get(hObj, 'CurrentRoots');

if isempty(apz),
    set(hObj, 'CurrentRoots', []);
elseif length(cpz) == 1,
    cpz = find(apz, 'Imaginary', cpz.Imaginary, 'Real', cpz.Real, '-isa', class(cpz));
    set(hObj, 'CurrentRoots', cpz);
end

% [EOF]
