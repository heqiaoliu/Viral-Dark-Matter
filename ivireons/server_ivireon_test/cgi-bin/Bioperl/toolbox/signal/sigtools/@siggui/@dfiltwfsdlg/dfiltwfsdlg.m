function h = dfiltwfsdlg(filtobjs)
%DFILTWFSDLG Create the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:18:20 $

error(nargchk(1,1,nargin,'struct'));

h = siggui.dfiltwfsdlg;

addcomponent(h, siggui.fsspecifier);

attachlisteners(h);

set(h, 'Filters', filtobjs);
set(h, 'isApplied', 1);

% ---------------------------------------------------------------
function attachlisteners(h)

l = handle.listener(h, h.findprop('Filters'), 'PropertyPostSet', ...
    @lclfilter_listener);

set(l, 'CallbackTarget', h);
set(h, 'FilterListener', l);

% ---------------------------------------------------------------
function lclfilter_listener(h, eventData)

filter_listener(h, eventData);

% [EOF]
