%NEW_SYSTEM Create a new empty Simulink system.
%   NEW_SYSTEM('SYS') creates a new empty system with the specified name.
%
%   An optional second argument can be used to specify the system type.
%   NEW_SYSTEM('SYS','Library') creates a new empty library,
%   and NEW_SYSTEM('SYS','Model') creates a new empty system.
%
%   An optional third argument can be used to specify a subsystem
%   whose contents should be copied into the new model. This third
%   argument can only be used when the second argument is 'Model'.
%   NEW_SYSTEM('SYS','MODEL','FULL_PATH_TO_SUBSYSTEM') creates a new
%   model populated with the blocks in the subsystem.
%
%   Another optional argument, 'ErrorIfShadowed', can be used to specify
%   that the command should error out if another model, MATLAB file or 
%   variable exists on the MATLAB path.
%   NEW_SYSTEM('SYS','MODEL','ERRORIFSHADOWED') will try to create a
%   new model named 'SYS' unless that name exists on the MATLAB path.
%
%   Note that NEW_SYSTEM does not open the system or library window.
%
%   Examples:
%   
%       new_system('mysys')
%   
%   creates, but does not open, a new system named 'mysys'.
%   
%       new_system('mysys','Library')
%
%   creates, but does not open, a new library named 'mysys'.
%
%       new_system('vdp','Model','ErrorIfShadowed')
%
%   will error out because 'vdp' is already on the MATLAB path.
%  
%       load_system('f14')
%       new_system('mysys','Model','f14/Controller')
%
%   creates, but does not open, a new model named 'mysys' that is
%   populated with the same blocks in the subsystem named 'Controller'
%   in the 'f14' demo model.
%   
%   See also OPEN_SYSTEM, CLOSE_SYSTEM, SAVE_SYSTEM.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.17.2.8 $
%   Built-in function


