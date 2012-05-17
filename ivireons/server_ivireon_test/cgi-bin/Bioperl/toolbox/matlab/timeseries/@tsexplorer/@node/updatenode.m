function [panel,helppanel] = updatenode(this, manager)
% UPDATE Refreshes help panel and may reset the right click menus (which
% can change if the plots have changed)

% Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2010/04/21 21:33:40 $

import java.io.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import javax.swing.text.html.*;
import com.mathworks.mlwidgets.help.*;
import com.mathworks.mlwidgets.html.*;
import java.awt.*;

if isempty( this.Dialog )
  this.Dialog = getDialogSchema(this,manager);
end

%% Set the size
fpos = get(manager.Figure,'Position');
pnlpos = hgconvertunits(ancestor(this.Dialog,'figure'),...
    [manager.DialogPosition 0 fpos(3)-manager.DialogPosition-...
    (manager.HelpDialogPosition+1)*strcmp(manager.HelpShowing,'on') ...
    fpos(4)],'Characters',get(this.Dialog,'Units'),get(this.Dialog,'Parent'));
set(this.Dialog,'Position',pnlpos)

%% Help panel
if isempty(this.HelpDialog)
    this.HelpDialog = localGetHelpPanelCache(manager,class(this));
    if isempty(this.HelpDialog)
        this.HelpDialog = uipanel('Parent',manager.Figure,'Units','Characters');
        % Build a JEditorPane using the html file stored in the HelpFile
        % property. Need to be able to turn this behavior off if there is a
        % memory leak in the HelpBrowser.
        if manager.Root.TsViewer.HelpEnabled
            map_path = fullfile(docroot,'techdoc','time_series_csh','time_series_csh.map');
            helptext = HelpPanel;
            helptext.displayTopic(map_path,this.HelpFile);
            helptext.setDropTarget([]);

            helpPanel = MJPanel(BorderLayout);
            topPanel = MJPanel(BorderLayout);
            headerPanel = MJPanel;
            if ispc
                headerPanel.setBackground(SystemColor.text);
            else
                headerPanel.setBackground(Color.white);
            end
            topPanel.add(headerPanel,BorderLayout.CENTER);
            btnIcon  = ImageIcon(fullfile(matlabroot,'toolbox','matlab','timeseries','smallclosebox.gif'));        
            closeBtn = MJButton(btnIcon);
            closeBtn.setBorder(BorderFactory.createEmptyBorder(5,5,5,5));
            set(handle(closeBtn,'callbackproperties'),'ActionPerformedCallback',...
                @(es,ed) set(manager,'HelpShowing','off'));
            topPanel.add(closeBtn,BorderLayout.EAST);
            helptext.getHTMLRenderer.add(topPanel,BorderLayout.NORTH);
            %helpPanel.add(helptext,BorderLayout.CENTER);
            [jscrollpane,helpcontainer] = javacomponent(helptext,[],manager.Figure);
            % Remove component resizing listener since we are not using normalized
            % units (performance reasons). Exclode MAC g289891
            if ~ismac
                L = get(helpcontainer,'Listeners__');
                for k=1:length(L)
                    if strcmp(L(k).SourceObject.Name,'PixelBounds')
                        L(k).Enable = 'off';
                        break
                    end
                end
            end         
            set(helpcontainer,'parent',this.HelpDialog,'units','normalized',...
                'position',[0 0 1 1]);
        end
        % Temporary listener to update the visibility of a uipanel's children
        helpdlghandle = handle(this.HelpDialog);
%         setappdata(this.HelpDialog,'listener',addlistener(helpdlghandle,...
%             'Visible','PostSet', @(es,ed) localVis(es,ed,helpdlghandle)));
        % Add new panel to help panel cache
        manager.NodeHelpPanelCache = [manager.NodeHelpPanelCache(:); ...
             struct('ClassName',class(this),'Panel',this.HelpDialog)];    
    end          
end


%% Position the help panel on the right of the frame 
helppnlpos = hgconvertunits(ancestor(this.HelpDialog,'figure'),...
    [fpos(3)-manager.HelpDialogPosition 0 manager.HelpDialogPosition fpos(4)],...
    'Characters',get(this.HelpDialog,'Units'),get(this.HelpDialog,'Parent'));
set(this.HelpDialog,'Position',helppnlpos)

%% Return the main panel
panel = this.Dialog;
helppanel = this.HelpDialog;

%% Send a resize event (since invisible panels have been prevented from 
%% responsing to resize events)
resizefcn = get(this.Dialog,'ResizeFcn');
if ~isempty(resizefcn)
   feval(resizefcn{1},handle(this.Dialog),1,resizefcn{2:end});
else
   send(handle(this.Dialog),'ResizeEvent'); % % Note that this line will have to be forked for HG2
end

% function localVis(es,ed,h)
% 
% %% Temporary callback function to toggle the visibility of uipanel children
% c = get(h,'Children');
% for k=1:length(c(:))
%     set(c(k),'Visible',get(h,'Visible'))
% end

function p = localGetHelpPanelCache(manager,thisClassName)

p = [];
for k=1:length(manager.NodeHelpPanelCache)
    if strcmp(manager.NodeHelpPanelCache(k).ClassName,thisClassName)
        p = manager.NodeHelpPanelCache(k).Panel;
        return
    end
end
