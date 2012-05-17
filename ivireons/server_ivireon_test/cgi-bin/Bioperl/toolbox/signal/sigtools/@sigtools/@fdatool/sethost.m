function sethost(hFDA,fcnhandle)
%SETHOST Adds a host to FDATool.
%   SETHOST(HFDA,FCNH) Adds a host to the FDATool session specified by the
%   session HFDA.  The function handle, FCNH, points to a function which
%   will return the proper FDATool structure with host information.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2007/12/14 15:21:24 $ 

error(nargchk(2,2,nargin,'struct'));

hFig = get(hFDA,'figureHandle');
ud = get(hFig,'UserData');

% Assign into ud.host the output of fdaregisterhost (an FDATool host structure)
ud.host = feval(fcnhandle);
set(hFig,'UserData',ud);

% [EOF]
