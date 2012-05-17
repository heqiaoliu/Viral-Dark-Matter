function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:45 $

ed = DAStudio.EventDispatcher;
h.listeners = handle.listener(ed, 'PropertyChangedEvent', @(s,e)firepropertychange(h));

% [EOF]
