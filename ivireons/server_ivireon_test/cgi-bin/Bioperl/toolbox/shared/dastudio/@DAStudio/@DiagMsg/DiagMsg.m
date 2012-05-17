function h = DiagMsg(varargin)
% Class constructor function (for das.DiagMsg)
%  Copyright 2008 The MathWorks, Inc. 
  
  % Instantiate object
  h = DAStudio.DiagMsg;
  h.enableOpenButton = true;

  % Attach Message object to Nag class
  h.Contents = DAStudio.DiagMsgContents;
  h.Contents.HyperSearched = 0;
  
end
