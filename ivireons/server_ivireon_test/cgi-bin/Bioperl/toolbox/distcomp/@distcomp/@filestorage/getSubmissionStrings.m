function [location, constructor] = getSubmissionStrings(storage)
; %#ok Undocumented
%getSubmissionStrings 
%
%  [LOCATIONSTRING, CONSTRUCTORSTRING] = getSubmissionStrings(STORAGE)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:24 $


location = sprintf('PC{%s}:UNIX{%s}:', storage.WindowsStorageLocation, storage.UnixStorageLocation);
constructor = 'makeFileStorageObject';