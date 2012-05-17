function editmenufcn(hfig, cmd)
%EDITMENUFCN Implements part of the figure edit menu.
%  EDITMENUFCN(CMD) invokes edit menu command CMD on figure GCBF.
%  EDITMENUFCN(H, CMD) invokes edit menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    EditUndo
%    EditCut
%    EditCopy
%    EditPaste
%    EditClear
%    EditDelete
%    EditSelectAll
%    EditPinning
%    EditCopyOptions
%    EditCopyFigure
%    EditFigureProperties
%    EditAxesProperties
%    EditObjectProperties
%    EditColormap

%    EditPost - internal use only

%  Copyright 1984-2005 The MathWorks, Inc.
%  $Revision: 1.7.4.22 $

error(nargchk(1,2,nargin))

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'EditPost'
        localPost(hfig);
    case 'EditUndo'
        uimenufcn(hfig, 'EditUndo');
    case 'EditCut'
        plotedit(hfig,'Cut');
    case 'EditCopy'
        if isactiveuimode(hfig,'Standard.EditPlot')
            plotedit(hfig,'Copy');
        elseif isactiveuimode(hfig,'Exploration.Brushing')
            if datamanager.isFigureLinked(hfig)
                com.mathworks.page.datamgr.linkedplots.LinkPlotPanel.fireFigureCallback(...
                    java(handle(hfig)),'datamanager.copySelection',{[]});
            else
                datamanager.copySelection(hfig,[]);
            end
        end 
    case 'EditPaste'
        plotedit(hfig,'Paste');
    case 'EditClear'
        plotedit(hfig,'Clear');
    case 'EditDelete'
        plotedit(hfig,'Delete');
    case 'EditSelectAll'
        plotedit(hfig,'SelectAll');
    case 'EditCopyOptions'
        preferences(xlate('Figure Copy Template.Copy Options'))
    case 'EditCopyFigure'
        if (ismac && (usejava('awt') == 1))
            % get the figure bits into an image
            % To Do - use hardcopy or print instead
            data = getframe(hfig);
            cda = data.cdata;
            % put the image onto the clipboard
            im = im2java(cda);
            jm = javax.swing.ImageIcon(im);
            im_obj = jm.getImage;
            cb = java.awt.Toolkit.getDefaultToolkit.getSystemClipboard;
            cb.setContents(com.mathworks.hg.util.ImageSelection(im_obj),[]);
            %disp('tried to copy to clipboard')
        else
            uimenufcn(hfig, 'EditCopyFigure')
        end
    case 'EditFigureProperties'
        % domymenu menubar figureprop
        propedit(hfig);
    case 'EditAxesProperties'
        % domymenu menubar axesprop
        ax = get(hfig,'currentaxes');
        if ~isempty(ax)
           propedit(ax);
        end
    case 'EditObjectProperties'
        obj = get(hfig,'CurrentObject');
        if isempty(obj) || ~ishghandle(obj)
            % use scribe current object if one exists and if scribe is on
            if strcmpi(getappdata(hfig,'scribeActive'),'on')
                scribeax = handle(findall(hfig,'Tag','scribeOverlay'));
                if ~isempty(scribeax) && ~isempty(scribeax.CurrentShape)
                    obj = double(scribeax.CurrentShape);
                end
            end
            % if still empty use figure
            if isempty(obj) || ~ishghandle(obj)
                obj = hfig;
            end
        end
        if ishghandle(obj,'figure') || ~isappdata(obj,'ScribeGroup')
            propedit(obj);
        elseif isappdata(obj,'ScribeGroup')
            scribeobj = getappdata(obj,'ScribeGroup');
            propedit(scribeobj);
        end
    case 'EditColormap'
        colormapeditor(hfig);        
    case 'EditFindFiles'
        com.mathworks.mde.find.FindFiles.invoke;
    case 'EditClearFigure'
        clf(hfig);
    case 'EditClearCommandWindow'
        clc;
    case 'EditClearCommandHistory'
        localEditClearCommandHistory(hfig);     
    case 'EditClearWorkspace'
        localEditClearWorkspace(hfig);    
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];

% store the last warning thrown
[ lastWarnMsg lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jpeer = get(hfig,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);

if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

%--------------------------------------------------------%
function localEditClearWorkspace(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localEditClearCommandHistory(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getClearHistoryAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

%--------------------------------------------------------%
function localPost(hfig)

% The first time the EditPost callback is called, hide any
% non-functional items on Unix.
% Also, if necessary, enable or disable any items on the editmenu
% based on their context.
        
edit = findall(allchild(hfig),'type','uimenu','Tag','figMenuEdit');

if ~ispc
     % We want to show the Copy Figure menu only if java figures is on by
     % default on the Mac.
    if (ismac && (usejava('awt') == 1))
        set(findall(edit,'label','Copy &Figure'),'visible','on');
    else
        set(findall(edit,'label','Copy &Figure'),'visible','off');
    end

    set(findall(edit,'label','Copy &Options...'),'visible','off');
    set(findall(edit,'label','Cu&t'),'separator','off');
    % hide non-functional unix items
end
        
if ~usejava('mwt')
    %There are no r11 property editors for figure and most axes children,
    %so disable the figure and current object edit options on the figure
    %menu
    set(findall(edit,'tag','figMenuEditGCA'),'separator','on');
    set(findall(edit,'tag','figMenuEditGCO'),'visible','off');
end
        
% Hide callbacks that require a java frame
if usejava('awt') ~= 1
    set(findall(edit,'tag','figMenuEditClearCmdWindow'),'visible','off');
    set(findall(edit,'tag','figMenuEditClearCmdHistory'),'visible','off');      
    set(findall(edit,'tag','figMenuEditClearWorkspace'),'visible','off');   
end

plotedit({'update_edit_menu',hfig,false}); 

% Customize the enabled state of the Copy and Delete menus in Data Brushing
% mode
if isactiveuimode(hfig,'Exploration.Brushing')
    datamanager.postEdit(hfig);
end
        
drawnow;


