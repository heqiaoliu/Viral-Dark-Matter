function currentroots_listener(hObj, eventData)
%CURRENTROOTS_LISTENER Listener to the currentroots

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:10:19 $

if nargin > 1 && ischar(eventData)
    feval(eventData, hObj);
else
    setcolors(hObj);
    setconjugate(hObj);
    update_action(hObj);
    update_currentvalue(hObj);
end

% --------------------------------------------------------------
function update_currentvalue(hObj)

h = get(hObj, 'Handles');

if length(hObj.CurrentRoots) == 1
    cv   = getcurrentvalue(hObj);
    if strcmpi(hObj.CoordinateMode, 'Polar'),
        one = abs(cv);
        two = angle(cv);
    else
        one = real(cv);
        two = imag(cv);
    end
    rstr = num2str(one);
    istr = num2str(two);
    enabState = hObj.Enable;
else
    istr = '';
    rstr = '';
    enabState = 'Off';
end

set(h.real, 'String', rstr);
set(h.imaginary, 'String', istr);

if ~strcmpi(get(h.real, 'Enable'), enabState),
    setenableprop([h.real h.imaginary], enabState);
end

% --------------------------------------------------------------
function update_action(hObj)

h = get(hObj, 'Handles');

if isempty(hObj.CurrentRoots)
    enabState = 'Off';
else
    enabState = 'On';
end

set(convert2vector(h.menus.action), 'Enable', enabState);

set([h.menus.action.deletecurrentroots h.contextmenu.deletecurrentroots], 'Label', ...
    sprintf('Delete current %s', getcurrenttype(hObj)));

% --------------------------------------------------------------
function setcolors(hObj)

cPZ = get(hObj, 'CurrentRoots');

set(setdiff(get(hObj, 'Roots'), cPZ), 'Current', 'Off');
set(cPZ, 'Current', 'On');
    
% --------------------------------------------------------------
function setconjugate(hObj)

hC = get(hObj, 'CurrentRoots');
h  = get(hObj, 'Handles');

switch length(hC)
case 1
    set(hObj, 'ConjugateMode', hC.Conjugate);
    
    enabState = hObj.Enable;
case 0
    enabState = hObj.Enable;
otherwise
    if all(strcmpi(get(hC, 'Conjugate'), 'On')) || ...
            all(strcmpi(get(hC, 'Conjugate'), 'Off')),
        enabState = hObj.Enable;
        cmode = hC(1).Conjugate;
    else
        enabState = 'off';
        cmode     = 'off';
    end
end

set(h.conjugatemode, 'Enable', enabState);

% [EOF]
