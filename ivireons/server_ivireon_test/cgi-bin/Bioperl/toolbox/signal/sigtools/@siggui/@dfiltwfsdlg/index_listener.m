function index_listener(hObj, varargin)
%INDEX_LISTENER Listener to the index property

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/28 19:13:00 $

if nargin == 2,
    indx  = get(varargin{1}, 'NewValue');
    oindx = get(hObj, 'Index');
else,
    indx  = get(hObj, 'Index');
    oindx = 1;
end

% Because this is a preset listener the setfunction check does not work.
% We must check the length of filters vs the indx ourselves.
if indx > length(get(hObj, 'Filters')), return; end

% Set the applied flag.  If we are going to or from 'Apply to All' we want
% to enable the Apply Button.
if ~indx*oindx, set(hObj, 'IsApplied', 0); end

% Set the combo to be a popup (read only) if we are going to an index of 0
h     = get(hObj, 'Handles');
findx = indx;
if length(hObj.BackupNames) > 1,
    m     = indx;
    indx  = indx + 1;
elseif indx == 0,
    indx = 1;
    m = 1;
else
    m = 1;
end
set(h.combo, 'Max', m, 'Value', indx);

% Set up the fsspecifier
setup_fsspecifier(hObj, findx);

% [EOF]
