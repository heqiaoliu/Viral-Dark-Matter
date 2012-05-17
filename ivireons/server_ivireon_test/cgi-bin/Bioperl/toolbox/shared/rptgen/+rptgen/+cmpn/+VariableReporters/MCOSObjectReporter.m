classdef MCOSObjectReporter < rptgen.cmpn.VariableReporters.StructuredObjectReporter
% MCOSObjectReporter generates a report for a variable whose value is an
% MCOS object.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = MCOSObjectReporter(moOpts, uddReport, ...
      objName, moObj)
      import rptgen.cmpn.VariableReporters.*;
      moReporter@rptgen.cmpn.VariableReporters.StructuredObjectReporter(moOpts, ...
        uddReport, objName, moObj);
    end
    
    
    function propNames = getObjectProperties(moReporter)
      % Get names of all public object properties
      metaclassObj = metaclass(moReporter.VarValue);
      props = metaclassObj.Properties;
      props = props(cellfun(@(prop) strcmp(prop.GetAccess, 'public'), props));
      if isa(moReporter.VarValue, 'meta.property')
        if ~moReporter.VarValue.HasDefault
          props = props(cellfun(@(prop) ~strcmp(prop.Name, 'DefaultValue'), props));
        end
      end
      propNames = moReporter.getObjectPropNames(props);     
    end
  
    function isFiltered = isFilteredProperty(moReporter, object, property)
      
      if strcmp(property.GetAccess, 'public')
        value = object.(property.Name);
        isFiltered = false;
      else
        isFiltered = true;
      end
      
      
      if ~isFiltered
        
        isFiltered = moReporter.moOpts.IgnoreIfDefault && ...
          property.HasDefault && isequal(value, property.DefaultValue);
        
        % Empty
        if ~isFiltered
          isFiltered = moReporter.moOpts.IgnoreIfEmpty && isempty(value);
        end
        
%         if ~isFiltered
%           % Auto
%           isFiltered = moReporter.moOpts.IsFilterAuto && ischar(value) && strcmpi(value, 'auto');
%         end
      end
    end

    
  end % of dynamic methods
  
end

