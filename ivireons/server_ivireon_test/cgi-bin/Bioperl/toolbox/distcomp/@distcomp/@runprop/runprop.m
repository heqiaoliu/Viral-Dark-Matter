function obj = runprop
; %#ok Undocumented
%RUNPROP concrete constructor for this class
%
%  OBJ = RUNPROP

%  Copyright 2000-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/11/04 21:16:07 $


obj = distcomp.runprop;
obj.DependencyDirectory = [tempname, 'rp', num2str(system_dependent('getpid'))];
obj.HasSharedFilesystem = true;
obj.AppendPathDependencies = true;
obj.AppendFileDependencies = true;
obj.IsFirstTask = true;
obj.LocalSchedulerName = 'runner';
obj.DecodeArguments = {};
obj.ExitOnTaskFinish = false;
obj.CleanUpDependencyDirOnTaskFinish = false;