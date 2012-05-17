function firepropertychange(h)
%FIREPROPERTYCHANGE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:15 $

ed = DAStudio.EventDispatcher;
ed.broadcastEvent('PropertyChangedEvent', h);

% [EOF]
