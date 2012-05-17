function exploreAction(this)
%  exploreAction
%  This method is invoked when a user double clicks this message in
%  the viewer window's list view. The method executes the open action
%  appropriate to the selected message.
%   
%  Copyright 2008 The MathWorks, Inc.
   
  viewer = DAStudio.DiagViewer.findActiveInstance();
  viewer.openMessage(this);
   
end