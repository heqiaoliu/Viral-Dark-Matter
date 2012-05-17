function saveasmmat( h, name )
%SAVEASM Save Figure as a MATLAB file and MAT-file for property values

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.9.4.3 $  $Date: 2010/04/21 21:31:53 $

% remove ext from filename so appropriate MATLAB file / MAT-file pairs get generated
[path, name, ext] = fileparts(name);

if ~isempty(find(name == '.'))
    error('MATLAB:saveasmmat:InvalidFilename', 'Invalid MATLAB file name: %s, . (dot) is not valid filename character.', filename);
end

hardcopy(h, '-dmfile', fullfile(path, name));
