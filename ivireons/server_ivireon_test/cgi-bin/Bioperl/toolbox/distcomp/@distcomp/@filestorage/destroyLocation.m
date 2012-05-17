function destroyLocation(obj, entityLocation)
; %#ok Undocumented
%destroyLocation remove a location from storage
%
%  DESTROYLOCATION(OBJ, ENTITYLOCATION)
%
% The input parent is a string without an extension, which uniquely
% identifies the parent of the locations we are trying to create

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.7 $    $Date: 2007/12/10 21:27:53 $

% Don't bother if the storage is read only
if obj.IsReadOnly
    error('distcomp:filestorage:InvalidFilePermissions', ...
        ['You do not have permission to write to the current StorageLocation : \n' ...
         '%s \n' ...
         'You should change directory to somewhere where you do have write permission'], obj.StorageLocation);
end

% Create a full location string
fullLocation = [obj.StorageLocation filesep entityLocation];
% Add .zip as a possible extension to delete because serializeForSubmission
% might have created that file
ext = [obj.Extensions ; '.zip'; '.lockstate'];
try
    % Turn off FileNotFound warning
    warningState1 = warning('off', 'MATLAB:DELETE:FileNotFound');
    warningState2 = warning('off', 'MATLAB:DELETE:Permission');
    % First try to remove the input files associated with the entity
    for i = 1:numel(ext)
        % It is possible that we will fail to delete a given file - don't
        % worry about this - we will delete the file when we delete the dir
        try
            delete([fullLocation ext{i}]);
        catch e %#ok<NASGU>
        end
    end
    warning(warningState2);
    warning(warningState1);
    % Turn off CouldNotRemove warning
    warningState = warning('off', 'MATLAB:RMDIR:CouldNotRemove');
    % Then remove any directories
    if exist(fullLocation, 'dir')
        % Again this might error - lack of permission or windows file locking
        try
            rmdir(fullLocation, 's');
        catch e %#ok<NASGU>
            % Fail to delete - ignore this as we will send the directory to
            % the deleteFileLater method of FileDeleter
        end
    end
    warning(warningState);
    % If the directory still exists then lets ask the JVM to remove it when
    % it terminates
    if exist(fullLocation, 'dir') && usejava('jvm')
        import com.mathworks.toolbox.distcomp.util.FileDeleter;
        file = java.io.File(fullLocation);
        FileDeleter.getInstance.deleteFileLater(file);
    end
    % Get the ID of the entity
    ID = pGetIDByName(obj, entityLocation);
    % Finally remove references to this entity from the metadata file
    parent = obj.pGetParentLocationFromEntityLocation(entityLocation);
    obj.pRemoveEntityFromMetadata(parent, ID);
catch err
    rethrow(err);
end