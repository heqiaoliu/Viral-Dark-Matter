function msg = createNullMsg(h)
% createNullMsg
%
% Creates an instance of a null message. A null message is
% a message that is displayed in the DV window when there are
% no actual messages to displayed.
%
%  Copyright 2008 The MathWorks, Inc. 

 msg = DAStudio.DiagMsg;
 msg.Type = ' ';
 msg.SourceFullName = ' ';
 msg.SourceName = ' ';
 msg.Component = ' ';
 msg.enableOpenButton = false;
 
 c = DAStudio.DiagMsgContents;
 c.Type = msg.Type;
 c.Summary = ' ';
 c.Details = ' ';
 
 msg.Summary = c.Summary;
 msg.Contents = c;
 msg.DispType = ' ';
 
 h.NullMessage = msg;
 
 
end