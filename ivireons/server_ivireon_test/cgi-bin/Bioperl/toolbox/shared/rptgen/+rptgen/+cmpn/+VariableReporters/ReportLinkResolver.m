classdef ReportLinkResolver < handle
% ReportLinkResolver returns a link to a report for an object if the report
% already exists.

% Copyright 2010 The MathWorks, Inc.

  properties
    
     LinkMap = {}
    
  end
 
  methods
    
    function putLink(moResolver, obj, moReport)
      import rptgen.cmpn.VariableReporters.*;
      if ReportLinkResolver.isValidObject(obj) 
        if isempty(moReport.ReportTitle)
          reportTitle = class(moReport.VarValue);
        else
          reportTitle = moReport.ReportTitle;
        end
        moResolver.LinkMap{end+1} = {obj ...
          moReport.makeLink(moReport.ReportId, reportTitle)};
      end
    end
    
    function joLink = getLink(moResolver, obj)
      import rptgen.cmpn.VariableReporters.*;
      
      joLink = [];
      
      if ReportLinkResolver.isValidObject(obj)       
        type = class(obj);
        if ~strcmp(type(1:5), 'meta.') || isa(obj, 'meta.class')
          try
            assoc = moResolver.LinkMap(cellfun(@(assoc) eq(assoc{1}, obj), ...
              moResolver.LinkMap));
          catch  %#ok<CTCH>
            % This try catch statement is intended to handle the case where
            % an MCOS value object does not define an eq method. The handle class
            % defines an eq method for all handle classes. It should be safe
            % to assume that value classes are not equal, i.e., value classes
            % should not lead to infinite loops.
            assoc = [];
          end
          if ~isempty(assoc)
            joLink = assoc{1}{2};
            joLink = joLink.cloneNode(true);
          end
        end
      end
    end
    
    function clear(moResolver)
      moResolver.LinkMap = {};
    end
    
    
  end % of dynamic methods
  
  methods (Static)
    
    function moResolver = getTheResolver()
      
      import rptgen.cmpn.VariableReporters.*;
      
      persistent moTheResolver
      
      if isempty(moTheResolver)
        moTheResolver = ReportLinkResolver;      
      end
      
      moResolver = moTheResolver;
      
    end
    
    function tf = isValidObject(obj)
      tf = false;
      if ~isempty(obj)
        if length(obj) > 1
          if isobject(obj(1)) || ishandle(obj(1))
            tf = true;
          end
        else
          if isobject(obj) || ishandle(obj)
            tf = true;
          end
        end
      end
    end
    
  end
  
end

