function sa = getSelectedAnnotations(system)
% GETSELECTEDANNOTATIONS Returns all selected annotations in the given system
%
% getSelectedAnnotations('model')
% getSelectedAnnotations('model/subsystem')
% getSelectedAnnotations(myModelHandle)
% getSelectedAnnotations(mySubsysHandle)
%   All of these forms return a list of Simulink Annotations that are 
%   currently selected in the given model or subsystem.  
%   It may return 0, 1, or more objects.
%
% getSelectedAnnotation(myStateflowChart)
%   Returns a list of all the Stateflow Notes that are currently selected in 
%   the given Stateflow Chart

% Copyright 2005 The MathWorks, Inc.
  
  try
    if (length(system) == 1 && ishandle(system) && ~isnumeric(system))
      obj = system;
    else
      obj = get_param(system, 'Object');
    end
  
    pkgname = get(get(classhandle(obj), 'Package'), 'Name');
    if (isequal(pkgname, 'Simulink'))
      sa = find(obj, '-depth', 1, '-isa', 'Simulink.Annotation', 'Selected', 'on');
    elseif (isequal(pkgname, 'Stateflow'))
      allSelected = obj.Editor.selectedObjects;
      sa = find(allSelected, '-depth', 0, '-isa', 'Stateflow.Note');
    else 
      error ('Simulink:BadAnnotationParent', 'Parameter must be a model, subsystem, or chart');
    end
  catch
    error ('Simulink:BadAnnotationParent', 'Parameter must be a model, subsystem, or chart');
  end
  
  
  