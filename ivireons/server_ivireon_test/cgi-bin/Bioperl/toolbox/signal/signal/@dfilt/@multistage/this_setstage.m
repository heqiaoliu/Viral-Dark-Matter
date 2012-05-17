function s = this_setstage(Hd,s) 
%THIS_SETSTAGE PreSet function for the stage property.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/13 05:03:29 $

% Create a listener for the stage
l  = handle.listener(s, 'clearmetadata', @clearmetadata); 
set(l,  'callbacktarget', Hd);
set(Hd, 'clearmetadatalistener', l);

clearmetadata(Hd);

