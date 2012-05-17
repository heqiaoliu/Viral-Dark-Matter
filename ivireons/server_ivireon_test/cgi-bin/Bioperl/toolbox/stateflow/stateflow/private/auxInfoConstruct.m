function emptyInfo = auxInfoConstruct()

%   Copyright 1995-2008 The MathWorks, Inc.

% Create an empty aux-info structure.
emptyInfo = struct(...
    'sourceFiles', [], ...
    'includeFiles', [], ...
    'includePaths', [], ...
    'linkObjects', [], ...
    'linkFlags', []);
