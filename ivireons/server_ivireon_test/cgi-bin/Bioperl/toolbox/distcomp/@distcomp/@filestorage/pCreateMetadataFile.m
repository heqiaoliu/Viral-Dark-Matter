function OK = pCreateMetadataFile(storage, parent)
; %#ok Undocumented
%pCreateMetadataFile 
%
% pCreateMetadataFile(fileStorage, parent)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/05/05 21:36:01 $

% Default return
OK = false;

metadataFilename = storage.pGetMetadataFilename(parent);
% These fields are intended for use as follows - most jobs will be a
% DefaultJobConstructor. Those that aren't should add their constructor to
% the list of alternatives if it isn't there already and their ID to the
% list of ID's and the index of their constructor in the same index of the
% AlternativeConstructorIndex array.
structToSave = struct( ...
    'DefaultConstructor', @distcomp.simplejob, ...
    'AlternativeConstructors', {{}}, ...
    'IDsUsingAlternative', [], ...
    'AlternativeConstructorIndex', [] ...
    );
try
    % Try and save the metadata file
    save(metadataFilename, '-struct', 'structToSave');
catch err
    rethrow(err);
end
OK = true;