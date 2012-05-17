function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2006 The MathWorks, Inc. 

is3D = false;
ZData = get(this,'ZData');
if ~isempty(ZData)
   is3D = true;
end

if is3D
    setConstructorName(code,'scatter3');
    constName = 'scatter3';
else
    setConstructorName(code,'scatter');
    constName = 'scatter';
end

plotutils('makemcode',this,code)
  
ignoreProperty(code,{'XData','YData','ZData','SizeData','CData',...
    'XDataSource','YDataSource','ZDataSource','SizeDataSource',...
    'CDataSource'});

% process XData
% Come up with names for input variables:
xName = get(this,'XDataSource');
xName = code.cleanName(xName,'X');
arg = codegen.codeargument('Name',xName,'Value',this.XData,'IsParameter',true,...
    'Comment',[constName ' X']);
addConstructorArgin(code,arg);

% process YData
% Come up with names for input variables:
yName = get(this,'YDataSource');
yName = code.cleanName(yName,'Y');
arg = codegen.codeargument('Name',yName,'Value',this.YData,'IsParameter',true,...
    'Comment',[constName ' Y']);
addConstructorArgin(code,arg);

if is3D
    % Come up with names for input variables:
    zName = get(this,'ZDataSource');
    zName = code.cleanName(zName,'Z');
    arg = codegen.codeargument('Name',zName,'Value',this.ZData,'IsParameter',true,...
        'Comment',[constName ' Z']);
    addConstructorArgin(code,arg);
end

% process SizeData
% Come up with names for input variables:
sName = get(this,'SizeDataSource');
sName = code.cleanName(sName,'S');
arg = codegen.codeargument('Name',sName,'Value',this.SizeData,'IsParameter',true,...
    'Comment',[constName ' S']);
addConstructorArgin(code,arg);

% process CData
% Come up with names for input variables:
cName = get(this,'CDataSource');
cName = code.cleanName(cName,'C');
arg = codegen.codeargument('Name',cName,'Value',this.CData,'IsParameter',true,...
    'Comment',[constName ' C']);
addConstructorArgin(code,arg);

generateDefaultPropValueSyntax(code);