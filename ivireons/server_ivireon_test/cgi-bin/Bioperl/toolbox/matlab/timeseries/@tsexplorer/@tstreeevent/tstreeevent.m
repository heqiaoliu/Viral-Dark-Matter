function h = tstreeevent(hSrc,action,node)
%DATAEVENT  Subclass of EVENTDATA to handle tree structure changes

%   Author(s): 
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:56:00 $


% Create class instance
h = tsexplorer.tstreeevent(hSrc,'tsstructurechange');
set(h,'Action',action,'Node',node)
