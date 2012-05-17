function exportToFile(obj, filename)
; %#ok Undocumented
%Writes all the information in this object to the specified file.
%

%  Copyright 2007-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.2 $  $Date: 2009/04/15 22:58:16 $ 

allValues = obj.pGetStruct();
% Save the version number so that we can later have the importing handle
% multiple versions.
currVersionString = char(com.mathworks.toolbox.distcomp.util.Version.VERSION_STRING);
currVersionNum = com.mathworks.toolbox.distcomp.util.Version.VERSION_NUM;
completeState = struct('Name', obj.ActualName, ...
                       'Values', allValues, ...
                       'Version', currVersionString, ...
                       'VersionNumber', currVersionNum); %#ok<NASGU>

% Force the use of a mat file so we are independent of the file name.
save(filename, '-struct', 'completeState', '-mat');
