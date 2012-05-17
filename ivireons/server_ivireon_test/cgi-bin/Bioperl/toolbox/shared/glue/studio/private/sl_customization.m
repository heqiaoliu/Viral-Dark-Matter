function sl_customization(cm)
    
    cm.addCustomMenuFcn('GenericM3I:MenuBar', @CustomMenus );
    
end

function schemas = CustomMenus( callbackInfo )
    schemas = { @ToolsMenu };
end

function schema = ToolsMenu( callbackInfo )
    schema = sl_container_schema;
    schema.label = '&Tools';
    schema.tag = 'GenericM3I:Tools';

    schema.generateFcn = @ToolsMenuChildren;
    
end

function schemas = ToolsMenuChildren( callbackInfo )
    schemas = { @FooBar, ...
                'separator'
              };
end

function schema = FooBar(callbackInfo)
    schema = sl_action_schema;
    schema.label = '&FooBar';
    schema.tag = 'GenericM3I:FooBar';

    schema.callback = 'disp(''foobar'')';
end