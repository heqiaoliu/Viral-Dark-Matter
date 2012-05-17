function pSetExecutableStrings(obj, MatlabExecutable, MatlabArguments)
% pSetStorageStrings private function to set values that need to be passed
% to remote matlabs's started by schedulers


%  Copyright 2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/06/27 22:38:51 $ 

obj.MatlabExecutable = MatlabExecutable;
obj.MatlabArguments  = MatlabArguments;

