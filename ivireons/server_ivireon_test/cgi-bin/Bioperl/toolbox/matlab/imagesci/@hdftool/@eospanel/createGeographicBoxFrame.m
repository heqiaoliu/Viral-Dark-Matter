function [hFrame api] = createGeographicBoxFrame(this, hParent, additionalGroupCB)
%CREATEGEOGRAPHICBOXFRAME Implement the "geographic box" subsetting method.
%   This consists of latitude and longitude which specify the corners of a 
%   box.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent for the frame.
%   ADDITIONALGROUPCB: Callback to add a group to our layout.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/02/06 14:22:35 $

    % Create the components.
    hFrame = uipanel('Parent',hParent);

    prefs = this.fileTree.fileFrame.prefs;
    
    % layout the top left panel
    topPanel = uiflowcontainer('v0', 'Parent',hFrame,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','LeftToRight');

    topLeftPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');
    topMiddlePanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
        	'FlowDirection','TopDown');
    topRightPanel = uiflowcontainer('v0', 'Parent',topPanel,...
	        'BackgroundColor', get(0,'defaultUiControlBackgroundColor'), ...
            'FlowDirection','TopDown');

    [cornerboxPanel, cornerboxApi, cbSize] = this.createBoxCornerGroup(topLeftPanel, '0', prefs);
    if nargin >= 3
        additionalGroupCB(topMiddlePanel);
    end
    [timePanel, timeApi, tSize] = this.createEntryFieldGroup(topMiddlePanel, [1 2], '', {'Start:','Stop:'}, 'Time (optional)', prefs );

    width  = cbSize(1);
    height = cbSize(2);
    set(topLeftPanel,...
        'WidthLimits',[width width],...
        'HeightLimits',[height height]);
    if nargin < 3    
        width  = prefs.charPad(1) + tSize(1);
        height = prefs.charPad(2) + tSize(2);
    else
        sizeLimits = get(topMiddlePanel, {'WidthLimits','HeightLimits'});
        width  = prefs.charPad(1) + max(tSize(1), sizeLimits{1}(1));
        height = prefs.charPad(2) + tSize(2) + sizeLimits{2}(1);
    end
    set(topMiddlePanel,...
        'WidthLimits',[width width],...
        'HeightLimits',[height height]);

    % Create and layout the user defined panel
    [userdefPanel, userdefApi, udSize] = this.createUserDefinedGroup(topRightPanel, '', 'User-defined (optional)', prefs);

    % Create the API
    api.getBoxCornerValues  = @getBoxCorners;
    api.getTime             = @getTime;
    api.getUserDefined      = @getUserDefined;
    api.reset               = @reset;
    api.updateUserDefPanel  = @updateUserDefinedPanel;

    %===========================================================
    function updateUserDefinedPanel(istruct)
        if userdefApi.getLength() == length(istruct.Dims)
            userdefApi.setInfoStruct(istruct);
            return;
        end
        [newPanel,userdefApi,udSize] = this.createUserDefinedGroup(topRightPanel, '', 'User-defined (optional)', prefs);
        delete(userdefPanel);
        userdefPanel = newPanel;
    end

    %==================================
    function out = getBoxCorners()
        out = [cornerboxApi.getBoxCorner1Values()';...
            cornerboxApi.getBoxCorner2Values()'];
    end

    %==================================
    function out = getTime()
        out = timeApi.getValues()';
    end

    %==================================
    function out = getUserDefined()
        selFields = userdefApi.getSelectedFieldNames();
        minVals   = userdefApi.getMinValues();
        maxVals   = userdefApi.getMaxValues();

        out = [selFields, minVals, maxVals];
    end

    %==================================
    function reset(istruct)
        cornerboxApi.reset();
        timeApi.reset();
        userdefApi.reset();
        if nargin == 1
            updateUserDefinedPanel(istruct);
        end
    end

end
