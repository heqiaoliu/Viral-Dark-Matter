function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2006 The MathWorks, Inc. 

setConstructorName(code,'contour')

plotutils('makemcode',this,code)

% Come up with names for input variables:
xName = get(this,'XDataSource');
xName = code.cleanName(xName,'xdata');
% Come up with names for input variables:
yName = get(this,'YDataSource');
yName = code.cleanName(yName,'ydata');
% Come up with names for input variables:
zName = get(this,'ZDataSource');
zName = code.cleanName(zName,'zdata');
  
% process XData
ignoreProperty(code,'XData');
ignoreProperty(code,'XDataMode');
ignoreProperty(code,'XDataSource');
if strcmp(this.XDataMode,'manual')
  arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
      'Comment','contour x');
  addConstructorArgin(code,arg);
end

% process YData
ignoreProperty(code,'YData');
ignoreProperty(code,'YDataMode');
ignoreProperty(code,'YDataSource');
if strcmp(this.YDataMode,'manual')
  arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true,...
      'Comment','contour y');
  addConstructorArgin(code,arg);
end

% process ZData
ignoreProperty(code,'ZData');
ignoreProperty(code,'ZDataSource');
arg = codegen.codeargument('Name',zName,'Value',this.ZData,'IsParameter',true,...
    'Comment','contour z');
addConstructorArgin(code,arg);

ignoreProperty(code,'LevelListMode');
ignoreProperty(code,'LevelStepMode');
ignoreProperty(code,'TextListMode');
ignoreProperty(code,'TextStepMode');

if strcmp(this.ShowText,'off')
  ignoreProperty(code,'TextList');
  ignoreProperty(code,'TextStep');
end

generateDefaultPropValueSyntax(code);