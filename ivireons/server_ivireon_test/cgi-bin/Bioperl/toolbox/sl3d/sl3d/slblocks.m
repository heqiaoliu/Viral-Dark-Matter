function blkStruct = slblocks
%SLBLOCKS Defines the block library for Simulink 3D Animation.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:15 $ $Author: batserve $

% Name of the subsystem which will show up in the
% Simulink Toolboxes subsystem.
blkStruct.Name = sprintf('Simulink\n3D Animation');

% The function that is called when
% the user double-clicks on this icon.
blkStruct.OpenFcn = 'vrlib';

blkStruct.MaskInitialization = '';

blkStruct.MaskDisplay = 'image(imread(''vrblockicon.png''))';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and its title
Browser(1).Library = 'vrlib';
Browser(1).Name    = 'Simulink 3D Animation';

blkStruct.Browser = Browser;

% define information for model updater
blkStruct.ModelUpdaterMethods.fhDetermineBrokenLinks = @sl3dBrokenLinksMapping;

% End of slblocks
