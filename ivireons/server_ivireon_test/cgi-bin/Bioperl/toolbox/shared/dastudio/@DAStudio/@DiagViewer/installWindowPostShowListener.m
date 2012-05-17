function installWindowPostShowListener(h)
%  installWindowPostShowListener
%  Installs a listener for diagnostic viewer window (i.e., Explorer) post
%  show events.

%  Copyright 2008 The MathWorks, Inc.
  

h.hPostShowListener = handle.listener(h.Explorer, 'MEPostShow', ...
  {@postShowHandler, h});

end

function postShowHandler(hExplorer, e, viewer)
  
  % If the Explorer is being shown for the first time with a new batch
  % of messages, select the first in the batch. Skip selection if
  % the Explorer is being shown after being minimized by the user to
  % ensure that any message selected by the user remains selected.
  if isempty(viewer.Messages)
    if isempty(viewer.selectedMsg)
      viewer.selectDiagnosticMsg(viewer.NullMessage);
    end    
  else
    if isempty(viewer.selectedMsg)
      viewer.selectDiagnosticMsg(viewer.Messages(1));
    end    
  end
  
  % Check whether the DV's title bar is on screen and if not move it on
  % screen. This ensures that the DV will never become inaccessible.
  % Treat the DV as on screen if its upper left or its upper right corner
  % is on screen.
  screen = get(0, 'screensize');
  pos = hExplorer.position;
  
  % pos(1) -- x-coord of upper left corner
  % pos(2) -- y-coord of upper left corner
  % pos(3) -- width
  % pos(4) -- height
  xlc_dv = pos(1) + 10;
  ylc_dv = pos(2) + 10;
  xrc_dv = pos(1) + pos(3) - 10;
  yrc_dv = ylc_dv;
  
  xlc_onscreen = (xlc_dv > screen(1)) && (xlc_dv < screen(1) + screen(3));
  ylc_onscreen = (ylc_dv > screen(2)) && (ylc_dv < screen(2) + screen(4));
  xrc_onscreen = (xrc_dv > screen(2)) && (xrc_dv < screen(1) + screen(3));
  yrc_onscreen = (yrc_dv > screen(2)) && (yrc_dv < screen(2) + screen(4));
  lc_onscreen = xlc_onscreen && ylc_onscreen;
  rc_onscreen = xrc_onscreen && yrc_onscreen;
  onscreen = lc_onscreen || rc_onscreen;
    
  if ~onscreen
    if xlc_dv < screen(1) 
      % Upper left corner of the DV is left of the screen. Move the
      % corner just on screen.
      pos(1) = screen(1); 
    else
      if xlc_dv > screen(1) + screen(3) 
        % Upper left corner is to the right of the screen. Move the
        % corner to the left so that the whole width of the DV is on
        % screen.
        pos(1) = screen(1) + screen(3) - pos(3); 
      end                                         
    end
    
    if ylc_dv < screen(2)
      % Upper left corner is above the screen. Move the corner down to
      % where it is just on screen.
      pos(2) = screen(2);
    else
      if ylc_dv > screen(2) + screen(4)
        % Upper left corner is below the screen. Move the corner up until
        % the entire height of the DV is on screen.
        pos(2) = screen(2) + screen(4) - pos(4);
      end
    end
    hExplorer.position = pos;
  end
  
  % Set the list view height the first time the DV is displayed.
  % The user can then change the height without having it reset
  % by the DV.
  imme = DAStudio.imExplorer(hExplorer);
  if ~viewer.msgListViewHeightInitialized
    imme.setListViewWidth(round(pos(4)/3));
    viewer.msgListViewHeightInitialized = true;
  end
  

  
end
