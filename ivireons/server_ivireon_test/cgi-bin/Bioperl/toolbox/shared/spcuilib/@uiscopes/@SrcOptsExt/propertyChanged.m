function propertyChanged(this, eventData)
%PROPERTYCHANGED property change event handler

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/14 04:07:46 $

if ischar(eventData)
    name  = eventData;
    value = this.findProp(name).Value;
else
    hProp = get(eventData, 'AffectedObject');
    value = get(hProp, 'Value');
    name  = get(hProp, 'Name');
end

hApp = get(this, 'Application');

switch name
    case 'RecentSourcesListLength'
        groupname = appName2VarName(this.Application);
        groupname = [groupname, 'Preferences'];
        setpref(groupname, name, value);
        this.RecentSources.setMax(value);
    case 'ShowRecentSources'
        
        hUI = getGUI(hApp);

        if value
            if ~isempty(this.RecentSourcesMenu)

                % Add the RecentSources back.
                placement = this.RecentSourcesMenu.Placement;
                hParent = hUI.findchild('Menus', 'File');
                hParent.add(this.RecentSourcesMenu);
                this.RecentSourcesMenu.Placement = placement;

                if hParent.isRendered
                    render(hParent);
                end
                this.RecentSourcesMenu = [];
            end
        else

            % Remove the RecentSources widget from UIMgr, but save it in a
            % private property so we can add it back if necessary.
            this.RecentSourcesMenu = hUI.findchild('Menus','File','RecentSourceItems');
            remove(this.RecentSourcesMenu);
        end
end

% [EOF]
