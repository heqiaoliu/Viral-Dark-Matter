function schemas = testappgetinterface( whichMenu, callbackInfo )

% Copyright 2009 The MathWorks, Inc.

    persistent iconsLoaded;

    if isempty(iconsLoaded)
        iconsLoaded = 1;
        im = DAStudio.IconManager;
        root = [matlabroot '/toolbox/shared/dastudio/resources/'];
        
        im.addFileToIcon( 'Test:TestTool', [root 'Configuration.png']);
    end

    schemas = {};
    switch( whichMenu )
        case 'Studio:MenuBar'
            schemas = MenuBar( callbackInfo );
        case 'Studio:ToolBars'
            schemas = ToolBars( callbackInfo );
        case 'Studio:EditMenu'
            schemas = EditMenu( callbackInfo );
    end
end

function schemas = MenuBar( callbackInfo )
    schemas = { @ToolsMenu };
end

% Tools Menu
% =========================================================================

function schema = ToolsMenu( callbackInfo )
    schema = sl_container_schema;
    schema.label = 'Tools';
    schema.tag = 'Test:ToolsMenu';
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.generateFcn = @ToolsMenuChildren;
end

function schemas = ToolsMenuChildren( callbackInfo )
    schemas = { @TestTool };
end

function schema = TestTool( callbackInfo )
    schema = sl_action_schema;
    schema.label = 'Test Tool';
    schema.tag = 'Test:TestTool';
    schema.icon = schema.tag;
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.callback = CreateCommonCallback(schema.tag);
end

function schemas = ToolBars( callbackInfo )
    % DIG currently ignores the schema.state for a toolbar, so if you want
    % to hide a tool bar, the way to do it is to not generate one at all.
    % If the generator function returns nothing, DIG will raise a warning.
    % SO, we need to check the state here.
    if isequal(callbackInfo.studio.getMenuState('Test:ToolBar'),'Hidden')
        schemas = {};
    else
        schemas = { @TestToolBar };
    end
end

function schema = TestToolBar( callbackInfo )
    schema = sl_container_schema;
    schema.label = 'Test Tool Bar';
    schema.tag = 'Test:ToolBar';
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.generateFcn = @TestToolBarChildren;
end

function schemas = TestToolBarChildren( callbackInfo )
    schemas = { @TestTool };
end

function schemas = EditMenu( callbackInfo )
    schemas = { @Create };
end

function schema = Create( callbackInfo )
    schema = sl_action_schema;
    schema.label = 'Create Item';
    schema.tag = 'Test:App:Create';
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.callback = CreateCommonCallback(schema.tag);
end

function func = CreateCommonCallback(tag)
    % Return an anonymous function representing the desired callback.
    % This is done in a helper function as a workaround to the issue
    % described in g486456.  If we create anonymous functions in the same
    % functions that have MCOS object parameters, those objects end up
    % getting unwanted references, because anonymous functions retain
    % access to their creator's workspace.
    func = @(c)CommonCallback(tag,c);
end

function CommonCallback(tag, callbackInfo)
    % CallbackInfo is expected to contain a handle to a Studio
    % The default callback raises a menu event in C++
    callbackInfo.studio.raiseMenuEvent(tag);
end
