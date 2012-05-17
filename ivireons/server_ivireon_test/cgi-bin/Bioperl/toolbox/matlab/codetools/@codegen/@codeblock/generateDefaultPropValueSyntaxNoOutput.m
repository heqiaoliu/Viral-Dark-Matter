function generateDefaultPropValueSyntaxNoOutput(hThis)

% Copyright 2003-2008 The MathWorks, Inc.

% Get handles
hFunc = getConstructor(hThis);
hMomento = get(hThis,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
  
% Give this object a name if it doesn't 
% have one already
name = [];
if isempty(get(hThis,'Name'))
   hFunc = get(hThis,'Constructor');
   name = get(hFunc,'Name');
   if ~isempty(name)
      set(hThis,'Name',name); 
   end
end

% Add Input arguments
hPropList = get(hMomento,'PropertyObjects');
local_add_argin(hThis,hFunc,hPropList,name,hObj);

%----------------------------------------------------------%
function local_add_argin(hCode,hFunc,hPropList,name,hObj)
% Adds list of properties to be input arguments to the
% specified function. The syntax will be param-value
% pairs.

n_props = length(hPropList);
for n = 1:n_props
   hProp = hPropList(n);
   if ~get(hProp,'Ignore')
   
      % Create param argument
      val = get(hProp,'Name');
      hVal = get(hProp,'Value');
      
      % If the value is a momento object, we need to create a new
      % post-constructor function which calls the SET method. There is an
      % assumption that the constructor will have generated a valid handle
      % for us to use.
      if isa(hVal,'codegen.momento')
          hArg = codegen.codeargument('Value',val,'IsParameter',false); 
          % Add Input arguments, recursing to the next level of nesting.
          hSubPropList = get(hVal,'PropertyObjects');
          if ~isempty(hSubPropList)
              % First, generate a call to GET for clarity:
              hInputArg = codegen.codeargument('Value',hObj,'IsParameter',true);
              hGetFunc = codegen.codefunction('Name','get');
              hGetFunc.addArgin(hInputArg);
              hGetFunc.addArgin(hArg);
              hOutputArg = codegen.codeargument('Name',val,'IsParameter',true,...
                  'IsOutputArgument',true,'Value',hVal.ObjectRef);
              hGetFunc.addArgout(hOutputArg);
              hCode.addPostConstructorFunction(hGetFunc);
              % Next, set the non-default properties on the nested object.
              hSetFunc = codegen.codefunction('Name','set');
              hSetFunc.addArgin(hOutputArg);
              local_add_argin(hCode,hSetFunc,hSubPropList,name,get(hObj,val));
              % If there is only one input argument to the call to SET,
              % this means that any properties were additional levels of
              % nesting. In this case, the call to GET is still necessary,
              % but the subsequent call to SET is not.
              if numel(hSetFunc.Argin) >= 3
                  hCode.addPostConstructorFunction(hSetFunc);
              end
          end
      else
          hArg = codegen.codeargument('Value',val,'ArgumentType','PropertyName');
          addArgin(hFunc,hArg);
          % Create value argument
          hArg = codegen.codeargument('ArgumentType','PropertyValue');
          set(hArg,'Name',get(hProp,'Name'));
          set(hArg,'Value',hVal);
          set(hArg,'IsParameter',get(hProp,'IsParameter'));
          set(hArg,'DataTypeDescriptor',get(hProp,'DataTypeDescriptor'));

          % This comment will appear in generated function help
          if ~isempty(name)
              comment = sprintf('%s %s', name, get(hProp,'Name'));
              set(hArg,'Comment',comment);
          end
          addArgin(hFunc,hArg);
      end
   end
end


