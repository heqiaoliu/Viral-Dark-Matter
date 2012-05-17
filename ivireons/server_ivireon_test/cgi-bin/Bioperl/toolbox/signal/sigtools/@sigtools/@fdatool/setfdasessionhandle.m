function setfdasessionhandle(h,hFig)
%SETFDASESSIONHANDLE  Set the handle to an FDATool session.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/13 00:30:42 $ 


ud = get(hFig,'userdata');

ud = setfield(ud,'sessionHandle',h);

set(hFig,'userdata',ud);

