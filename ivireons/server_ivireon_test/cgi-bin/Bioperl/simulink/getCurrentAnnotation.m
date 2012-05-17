function ca = getCurrentAnnotation()
% GETCURRENTANNOTATION
%
%  If an annotation's callback is executing, this function 
%  returns that annotation.
%  If not, it will return the last annotation clicked.
%  It will return nothing if no annotation has been clicked, or
%  if the previously-clicked object has been deleted.
%  This function returns Simulink Annotations or Stateflow Notes.

% Copyright 2005 The MathWorks, Inc.
  
  cba = getCallbackAnnotation;
  if (~isempty(cba))
    ca = cba;
  else
    ca = last_clicked_annotation;
    if (~isempty(ca) && isempty(ca.getParent)) 
      % Don't return objects not in a system (eg on undo stack)
      ca = [];
    end
  end
  
  if (~isa(ca, 'Simulink.Annotation') && ~isa(ca, 'Stateflow.Note'))
    ca = [];
  end
  
  