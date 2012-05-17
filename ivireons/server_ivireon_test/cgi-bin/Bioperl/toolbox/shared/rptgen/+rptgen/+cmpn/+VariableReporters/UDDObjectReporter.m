classdef UDDObjectReporter < rptgen.cmpn.VariableReporters.StructuredObjectReporter
% UDDObjectReporter generates a report for a variable whose value is a
% UDD object.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = UDDObjectReporter(moOpts, uddReport, ...
      objName, uddObj)
      import rptgen.cmpn.VariableReporters.*;
      moReporter@rptgen.cmpn.VariableReporters.StructuredObjectReporter(moOpts, ...
        uddReport, objName, uddObj);
    end
    

    
    function propNames = getObjectProperties(moReporter)      
      propNames = {};     
      if ~isa(moReporter.VarValue, 'handle.listener')
        % Get names of all visible object properties
        metaclassObj = classhandle(moReporter.VarValue);
        if ~isempty(metaclassObj.Properties)
          propSchemas = find(metaclassObj.Properties,'Visible','on');
          nProps = length(propSchemas);
          props = cell(nProps, 1);
          for i = 1:nProps
            props{i} = propSchemas(i);
          end
          propNames = getObjectPropNames(moReporter, props);
        end
      end
    end

    function fields = getStructFields(struct)
      fields = fieldnames(struct);
    end

  
    function isFiltered = isFilteredProperty(moReporter, object, property)
      
      % Filter out private properties.
      access = property.Access;
      if strcmp(access.PublicGet, 'on')
        name = property.Name;
        try
          value = object.(name);
          isFiltered = false;
        catch %#ok<CTCH>
          isFiltered = true;
        end
      else
        isFiltered = true;
      end
            
      if ~isFiltered
        
        isFiltered = moReporter.moOpts.IgnoreIfDefault && ...
          strcmp(access.PublicGet, 'on') && ...
          isequal(value, property.FactoryValue);
        
        if ~isFiltered
          % Empty
          isFiltered = moReporter.moOpts.IgnoreIfEmpty && ...
          isempty(value);
        end       
      end
    end
  

    
  end % of dynamic methods
  
end

