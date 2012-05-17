function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $ $Date: 2007/11/09 19:46:08 $

% Name of the subsystem which will show up in the SIMULINK Blocksets
% and Toolboxes subsystem.
% Example:  blkStruct.Name = 'DSP Blockset';
blkStruct.Name = sprintf('Control\nSystem\nToolbox');

% The function that will be called when the user double-clicks on
% this icon.
% Example:  blkStruct.OpenFcn = 'dsplib';
blkStruct.OpenFcn = 'ExampleTF=tf([1 0],[1 1]);cstblocks;';%.mdl file

% The argument to be set as the Mask Display for the subsystem.  You
% may comment this line out if no specific mask is desired.
% Example:  blkStruct.MaskDisplay = 'plot([0:2*pi],sin([0:2*pi]));';
blkStruct.MaskDisplay = 'disp(''LTI'')';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it
Browser(1).Library = 'cstblocks';
Browser(1).Name    = 'Control System Toolbox';
Browser(1).IsFlat  = 1;

blkStruct.Browser = Browser;

% Define information for model updater for updating obsolete blocks
blkStruct.ModelUpdaterMethods.fhUpdateModel = @cstBlocksSlupdateHelper;


