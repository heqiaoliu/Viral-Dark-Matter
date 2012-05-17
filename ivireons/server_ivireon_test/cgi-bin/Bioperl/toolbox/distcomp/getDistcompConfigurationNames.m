function names = getDistcompConfigurationNames
%getDistcompConfigurationNames get the names of all configurations
%
% names = getDistcompConfigurationNames returns a cell array of string that are
% all the currently defined configurations.
%
% Example:
%     % Get all current configurations.
%     names = getDistcompConfigurationNames;
%

%  Copyright 2006-2007 The MathWorks, Inc.

%  $Revision: 1.1.6.3 $    $Date: 2007/12/10 21:27:45 $ 

names = distcomp.configserializer.getAllNames();

