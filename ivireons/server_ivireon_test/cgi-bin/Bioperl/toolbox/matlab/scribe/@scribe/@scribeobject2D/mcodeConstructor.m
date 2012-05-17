function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Customize object code generation
% code is a codegen.codeblock object

% Copyright 2006-2007 The MathWorks, Inc.

set(code,'Name',this.ShapeType);
% Specify constructor name used in code
setConstructorName(code,'annotation');

fig=ancestor(this,'figure');
arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
addConstructorArgin(code,arg)

arg=codegen.codeargument('Value',this.ShapeType);
addConstructorArgin(code,arg);

propsToIgnore = {'HitTest','Parent'};
ignoreProperty(code,propsToIgnore);

% Work around for code generation bug
% Remove String property if string is empty
if isprop(this,'String')
    str = get(this,'String');
    if isempty(str)
        ignoreProperty(code,'String');
    end
end

% According to the documentation, the first input argument should be the
% position vector, in normalized coordinates:
hPos = get(this,'Position');
hPos = hgconvertunits(fig,hPos,get(this,'Units'),'Normalized',fig);
arg2 = codegen.codeargument('Name','position','Value',hPos);
addConstructorArgin(code,arg2);
ignoreProperty(code,'Position');

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);