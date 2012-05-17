function editCallbacks(this, evt, varargin)
%EDITCALLBACKS
%   Called from Java or from MATLAB.
%
%   Not to be used directly.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.8.2.1 $  $Date: 2010/06/24 19:45:22 $  $Author: batserve $

% callbacks can be called from MATLAB or Java
matlabCallback = ~(ischar(this) && (strcmpi(this, 'JavaCallback')));


%;!! we are setting 'modified' property without waiting whether the scene was really
%;!! changed or not; in case when the scene was not really modified
%;!! (and property was set to true), discrepancy between
%;!! property value and real scene state arises

if ~matlabCallback
  wid = varargin{1};
  method = varargin{2};
  list = getappdata(0, 'SL3D_edit_List');
  if ~list.isKey(wid) 
    % no editor available  
    return;
  end
  obj = list(wid);
  
  % helper methods do not modify scene
  if isempty(evt) || (ischar(evt) && ~strcmp(evt, 'helper'))
    set(obj, 'modified',  true);  
  end
else
  obj = varargin{1};
  method = varargin{2};
  
  % MATLAB callback always modifies scene
  set(obj, 'modified',  true);  
end

switch method
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%% methods for scene modification and manipulation %%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
  case 'setField'
    setField(obj, varargin{3}, varargin{4}, char(varargin{5}));
        
  case 'setMFStringField'
    setMFStringField(obj, varargin{3}, varargin{4});
        
  case 'renameNode'
    renameNode(obj, varargin{3}, char(varargin{4}));
        
  case 'addNode'
    try
      jitem = getSelectedJItem(obj, 'parentField');
    catch ME
      h = errordlg(ME.message, 'Add Error', 'modal');
      uiwait(h);
      return;          
    end   
      
    % expect Root node selected
    nodename = char(jitem.getName);
    fieldname = 'children';
    if ~jitem.getClass().getName().equals('com.mathworks.toolbox.sl3d.editor.tree.item.TreeItemRoot')
      % it is SFNode/MFNode field
      fieldname = nodename;
      nodename = char(jitem.getParent.getName);          
    end 
    addNode(obj, fieldname, nodename, char(varargin{3}), char(varargin{4}));
        
  case 'addUsedNode'
    try  
      jitem = getSelectedJItem(obj, 'parentField');  
    catch ME
      h = errordlg(ME.message, 'Using Node Error', 'modal');    
      uiwait(h);
      return;            
    end
      
    if nargin==4
      addUsedNode(obj, jitem);
    else
      addUsedNode(obj, jitem, varargin{3});
    end
  
  case 'addEmptyRoute'
    addEmptyRoute(obj);     
    
  case 'deleteRoute'
    try  
      jroute = getSelectedJItem(obj, 'route');  
    catch ME
      h = errordlg(ME.message, 'Deletion Error', 'modal');    
      uiwait(h);
      return;            
    end        
      
    deleteRoute(obj, jroute);
        
  case 'setRoute'
    setRoute(obj, varargin{3}, varargin{4});
        
  case 'setComment'
    item = varargin{3};
    newcomment = varargin{4};
    if ~strcmp(newcomment, obj.getItemComment(item))
      setComment(obj, item, newcomment);
    end
        
  case 'gotoViewpoint'
    vrsfunc('SetCanvasProperty', uint64(obj.jcanvas.getPointerToNativeCanvas()), 'Viewpoint', char(varargin{3}));
  
  case 'insertComponent'
    insertComponent(obj, false);  
    
  case 'insertMaterial'
    insertMaterial(obj, false);
        
  case 'insertTexture'
    insertTexture(obj, false);
    
  case 'insertFromOtherLocation'  
    insertFromOtherLocation(obj);
      
  case 'inlineFile'
    inlineFile(obj);
    
  case 'pasteChild' 
    if varargin{3}
      vr.editCallbacks([],[],obj, 'addUsedNode');
    else
      vr.editCallbacks([],[],obj, 'addNode', [], 'copy');  
    end
      
  case 'cutNode'
    try  
      jnode = getSelectedJItem(obj, 'node');  
    catch ME
      h = errordlg(ME.message, 'Cut Error', 'modal');    
      uiwait(h);
      return;            
    end
    cutNode(obj, jnode);
      
  case 'copyNode'    
    try  
      jnode = getSelectedJItem(obj, 'node');  
    catch ME
      h = errordlg(ME.message, 'Copy Error', 'modal');    
      uiwait(h);
      return;            
    end
    copyNode(obj, jnode);
      
  case 'deleteNode'
    try  
      jnode = getSelectedJItem(obj, 'node');  
    catch ME
      h = errordlg(ME.message, 'Deletion Error', 'modal');    
      uiwait(h);
      return;            
    end   
    
    if deleteNode(obj, jnode, true, false)
      refreshGUI(obj, false);    
    end
    
  case 'deleteChildNode'
    try
      jfield = getSelectedJItem(obj, 'singleChildParentField');
      jnode = javaMethodEDT('getFirstChild', jfield);
    catch ME
      h = errordlg(ME.message,'Deletion Error', 'modal');
      uiwait(h);
      return;          
    end
    
    if ~isempty(jnode)
      deleteNode(obj, jnode, true, false);
      refreshGUI(obj, false);         
    end
      
  case 'deleteAllNodes'
    try
      jfield = getSelectedJItem(obj, 'multiChildrenParentField');
    catch ME
      h = errordlg(ME.message,'Deletion Error', 'modal');
      uiwait(h);
      return;          
    end    
    deleteAllNodes(obj, jfield);
  
    case 'deleteNodeOrRoute'  
      try
        jdeletable = getSelectedJItem(obj, 'deletable');
      catch ME
        h = errordlg(ME.message,'Deletion Error', 'modal');
        uiwait(h);
        return;          
      end
      
      if jdeletable.getClass().getName().equals('com.mathworks.toolbox.sl3d.editor.tree.item.TreeItemRoute')
        deleteRoute(obj, jdeletable);  
      else
        deleteNode(obj, jdeletable, true, false);
        refreshGUI(obj, false);            
      end

        
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%% helper methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
  case 'showItemEditPane'
    item = varargin{3};
    comment = obj.getItemComment(item);
    classname = item.getClass().getName();
        
    if classname.equals('com.mathworks.toolbox.sl3d.editor.tree.item.TreeItemRoute')
      % called directly in java callback mode -- we consider these callbacks as java callbacks  
      vr.editCallbacks('JavaCallback', 'helper', varargin{1}, 'loadEventFields', item, item.getFromNode, true);
      vr.editCallbacks('JavaCallback', 'helper', varargin{1}, 'loadEventFields', item, item.getToNode, false);
    end
        
    pane = com.mathworks.toolbox.sl3d.editor.edit.TreeItemEditPane(item, comment);
    obj.jeditpanecontainer.removeAll();
    obj.jeditpanecontainer.add(pane, java.awt.BorderLayout.CENTER);
    pane.revalidate();
        
  case 'loadEventFields'
    item = varargin{3};
    nodeName = char(varargin{4});
    fromNodeFlag = logical(varargin{5});
        
    if isempty(nodeName)
      % no events can be loaded
      Events = javaArray('java.lang.String', 1);
      Events(1) = java.lang.String;
    else
      % load events
      result = vrsfunc('GetEventFieldsForNodeType', get(obj.world, 'Id'), nodeName, ~fromNodeFlag);
      [~, count] = size(result);
      Events = javaArray('java.lang.String', count);
      for i=1:count
        Events(i) = java.lang.String([result{1,i}, ' (',result{2,i}, ')']);
      end
    end
        
    if fromNodeFlag
      item.setComboBoxEventOuts(Events);
    else
      item.setComboBoxEventIns(Events);
    end
  
  case 'showClipboardErrorDlg'
    caption = 'Paste Operation Error';  
    message = 'The data on the clipboard cannot be pasted.';
    if strcmp(varargin{3}, 'append')
      caption = 'Append Operation Error';    
      message = 'The data on the clipboard cannot be appended.';
    end
    h = errordlg(message , caption, 'modal'); 
    uiwait(h);
end

% update toolbar after each callback
updateUIToolbar(obj, getSelectedJItem(obj, 'whatever'));

end
      
 
