function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003-2008 The MathWorks, Inc.

% Specify constructor name used in code
setConstructorName(code,'legend');
set(code,'Name','legend');

% First arg is an axes
ax=double(this.Axes);
arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
addConstructorArgin(code,arg);

% Next arg is the string "show"
arg=codegen.codeargument('Value','show');
addConstructorArgin(code,arg);
propsToIgnore = {};
propsToAdd = {};

if strcmp(get(this,'Location'),'none')
  if strcmp(get(this,'ActivePositionProperty'),'position')
    propsToIgnore = {'Location','OuterPosition'};
  else
    propsToIgnore = {'Location','Position'};
  end
else
    if ~is2D(ax)
        if strcmpi(this.Location,'NorthEastOutside')
            propsToIgnore = {'Location'};
        else
            propsToAdd = {'Location'};
        end
    else
        if strcmpi(this.Location,'NorthEast')
            propsToIgnore = {'Location'};
        else
            propsToAdd = {'Location'};
        end
    end
  propsToIgnore = {propsToIgnore{:},'OuterPosition','Position'};
end
propsToIgnore = {'Parent','Layer','ActivePositionProperty',...
    'Title','XLabel','YLabel', ...
    'YAxisLocation','YLim','ZLabel','ButtonDownFcn',...
    'SelectionHighlight','Tag','Box','NextPlot','XTick',...
    'YTick','UserData','String','Interruptible','XLim','CLim',...
    'YTickLabel','XTickLabel',propsToIgnore{:}};

% Check for default properties based on the host axes:
if ~strcmpi(this.FontName,get(ax,'FontName'))
    propsToAdd{end+1} = 'FontName';
else
    propsToIgnore{end+1} = 'FontName';
end
if ~strcmpi(this.FontAngle,get(ax,'FontAngle'));
    propsToAdd{end+1} = 'FontAngle';
else
    propsToIgnore{end+1} = 'FontAngle';
end
if ~isequal(this.FontSize,get(ax,'FontSize'));
    propsToAdd{end+1} = 'FontSize';
else
    propsToIgnore{end+1} = 'FontSize';
end
if ~isequal(this.FontWeight,get(ax,'FontWeight'));
    propsToAdd{end+1} = 'FontWeight';
else
    propsToIgnore{end+1} = 'FontWeight';
end
if ~isequal(this.Color,get(ax,'Color'));
    if strcmpi(get(ax,'Color'),'none')
        fig = ancestor(ax,'Figure');
        if ~isequal(this.Color,get(fig,'Color'))
            propsToAdd{end+1} = 'Color';
        else
            propsToIgnore{end+1} = 'Color';
        end
    else
        propsToAdd{end+1} = 'Color';
    end
else
    propsToIgnore{end+1} = 'Color';
end
ignoreProperty(code,propsToIgnore);
addProperty(code,propsToAdd);

% Generate remaining properties as property/value syntax
% Add Output argument
hFunc = code.Constructor;
hArg = codegen.codeargument('Value',this,...
                            'Name',get(hFunc,'Name'));
addArgout(hFunc,hArg);

% Generate calls to the SET function
localCallSet(code);

% If the location is set to be outside, the axes will be automatically
% resized. Add a call to [re]set the axes position afterwards, if the axes
% was in manual space:
if strncmp(fliplr(get(this,'Location')),'edistuO',7)
    if ~isappdata(double(ax),'LegendColorbarExpectedPosition') || ...
            ~isequal(getappdata(double(ax),'LegendColorbarExpectedPosition'),get(ax,'Position'))
        if strcmpi(get(ax,'ActivePositionProperty'),'Position')
            axPos = get(ax,'Position');
            code.addPostConstructorText(sprintf('%% Resize the axes in order to prevent it from shrinking.'));
            hFunc = codegen.codefunction('Name','set');
            axArg = codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
            propArg = codegen.codeargument('Value','Position','ArgumentType','PropertyName');
            valArg = codegen.codeargument('ArgumentType','PropertyValue','Value',axPos);
            hFunc.addArgin(axArg);
            hFunc.addArgin(propArg);
            hFunc.addArgin(valArg);
            code.addPostConstructorFunction(hFunc);
        end
    end
end

%------------------------------------------------------------------------%
function localCallSet(code)
% Generate calls to the set function

% Create the function:
hFunc = codegen.codefunction('Name','set');
name = code.Name;

% Add Input arguments
hMomento = get(code,'MomentoRef');
hObj = get(hMomento,'ObjectRef');
hPropList = get(hMomento,'PropertyObjects');

% First argument is the object:
hArg = codegen.codeargument('Value',hObj,'IsParameter',true);
hFunc.addArgin(hArg);

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
      set(hArg,'DataTypeDescriptor',get(hProp,'DataTypeDescriptor'));
            
      % This comment will appear in generated m-help
      if ~isempty(name)
         set(hArg,'Comment',sprintf('%s %s', name, get(hProp,'Name')));
      end
      addArgin(hFunc,hArg);
   end
end
% Only call set if there are properties to set
if ~isscalar(hFunc.Argin)
    code.addPostConstructorFunction(hFunc);
end

