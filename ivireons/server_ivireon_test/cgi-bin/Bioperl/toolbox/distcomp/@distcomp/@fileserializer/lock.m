function aLock = lock(obj, entity)
; %#ok Undocumented
%lock
%
%  LOCK(SERIALIZER, LOCATION)

% Copyright 2007-2008 The MathWorks, Inc.
    
%  $Revision: 1.1.6.2 $    $Date: 2008/03/31 17:07:23 $
    
numEntities = numel(entity);
% If there are no entities then return an empty array early
if numEntities == 0 || numEntities > 1
    error('distcomp:fileserializer:InvalidLock', 'Only one entity can be locked');
end

storage = obj.Storage;
% Ensure that we have a location plus a file seperator
locationStart = fullfile(storage.StorageLocation, filesep);
% Get the full path to the file
thisLocation = [locationStart entity.pGetEntityLocation '.lockstate'];
% Make a FileOutputStream from which we can get the FileChannel
fos = java.io.FileOutputStream(java.lang.String(thisLocation), true);
fc = fos.getChannel();
% Loop in tryLock until we manage to get the lock - we use tryLock and pause 
% rather than lock because otherwise MATLAB might hang
while true
    try
        aLock = fc.tryLock();
        if ~isempty(aLock)
            return;
        end
        pause(0.1);
    catch e %#ok<NASGU>
    end
end
