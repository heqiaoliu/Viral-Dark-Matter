function obj = abstracttask(obj, proxy)
; %#ok Undocumented
%ABSTRACTTASK abstract constructor for this class
%
%  OBJ = ABSTRACTTASK(OBJ, PROXY)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:35:23 $


obj.abstractdataentity(proxy);
% Define the type of this object for the serializer class
obj.Type = 'task';