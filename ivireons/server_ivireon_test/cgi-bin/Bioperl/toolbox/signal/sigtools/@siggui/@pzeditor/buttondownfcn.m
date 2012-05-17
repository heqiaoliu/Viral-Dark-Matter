function buttondownfcn(this)
%BUTTONDOWNFCN ButtonDown Function for the PZ Editor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2008/05/31 23:28:13 $

% Get the handle to the current PZ from the callback object (the object
% that was clicked).
hcbo = get(this, 'CallbackObject');
hC   = getappdata(hcbo, 'RootObject');

switch lower(get(this, 'ButtonClick')),
    case 'left'
        
        % left button clicks set the CurrentRoots
        set(this, 'CurrentRoots', hC);
        set(this, 'CurrentRoots', hC); 
        
        % Perform the specified action
        perform_action(this);
        set(this, 'Action', 'move pole/zero');
    case 'right'
        
        % If the clicked object is the axes and we are on 'move' return.
        if strcmpi(get(hcbo, 'type'), 'axes') && strcmpi(this.Action, 'move pole/zero'),
            return;
        end
        
        % A right click will just set the CurrentRoots.  This is so that we
        % can put the pzeditor functionality on a contextmenu
        set(this, 'CurrentRoots', union(hC, get(this, 'CurrentRoots')));
        if ~strcmpi(get(this, 'Action'), 'move pole/zero')
            perform_action(this);
        end
    case 'shift'
        % Use SETXOR to add new poles/zeros and remove already selected
        % poles and zeros.
        set(this, 'CurrentRoots', setxor(get(this, 'CurrentRoots'), hC));
        
        perform_action(this);
end

% --------------------------------------------------------------
function perform_action(this)

cp   = checkforzero(this);
hcbo = get(this, 'CallbackObject');

switch lower(get(this, 'Action'))
    case 'add pole'
        hPZ = addpole(this, cp);
        set(this, 'CurrentRoots', hPZ);
    case 'add zero'
        hPZ = addzero(this, cp);
        set(this, 'CurrentRoots', hPZ);
    case 'move pole/zero'
        
        % If the clicked object is the axes select a region
        if strcmpi(get(hcbo, 'Type'), 'axes')
            lclselectregion(this);
        end
    case 'delete pole/zero'
        
        % Allow the deletion of multiple roots.
        if strcmpi(get(hcbo, 'Type'), 'axes'),
            lclselectregion(this);
        end
        
        % If there are any roots selected, delete them.
        if ~isempty(this.CurrentRoots),
            deletecurrentroots(this);
        end
end

% --------------------------------------------------------------
function cp = checkforzero(this)

% If the user clicked significantly close to 0 on the imaginary.  assume it
% is zero so that we don't create a complex filter.
h  = get(this, 'Handles');
cp = get(this, 'CurrentPoint');

ylim = get(h.axes, 'YLim');

if abs(cp(2)) < diff(ylim)/50, cp(2) = 0; end

% --------------------------------------------------------------
function lclselectregion(this)

hPZs = get(this, 'Roots');

if isempty(hPZs),
    
    % If there are no poles or zeros don't allow selection.
    hPZ = [];
else
    
    point1 = get(this, 'CurrentPoint');
    rbbox;
    point2 = get(this.CallbackObject, 'CurrentPoint');
    point2 = point2(1,1:2);
    
    hPZ = inside(hPZs, point1, point2);
end

set(this, 'CurrentRoots', hPZ);

% [EOF]
