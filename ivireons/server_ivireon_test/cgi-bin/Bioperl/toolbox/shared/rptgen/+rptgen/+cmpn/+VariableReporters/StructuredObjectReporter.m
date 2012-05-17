classdef StructuredObjectReporter < ...
    rptgen.cmpn.VariableReporters.VariableReporter & ...
    rptgen.cmpn.VariableReporters.HierarchicalObjectReporter
% StructureObjectReporter is the base class for reporters that report
% on structure-like objects, e.g., struct, MCOS, or UDD objects.

% Copyright 2010 The MathWorks, Inc.

  
  methods
    
    function moReporter = StructuredObjectReporter(moOpts, uddReport, ...
      varName, varValue)
      moReporter@rptgen.cmpn.VariableReporters.VariableReporter(moOpts, ...
        uddReport, varName, varValue);
    end
    
    function joVarReport = makeAutoReport(moReporter)
      joVarReport = moReporter.makeTabularReport();
    end
    
    function joVarReport = makeTabularReport(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      
      % Get all specified properties
      props = moReporter.getObjectProperties();
      numProps = length(props);
      
      % Initialize cell array to hold object report table
      caTable = cell(numProps,2);
            
      % Go through all properties
      for i = 1:numProps
        propName = props{i};
        propValue = moReporter.VarValue.(propName);
        
        caTable{i,1} = propName;
        if isempty(propValue)
          caTable{i,2} = '';
        else
          titleSuffix = ['.' propName];
          if isempty(moReporter.ReportTitle)
            propReportTitleBase = class(moReporter.VarValue);
          else
            propReportTitleBase = moReporter.ReportTitle;
          end
          propReportTitle = [propReportTitleBase titleSuffix];
          linkResolver = ReportLinkResolver.getTheResolver();
          forwardLink = linkResolver.getLink(propValue);
          if isempty(forwardLink)
            moOpts = moReporter.moOpts;
            moOpts.TitleMode = 'auto';
            moPropReporter = ReporterFactory.makeReporter(moOpts, ...
              moReporter.uddReport, propReportTitle, propValue);
            if isa(moPropReporter, ...
                'rptgen.cmpn.VariableReporters.HierarchicalObjectReporter') && ...
                moReporter.ReportLevel < moReporter.moOpts.DepthLimit
              forwardLink = moReporter.makeLink(moPropReporter.ReportId, ...
               propReportTitle);
              caTable{i, 2} = forwardLink;
              moReporter.makeBackLink(moPropReporter, titleSuffix);
              moPropReporter.ReportLevel = moPropReporter.ReportLevel + 1;
              ReporterQueue.getTheQueue().add(moPropReporter);                    
            else
              moPropReporter.moOpts.TitleMode = 'none';
              caTable{i, 2} = moPropReporter.makeTextReport();
            end
          else
            caTable{i, 2} = forwardLink;
          end
        end
        
      end
           
      if ~isempty(caTable)
        caTable = moReporter.addTableHeads(caTable);
        joVarReport = moReporter.makeValueTable(caTable);
      else
        joVarReport = moReporter.makeProplessObjDescr();
      end
      


      
    end
    

    function joVarReport = makeProplessObjDescr(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      joVarReport = moReporter.uddReport.createDocumentFragment();
      joAnchor = moReporter.makeAnchor(moReporter.ReportId, '');
      joVarReport.appendChild(joAnchor);
      
      joEmphasis = moReporter.uddReport.createElement('emphasis');
      joEmphasis.setAttribute('role', 'bold');
      joEmphasis.setAttribute('xml:space', 'preserve');
      joEmphasis.appendChild(moReporter.uddReport.createTextNode( ...
        [moReporter.ReportTitle ' (' class(moReporter.VarValue) ', ']));
      joEmphasis.appendChild(moReporter.uddReport.createTextNode(')'));
      joPara = moReporter.uddReport.createElement('para', joEmphasis);
      joVarReport.appendChild(joPara);
      joPara = moReporter.uddReport.createElement('para');
      joPara.appendChild(moReporter.uddReport.createTextNode(msg('ProplessObj')));
      joVarReport.appendChild(joPara);
    end
    
    function propHead = getPropHead(moReporter) %#ok<MANU>
      import rptgen.cmpn.VariableReporters.*;
      propHead = msg('ObjTblPropColHd');
    end
    
    function joHead = makeHead(moReporter, head)
      joHead = moReporter.uddReport.createElement('emphasis', head);
      joHead.setAttribute('role', 'bold');
      joHead.setAttribute('xml:space', 'preserve');
    end
    
    
    function caTable = addTableHeads(moReporter, caPropTable)
      import rptgen.cmpn.VariableReporters.*;
      sz = size(caPropTable);
      caTable = cell(sz(1)+1, 2);
      caTable(1,:) = {moReporter.makeHead(moReporter.getPropHead()) ...
        moReporter.makeHead(msg('ObjTblValColHd'))};
      caTable(2:end,:) = caPropTable;
    end


    function propNames = getObjectPropNames(moReporter, props)

      numberOfProperties = length(props);

      % Initialize index filter to show user specified properties
      filtered = false(1,numberOfProperties);

      % Go through each property
      for i = 1:numberOfProperties
        tf = moReporter.isFilteredProperty(moReporter.VarValue, props{i});
        filtered(i) = tf;
      end

      propNames = moReporter.getFilteredProperties(props, filtered);
    end


    function propNames = getFilteredProperties(moReporter, props, filtered) %#ok<MANU>

      % Remove filtered properties
      if ~isempty(props)
        props(filtered) = [];
      end

      numberOfProperties = length(props);
      propNames = cell(numberOfProperties, 1);

      for i = 1:numberOfProperties
        propNames{i, 1} = props{i}.Name;
      end

    end
    
    function registerLink(moReporter)
      import rptgen.cmpn.VariableReporters.*;
      moResolver = ReportLinkResolver.getTheResolver();
      moResolver.putLink(moReporter.VarValue, moReporter);
    end
   
  end % of dynamic methods
  
end

