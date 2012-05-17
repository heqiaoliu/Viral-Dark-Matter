function h = dataChangeEvent(hSrc,Action,Ind)
%DataChangeEvent  Subclass of EVENTDATA to handle tree structure changes

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/05/27 14:11:49 $


% Create class instance
h = tsdata.dataChangeEvent(hSrc,'datachange');
set(h,'Action',Action,'Index',Ind);
