function msgObject = convertNagToUDDObject(h, nag) %#ok<INUSL>
%  CONVERTNAGTOUDDOBJECT
%
%  Converts a nag to a UDD object of DAStudio.DiagMsg class. A nag is
%  a message structure created by the Simulink/Stateflow nag controller
%  (slsfnagctlr.m).
%
%  Copyright 1990-2008 The MathWorks, Inc.
  
 msgObject = DAStudio.DiagMsg;
 
 msgObject.type = nag.type;
 
 msgObject.SourceFullName = nag.sourceFullName;
 % Remove line feeds (char code = 10)
 msgObject.SourceFullName(msgObject.SourceFullName==10) = [];
 
 msgObject.SourceName = nag.sourceName;
 msgObject.SourceName(msgObject.SourceName==10) = [];


 msgObject.Component = nag.component;
 msgObject.Component(msgObject.Component==10) = [];
 
 for i = 1:length(nag.objHandles)
   objHandle = nag.objHandles(i);
   msgObject.AssocObjectHandles = [msgObject.AssocObjectHandles, objHandle];
   name = get_param(objHandle,'Name');
   msgObject.AssocObjectNames = [msgObject.AssocObjectNames; {name}];
 end
 
 if (~isempty(nag.sourceHId))
     objHandle = nag.sourceHId;
     msgObject.SourceObject = [msgObject.SourceObject, objHandle];
 end
 
 % copy the open function if there is one
 if (~isempty(nag.openFcn))
    msgObject.OpenFcn = nag.openFcn; 
 end
 
 c = DAStudio.DiagMsgContents;
 
 c.Type = nag.msg.type;
 c.Type(c.type==10) = [];
 
 c.Summary = nag.msg.summary;
 c.Summary(c.Summary==10) = [];
 
 % Fix for G418710:
 % Hide hyperlink start and end tags in summary line.
 % Note that the order of the next two statements is significant.
 % Note also that this needs to happen prior to truncating the message
 c.Summary = regexprep(c.Summary, '</a>', ''); % Hide end tag
 c.Summary = regexprep(c.Summary, '<a.*?".*?">', ''); % Hide start tag
 
 % Fix for g522269: truncate summary so it won't produce
 % a humongous tooltip.
 maxNumCharsInSummary = 101;
 if length(c.Summary) > maxNumCharsInSummary
    c.Summary = [c.Summary(1:maxNumCharsInSummary) ' ...'];
 end
 
 % Workaround for the fact that the Model Explorer displays a null string
 % property value as '[ ]' in the list view.
 if strcmp(c.Summary, '')
   c.Summary = ' ';
 end
 
 c.Details = nag.msg.details;
  
 msgObject.Summary = c.summary;
 msgObject.HyperRefDir = nag.refDir;
 msgObject.Contents = c;
 msgObject.DispType = [c.type ' ' msgObject.type];
 
end
