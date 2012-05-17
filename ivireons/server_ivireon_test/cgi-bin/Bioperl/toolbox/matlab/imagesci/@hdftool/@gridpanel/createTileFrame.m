function [hTileFrame api] = createTileFrame(this, hParent)
%CREATETILEFRAME Construct a frame for the "TILE" subsetting method.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   HPARENT: the panel which will be our HG parent.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/06 14:22:46 $

    % Create the components.
    hTileFrame = uipanel('Parent', hParent);
    prefs = this.fileTree.fileFrame.prefs;
    topPanel = uiflowcontainer('v0', 'Parent', hTileFrame,...
            'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection', 'TopDown');

    % Create the 'Tile' panel
    [levelPanel, api, minSize] = this.createSingleEntryGroup(...
        topPanel, 'Tile Coordinates:', '1,1', prefs);

end

