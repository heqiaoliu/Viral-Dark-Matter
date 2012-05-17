classdef nnetParam

% Copyright 2010 The MathWorks, Inc.
  
  properties
    fcn = '';
    values = struct;
    parameters = []; % TODO - Make this lazy evaluation
  end
  
  methods
    
    function x = nnetParam(fcn,values,parameters)
      if nargin < 1
        fcn = '';
      elseif ~ischar(fcn)
        nnerr.throw('Function is not a string.');
      end
      if nargin < 2
        if isempty(fcn)
          values = struct;
        else
          values = feval(fcn,'parameterDefaults');
        end
      elseif ~isstruct(values)
        nnerr.throw('Values are not a struct.');
      end
      if nargin < 3
        if isempty(fcn)
          parameters = [];
        else
          parameters = feval(fcn,'parameters');
        end
      elseif ~isempty(parameters) && ~isa(parameters,'nnetParamInfo')
        nnerr.throw('Param not nnetParamInfo');
      end
      x.fcn = fcn;
      x.values = values;
      x.parameters = parameters;
    end
    
    function disp(x)
      if ~isstruct(x.values)
        nnerr.throw('Bad initialization.')
      end
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if (isLoose), fprintf('\n'), end
      if isempty(x.fcn)
        disp('    No Neural Function Parameters');
      elseif isempty(x.parameters)
        disp(['    No Function Parameters for ' nnlink.fcn2strlink(x.fcn)]);
      else
        disp(['    Function Parameters for ' nnlink.fcn2strlink(x.fcn)]);
        if (isLoose), fprintf('\n'), end
        fields = fieldnames(x.values);
        maxLen1 = 0;
        maxLen2 = 0;
        maxLen3 = 0;
        for i=1:length(fields)
          fi = fields{i};
          ti = x.parameters(i).title;
          maxLen1 = max(maxLen1,length(fi));
          maxLen2 = max(maxLen2,length(ti));
          maxLen3 = max(maxLen3,length(fi) + length(ti));
        end
        for i=1:length(fields)
          fi = fields{i};
          ti = x.parameters(i).title;
          s3 = nnstring.spaces(maxLen3-length(fi)-length(ti));
          str = ['    ' ti s3 ' ' nnlink.prop2link2(fi) ': '];
          if nnstring.ends(x.parameters(i).type,'_fcn')
            disp([str nnlink.fcn2strlink(x.values.(fi))]);
          else
            disp([str nnstring.fieldvalue2str(x.values.(fi))]);
          end
        end
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function f = mfunction(x)
      f = x.fcn;
    end
    
    function x = subsref(x,s) % TODO - do I need this?
      x = subsref(x.values,s);
    end
    
    function x = subsasgn(x,s,v)
      x.values = subsasgn(x.values,s,v);
    end
    
    function f = fieldnames(x)
      f = fieldnames(x.values);
    end
    
    function s = struct(x)
      s = x.values;
    end
    
    function flag = isempty(x)
      flag = isempty(x.parameters);
    end
    
  end
end
