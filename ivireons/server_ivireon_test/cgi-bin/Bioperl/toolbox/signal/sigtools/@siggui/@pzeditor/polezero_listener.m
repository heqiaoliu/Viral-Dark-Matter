function polezero_listener(hObj, eventData)
%POLEZERO_LISTENER Listener to the PoleZero property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:28 $


% msroots = get(hObj, 'MSRoots');
% msroots = [msroots{:}];

allnew = get(eventData, 'NewValue');

% set(setdiff(msroots, allnew), 'Enable', 'Off');
% set(allnew, 'Enable', 'On');

% Delete the old poles and zeros that have been removed.
oldpnzs = setdiff(hObj.Roots, allnew);
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
