function schemas = testtreegetinterface( whichMenu, callbackInfo )

% Copyright 2009 The MathWorks, Inc.

    schemas = {};
    switch( whichMenu )
        case 'Test:Tree:RootContextMenu'
            schemas = RootContextMenu( callbackInfo );
        case 'Test:Tree:ItemContextMenu'
            schemas = ItemContextMenu( callbackInfo );
    end
end

function schemas = RootContextMenu( callbackInfo )
    schemas = { @Create };
end

function schema = Create( callbackInfo )
    schema = sl_action_schema;
    schema.label = 'Create Item';
    schema.tag = 'Test:Tree:Create';
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.callback = CreateCommonCallback(schema.tag);
end

function schemas = ItemContextMenu( callbackInfo )
    schemas = { @Remove, @Rename };
end

function schema = Remove( callbackInfo )
    schema = sl_action_schema;
    schema.label = 'Remove';
    schema.tag = 'Test:Tree:Remove';
    callbackInfo.studio.raiseMenuGenerateEvent(schema.tag);
    schema.state = callbackInfo.studio.getMenuState(schema.tag);
    schema.callback = CreateCommonCallback(schema.tag);
end

function schema = Rename( callbackInfo )
    schema = sl_action_schema;
    schema.label = 'Rename';
    schema.tag = 'Test:Tree:Rename';
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
