function generateDefaultPropValueList(hFunc,hPropList)
% Internal code generation method

% Copyright 2003-2004 The MathWorks, Inc.

% Utility for generating param-value syntax

n_props = length(hPropList);
for n = 1:n_props
   hProp = hPropList(n);
   if ~get(hProp,'Ignore')
   
      % Create param argument
      val = get(hProp,'Name');
      hArg = codegen.codeargument('Value',val,'ArgumentType','PropertyName');
      addArgin(hFunc,hArg);     
      
      % Create value argument
      hArg = codegen.codeargument('ArgumentType','PropertyValue');
      set(hArg,'Name',get(hProp,'Name'));
      set(hArg,'Value',get(hProp,'Value'));
      set(hArg,'IsParameter',get(hProp,'IsParameter'));
      addArgin(hFunc,hArg);
   end
end


