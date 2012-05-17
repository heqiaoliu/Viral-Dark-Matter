function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2003-2007 The MathWorks, Inc.

% Generate constructor like this:
% h = myconstructor(val1,val2,'prop3',val3,'prop4',val4,...)
% First two arguments are values of 'prop1' and 'prop2'

% Specify constructor name used in code
setConstructorName(code,'colorbar');

% Force properties 'prop2' and 'prop3' to always be parameters in 
% generated code
ax=double(this.Axes);
arg=codegen.codeargument('IsParameter',false,'Name','peer','Value','peer');
addConstructorArgin(code,arg);
arg=codegen.codeargument('IsParameter',true,'Name','axes','Value',ax);
addConstructorArgin(code,arg);
p = findprop(this,'Location');

if ~strcmpi(get(this,'Location'),'manual')
    if ~strcmpi(get(this,'Location'),p.FactoryValue)
        arg=codegen.codeargument('IsParameter',false,'Name','Orientation','Value',get(this,'Location'));
        addConstructorArgin(code,arg);
    end
else
    arg=codegen.codeargument('IsParameter',false,'Name','Position','Value',this.Position);
    addConstructorArgin(code,arg);
end

propsToIgnore = {'Parent','ActivePositionProperty','Layer',...
    'OuterPosition','Position','Title','XLabel',...
    'YLabel','YAxisLocation','YLim','ZLabel',...
    'ButtonDownFcn','SelectionHighlight','Tag','Image',...
    'Interruptible','XLim','Location','Box',...
    'XTick','YTick','TickDir'};
propsToAdd = {};

% Take care of default properties that are not factory values
axColor = get(ax,'Color');
% The test below comes from the colorbar constructor
if ~ischar(axColor) && sum(axColor(:))<1.5
    expColor = [1 1 1];
else
    expColor = [0 0 0];
end
if ~isequal(this.XColor,expColor)
    propsToAdd{end+1} = 'XColor';
else
    propsToIgnore{end+1} = 'XColor';
end
if ~isequal(this.YColor,expColor)
    propsToAdd{end+1} = 'YColor';
else
    propsToIgnore{end+1} = 'YColor';
end

ignoreProperty(code,propsToIgnore);
addProperty(code,propsToAdd);

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);

% If the location is set to be outside, the axes will be automatically
% resized. Add a call to [re]set the axes position afterwards, if the axes
% was in manual space:
if strncmp(fliplr(get(this,'Location')),'edistuO',7)
    if ~isappdata(double(ax),'LegendColorbarExpectedPosition') || ...
            ~isequal(getappdata(double(ax),'LegendColorbarExpectedPosition'),get(ax,'Position'))
        if strcmpi(get(ax,'ActivePositionProperty'),'Position')
            axPos = get(ax,'Position');
            code.addPostConstructorText('% Resize the axes in order to prevent it from shrinking.');
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