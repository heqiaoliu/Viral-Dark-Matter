function checkCC(CC,fcnName)
%CHECKCC validates bwconncomp structure

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/09/13 06:55:48 $

if ~isstruct(CC)
    eid = sprintf('Images:%s:expectedStruct',fcnName);
    error(eid, 'CC must be a structure.');
end

tf = isfield(CC, {'Connectivity','ImageSize','NumObjects','PixelIdxList'});
if ~all(tf)
    eid = sprintf('Images:%s:missingField',fcnName);
    error(eid, ...
        'CC must contain the following fields: Connectivity, ImageSize, NumObjects, and PixelIdxList.');
end
