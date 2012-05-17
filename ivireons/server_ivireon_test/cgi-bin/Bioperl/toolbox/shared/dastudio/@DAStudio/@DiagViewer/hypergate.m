function hypergate(h)
%  HYPERGATE 
%  
%  Determines the type of object (Simulink or Stateflow) targeted by a 
%  message hyperlink and the executes the hyperlink.
%
%  Copyright 1990-2008 The MathWorks, Inc.
       
msg = h.getSelectedMsg;
link = msg.SourceFullName;
linkType = ml_type_l(msg.SourceObject(1));

% Convert numeric Stateflow object handles (ids) to strings
% for hyperlink method.
if isequal(linkType, 'id')
   link = num2str(msg.SourceObject(1));
end

h.hyperlink(linkType, link);

% Determines whether the target of the hyperlink is a model object specified
% by a path string or a Stateflow chart object specified by a numeric handle.
function theType = ml_type_l(obj)
  
if ~isempty(obj) && isnumeric(obj) && obj==fix(obj) && sf('ishandle', obj)
  theType = 'id';
else
  theType = 'mdl';
end