classdef nnetSetting

% Copyright 2010 The MathWorks, Inc.
  
  properties
    fcn = '';
    values = struct;
  end
  
  methods
    
    function x = nnetSetting(fcn,values)
      if nargin == 0
        x.fcn = '';
        x.values = struct;
      elseif nargin == 2 
        x.fcn = fcn;
        x.values = values;
        if ~ischar(fcn), nnerr.throw('Fcn not a function name'); end
        if ~isstruct(values), nnerr.throw('Values not a struct.'); end
      else
        nnerr.throw('Incorrect number of arguments.');
      end
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if (isLoose), fprintf('\n'), end
      if isempty(x.fcn)
        disp('    No Neural Function Settings');
      elseif isempty(fieldnames(x.values))
        disp(['    No Function Settings for ' nnlink.fcn2ulink(upper(x.fcn))]);
      else
        disp(['    Function Settings for ' nnlink.fcn2ulink(upper(x.fcn))]);
        if (isLoose), fprintf('\n'), end
        fields = fieldnames(x.values);
        maxLen = 0;
        for i=1:length(fields)
          maxLen = max(maxLen,length(fields{i}));
        end
        for i=1:length(fields)
          fi = fields{i};
          disp([nnlink.prop2link(fi,maxLen) nnstring.fieldvalue2str(x.values.(fi))]);
        end
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function x = subsref(x,s)
      x = subsref(x.values,s);
    end
    
    function x = subsasgn(x,s,v)
      nnerr.throw('nnetSetting properties are read-only.');
    end
    
    function fn = fieldnames(x)
      fn = fieldnames(x.values);
    end
    
    function s = struct(x)
      s = x.values;
    end
    
    function flag = isempty(x)
      flag = isempty(fieldnames(x.values));
    end
  end
end
