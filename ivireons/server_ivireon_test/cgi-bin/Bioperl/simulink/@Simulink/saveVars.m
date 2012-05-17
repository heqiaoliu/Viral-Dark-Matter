%SIMULINK.SAVEVARS Save workspace variables to MATLAB script.
%  
% Basic function syntax:
% ----------------------
%   Simulink.saveVars('filename')
%     Saves all workspace variables to MATLAB script, "filename.m".
%     Executing this script restores the variables into the current workspace.
%
%   Simulink.saveVars('filename', 'X', 'Y', 'Z')
%     Saves variables X, Y and Z.  The wildcard '*' can be used to save all
%     variables that match a pattern.
%
%   NOTE: 
%   - If MATLAB code cannot be generated for a variable, the variable is saved
%     into a corresponding MAT-file "filename.mat".
%
% Updating an existing file:
% --------------------------
%   Simulink.saveVars('filename', ..., '-update')
%     Resaves only those variables that are created by an existing MATLAB script.
%     The order of variables in the file is preserved.
%
%   Simulink.saveVars('filename', ..., '-append')
%     Saves workspace variables to an existing MATLAB script.
%     The order of existing variables in the file is preserved.
%     The code for any new variables is appended at the end of the file.
%
%
% Complete function syntax:
% -------------------------
%   [r1, r2] = Simulink.saveVars('filename', ..., 'updateOption', 'matversion');
% 
%   Simulink.saveVars has a similar syntax to MATLAB function SAVE. 
%   The syntax for specifying MAT-file version is the same as for SAVE.
%
% Input arguments:
%   1.filename:
%     Valid MATLAB file name (.m extension is optional).
%     This filename cannot match names of variables in workspace.
%
%     NOTE: 
%     - If MATLAB code cannot be generated for a variable, the variable is saved
%       into a corresponding MAT-file "filename.mat".
%         
%   2.list of variable names: (optional)
%     Explicit list of variables (e.g., 'X', 'Y', 'Z')
%     or list of variables matching wildcard (e.g., 'X*')
%     or a regular expression (e.g., '-regexp', 'expr1', 'expr2').
%
%   3.updateOption: (optional)
%     -create: Create new MATLAB script file (default behavior).
%     -update: Update existing file (only save variables already in file).
%     -append: Update existing file (update existing variables and
%                                    append new variables to the end of file).
%
%   4.userConfiguration: (optional)
%     -maxnumel:  Set the maximum number of elements of an array that 
%                 saveVars can save to MATLAB script file.
%                 Must be followed by an integer between 0 and 10000 (e.g., '-maxnumel', 1000).
%     -maxlevels: Set the maximum number of levels of an object, or nested cell/struct 
%                 hierarchy that saveVars can save to MATLAB script file. 
%                 Must be followed by an integer between 0 and 200 (e.g., '-maxlevels', 20).
%     -textwidth: Set the text wrap width for MATLAB script file.
%                 Must be followed by an integer between 32 and 256 (e.g., '-textwidth', 76).
%
%
% Return arguments:
%   1.List of variables saved to MATLAB script.
%   2.List of variables saved to MAT-file.
%   
% See also SAVE

%   Copyright 2009 The MathWorks, Inc.
