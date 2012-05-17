function obj = abstractjob(obj, proxy)
; %#ok Undocumented
%ABSTRACTJOB abstract constructor for this class
%
%  OBJ = ABSTRACTJOB(OBJ, GROUP, LOCATION)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:33:47 $


% Special constructor to allow a template abstractjob to be created so that
% it can be used to read the actual job constructor
if isempty(obj)
    obj = distcomp.abstractjob;
end
obj.abstractdataentity(proxy);
% Define the type of this object for the serializer class
obj.Type = 'job';