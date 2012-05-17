function removePopup(this)

% Copyright 2005 The MathWorks, Inc.

%% Deletes the popup menu after remowing all the callbacks. Needed to avoid
%% memory leaks.
if ~isempty(this.PopupMenu)
    subMenus = this.PopupMenu.getComponents;
    for j=1:length(subMenus)
        if isa(subMenus(j),'com.mathworks.mwswing.MJMenuItem')
           cb = handle(subMenus(j),'callbackproperties');
           set(cb,'ActionPerformedCallback',[])
        elseif isa(subMenus(j),'com.mathworks.mwswing.MJMenu')
           localSubMenus = subMenus(j).getMenuComponents;
           for r=1:length(localSubMenus)
               if isa(localSubMenus(r),'com.mathworks.mwswing.MJMenuItem')
                   cb = handle(localSubMenus(r),'callbackproperties');
                   set(cb,'ActionPerformedCallback',[])
               end
           end
        end
    end
end