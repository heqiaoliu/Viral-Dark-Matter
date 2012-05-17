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

% next args are position in normalized coordinates
arg=codegen.codeargument('Value',this.NormX,'Name','X');
addConstructorArgin(code,arg);
arg=codegen.codeargument('Value',this.NormY,'Name','Y');
addConstructorArgin(code,arg);

ignoreProperty(code,'HitTest');
ignoreProperty(code,'X');
ignoreProperty(code,'Y');
ignoreProperty(code,'Position');
ignoreProperty(code,'Parent');

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);