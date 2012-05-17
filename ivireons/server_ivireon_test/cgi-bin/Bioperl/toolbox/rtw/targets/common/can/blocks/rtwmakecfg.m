function makeInfo=rtwmakecfg()
% RTWMAKECFG adds include and source directories to rtw make files. 
% makeInfo=RTWMAKECFG returns a structured array containing build info. 
% Please refer to the rtwmakecfg API section in the Real-Time workshop 
% Documentation for details on the format of this structure. 

% Copyright 1994-2005 The MathWorks, Inc.
% $Revision: 1.3.6.6 $ $Date: 2008/11/04 21:23:51 $

% Get hold of the fullpath to this file, without the filename itself
rootpath = fileparts(mfilename('fullpath')); 

% CAN blocks rely on the CAN_DATATYPE struct defined in can_message.h
makeInfo.includePath{1} = fullfile(matlabroot,'toolbox','shared','can','src',...
		                    'scanutil');

% CCP block needs include path for ccp_utils.h
makeInfo.includePath{2} = fullfile(matlabroot,'toolbox','rtw','targets',...
                         'common', 'can','blocks', 'tlc_c');


% CCP block source path for ccp_utils.c
makeInfo.sourcePath{1} = fullfile(matlabroot,'toolbox','rtw','targets',...
                         'common', 'can','blocks', 'tlc_c');

if vector_code_generation(bdroot)                     
   % Vector blocks rely on the Vector CAN Library C API during 
   % Code Generation
   makeInfo.includePath{2} = fullfile(rootpath, 'mex', 'vector');
   
   % Vector blocks reference the following precompiled library
   makeInfo.precompile = 1; 

   makeInfo.library(1).Name = 'vector_can_library_standalone';
   makeInfo.library(1).Location = rootpath;
   % Note: the 'dummy' module must be specified for the process to 
   % work correctly - the library will not be rebuilt
   makeInfo.library(1).Modules = { 'dummy' };
end;
