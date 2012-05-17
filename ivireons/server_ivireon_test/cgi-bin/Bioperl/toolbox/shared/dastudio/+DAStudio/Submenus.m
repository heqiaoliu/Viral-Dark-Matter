function func = Submenus( menuname )

    % initialize function list
    persistent menuMap;
    if isempty(menuMap)
        menuMap = initializeSubmenus;
    end
    
    func = {};
    if menuMap.isKey( menuname )
        func = menuMap( menuname );
    else
        func = DAStudio.makeCallback( menuname, @menu_SubmenuNotFound );
    end
end

function menuMap = initializeSubmenus
    menuMap = containers.Map;
    
    menuMap('OpenRecentMenu') = @menu_OpenRecentMenu;
    menuMap('CloseMenu') = @menu_CloseMenu;
    menuMap('DocksMenu') = @menu_DocksMenu;
    menuMap('TabsMenu') = @menu_TabsMenu;
    menuMap('StatusMenu') = @menu_StatusMenu;
end

function schema = menu_SubmenuNotFound( menuname, ~ )
    schema = DAStudio.ActionSchema;
    schema.label = 'Action Not Found';
    schema.tag = 'Studio:ActionNotFound';
    schema.userdata = menuname;
    schema.callback = @cbk_SubmenuNotFound;
end

function cbk_SubmenuNotFound( cbinfo )
    menuname = cbinfo.userdata;
    warning( 'Submenu ''%s'' not found.', menuname );
end

function schema = menu_OpenRecentMenu( cbinfo ) 
    schema = DAStudio.ContainerSchema;
    schema.label = xlate('Open Recent');
    schema.tag = 'Studio:OpenRecent';
    
    submenus = cbinfo.userdata.submenus;
    schema.userdata = cbinfo.userdata;
    schema.generateFcn = @gen_OpenRecentMenuGenerator;
    schema.state = 'Disabled';	            
end

function schemas = gen_OpenRecentMenuGenerator( ~ )
    schemas = { DAStudio.Actions( 'NotFound' )};
end

function schema = menu_CloseMenu( cbinfo )
    schema = DAStudio.ContainerSchema;
    schema.label = xlate('Close');
    schema.tag = 'Studio:Close';
    
    actions = cbinfo.userdata.actions;
    schema.childrenFcns = { 
            actions('CloseTab'), ...
            actions('CloseOtherTabs'), ...
            actions('CloseAllTabs'), ...
            actions('CloseWindow'), ...
            actions('CloseAllWindows')
          };           
end

% Edit Menu submenus

% View Menu submenus
function schema = menu_DocksMenu( cbinfo )
    schema = DAStudio.ContainerSchema;
    schema.label = xlate('Dock Windows');
    schema.tag = 'Studio:DocskMenu';
    
    schema.userdata = cbinfo.userdata;
    schema.generateFcn = @gen_DockMenuGenerator;
    docks = cbinfo.studio.getDockComponents();
    if isempty( docks )
        schema.state = 'Disabled';
    end
end

function schemas = gen_DockMenuGenerator( cbinfo )
    docks = cbinfo.studio.getDockComponents();
    schemas = {};
    actions = cbinfo.userdata.actions;
    if isempty( docks )
        schemas = { DAStudio.makeCallback( 'No Dock Windows', actions('DummyWidgetSchema') ) };
    else
        for i = 1:length(docks)
            oneWidget = docks{i};
            schemas = [ schemas { DAStudio.makeCallback( oneWidget, actions('DockWidgetSchema') ) } ];
        end
    end
end

function schema = menu_TabsMenu( cbinfo )
    schema = DAStudio.ContainerSchema;
    schema.label = xlate('Tabs');
    schema.tag = 'Studio:TabsMenu';
    tabs = cbinfo.studio.getTabComponents();
    
    schema.userdata = cbinfo.userdata;
    schema.generateFcn = @gen_TabsMenuGenerator;
    if isempty( tabs )
        schema.state = 'Disabled';
    end
end

function schemas = gen_TabsMenuGenerator( cbinfo )
    tabs = cbinfo.studio.getTabComponents();
    schemas = {};
    actions = cbinfo.userdata.actions;
    if isempty( tabs )
        schemas = { DAStudio.makeCallback( 'No Tabs', actions('DummyWidgetSchema') ) };
    else
        for i = 1:length(tabs)
            onewidget = tabs{i};
            %schemas = [ schemas { DAStudio.makeCallback( onewidget, actions('TabWidgetSchema') ) } ];
        end  
    end
end

function schema = menu_StatusMenu( cbinfo )
    schema = DAStudio.ContainerSchema;
    schema.label = xlate('Status Items');
    schema.tag = 'Studio:StatusMenu'; 
    status = cbinfo.studio.getStatusComponents();
    
    schema.userdata = cbinfo.userdata;
    schema.generateFcn = @gen_StatusMenuGenerator;

    % For some reason, disabling containers is not working. They
    % still show enabled and warn when expanded. I am going to
    % place dummy menu items that are disabled in order to remove
    % the warnings.
    if isempty( status )
        schema.state = 'Disabled';
    end
end

function schemas = gen_StatusMenuGenerator( cbinfo )
    status = cbinfo.studio.getStatusComponents();
    schemas = {};
    actions = cbinfo.userdata.actions;
    if isempty( status )
        schemas = { DAStudio.makeCallback( 'No Status Items', actions('DummyWidgetSchema') ) };
    else
        for i = 1:length(status)
            onewidget = status{i};
            schemas = [ schemas { DAStudio.makeCallback( onewidget, actions('StatusWidgetSchema') ) } ];
        end   
    end
end
