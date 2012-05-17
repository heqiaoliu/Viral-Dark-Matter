classdef ReporterFactory < handle
% ReporterFactory creates reporters capable of handling various MATLAB
% data types.
  
% Copyright 2010 The MathWorks, Inc.
  
 
  methods (Static)
    
    function moReporter = makeReporter(moOpts, joReport, varName, varValue)
    % makeVariableReporter creates a reporter that knows how to create a
    % report for a variable that best describes the variable's value.
      
      import rptgen.cmpn.VariableReporters.*
      
      if ischar(varValue)
        moReporter = StringReporter(moOpts, joReport, varName, varValue); 
        
      elseif islogical(varValue) % This must come before numeric
        if min(size(varValue))>1
          moReporter = LogicalArrayReporter(moOpts, joReport, varName, varValue);
        elseif length(varValue) > 1
            moReporter = LogicalVectorReporter(moOpts, joReport, varName, varValue);
        else
            moReporter = LogicalScalarReporter(moOpts, joReport, varName, varValue);
        end
        
      elseif isjava(varValue)
        if isa(varValue, 'org.w3c.dom.Node')
           moReporter = XMLDocReporter(moOpts, joReport, varName, varValue);
        else
          moReporter = StringReporter(moOpts, joReport, varName, ...
            rptgen.toString(varValue));
        end
        
      % Note; Testing for handle objects must come before testing for vector
      % objects. This is because handles are numeric objects.
      %
      % Exclude root Handle Graphics and Simulink objects because unable
      % to distinguish a handle of 0 from a numeric 0.
%       elseif isnumeric(varValue) && ~isempty(varValue) && ...
%           ishandle(varValue(1)) && (varValue(1) ~= 0)
%         if ishghandle(varValue(1))
%           if min(size(varValue))>1
%             moReporter = ObjectArrayReporter(moOpts, joReport, varName, varValue);
%           elseif length(varValue) > 1
%             moReporter = ObjectVectorReporter(moOpts, joReport, varName, varValue);
%           else
%             moReporter = HGObjectReporter(moOpts, joReport, varName, varValue);
%           end
%         else
%           if min(size(varValue))>1
%             moReporter = ObjectArrayReporter(moOpts, joReport, varName, varValue);
%           elseif length(varValue) > 1
%             moReporter = ObjectVectorReporter(moOpts, joReport, varName, varValue);
%           else
%             moReporter = SimulinkObjectReporter(moOpts, joReport, varName, varValue);
%           end
%         end
      
      % Conditional expression is complicated because it must handle arrays
      % of values and the && operator requires operands to be scalar
      % logicals.
      elseif ~isnumeric(varValue) && ~isempty(find(ishandle(varValue),1)) 
        if min(size(varValue))>1
          moReporter = ObjectArrayReporter(moOpts, joReport, varName, varValue);
        elseif length(varValue) > 1
          moReporter = ObjectVectorReporter(moOpts, joReport, varName, varValue);
        else
          moReporter = UDDObjectReporter(moOpts, joReport, varName, varValue);
        end
        
      elseif isnumeric(varValue)
        if min(size(varValue))>1
          moReporter = NumericArrayReporter(moOpts, joReport, varName, varValue);
        elseif length(varValue) > 1
            moReporter = NumericVectorReporter(moOpts, joReport, varName, varValue);
        else
            moReporter = NumericScalarReporter(moOpts, joReport, varName, varValue);
        end
      elseif iscell(varValue)
        if min(size(varValue)) > 1
          moReporter = CellArrayReporter(moOpts, joReport, varName, varValue);
        else
          moReporter = CellVectorReporter(moOpts, joReport, varName, varValue);
        end
      elseif isstruct(varValue)
        if min(size(varValue)) > 1
          moReporter = ObjectArrayReporter(moOpts, joReport, varName, varValue);
        elseif length(varValue) > 1
          moReporter = ObjectVectorReporter(moOpts, joReport, varName, varValue);
        else
          moReporter = StructureReporter(moOpts, joReport, varName, varValue);
        end
        
      elseif isobject(varValue)
        if isempty(metaclass(varValue)) % handle Simulink zpk objects
          moReporter = StringReporter(moOpts, joReport, varName, varValue);
        else
          if min(size(varValue)) > 1
            moReporter = ObjectArrayReporter(moOpts, joReport, varName, varValue);
          elseif length(varValue) > 1
            moReporter = ObjectVectorReporter(moOpts, joReport, varName, varValue);
          else
            moReporter = MCOSObjectReporter(moOpts, joReport, varName, varValue);
          end
        end
        
      else       
        valueType = class(varValue);
        if max(size(varValue)) > 1
          arrayText = msg('ErrCantRpt1');
        else
          arrayText = '';
        end
        
        errorText = ...
          sprintf(msg('ErrCantRpt2'), valueType, arrayText);
        moReporter = StringReporter(moOpts, joReport, varName, errorText);
      end
      
    end % makeVariableReporter
    
    
  end % static methods
  
end

