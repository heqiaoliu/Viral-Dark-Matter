classdef DomainInterface < DAStudio.AbstractDomainInterface
    methods
        function self = DomainInterface()
            % Setup this domain to use the base studio
            % menubar, toolbars and context classes.
            actions = @DAStudio.Actions;
            submenus = @DAStudio.Submenus;
            menubar = DAStudio.MenuBar( actions, submenus );
            toolbars = DAStudio.ToolBars( actions, submenus );
            context = DAStudio.ContextMenus( actions, submenus );
            self = self@DAStudio.AbstractDomainInterface( menubar, toolbars, context );
        end
    end
end
