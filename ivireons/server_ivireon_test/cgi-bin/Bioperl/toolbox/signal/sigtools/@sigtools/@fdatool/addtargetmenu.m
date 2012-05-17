function hMenu = addtargetmenu(hFDA, lbl, cb, tag)
%ADDTARGETMENU Adds a submenu to the Targets menu on FDATool.
%   ADDTARGETMENU(H,LABEL,CB,TAG) Adds a submenu to the Targets menu
%   of the FDATool associated with H with the string of equal to be 
%   LABEL, the callback equal to CB and the tag equal to TAG.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2007/12/14 15:21:03 $ 

error(nargchk(3,4,nargin,'struct'));
if nargin < 4, tag = ''; end

h = get(hFDA, 'Handles');

% Find the "Targets" menu.
hTargetsMenu = findall(h.menus.main,'tag','targets');
pos = get(hTargetsMenu,'Position');

nChild = length(get(hTargetsMenu, 'Children'));

if isequal(nChild, 0),
    sep = 'Off';
else
    sep = 'On';
end

% Create a submenu under the "Targets" menu.
hMenu = addmenu(hFDA,[pos nChild+1], lbl, cb, tag, sep);

% [EOF]
