function mcodeConstructor(this,code)
%MCODECONSTRUCTOR Constructor code generation 

%   Copyright 1984-2006 The MathWorks, Inc. 

is3D = ~isempty(this.zdata);

if is3D
   setConstructorName(code,'quiver3')
   constName = 'quiver3';
else
    setConstructorName(code,'quiver')
    constName = 'quiver';
end

plotutils('makemcode',this,code)

ignoreProperty(code,{'XData','YData','ZData',...
    'XDataMode','YDataMode',...
    'XDataSource','YDataSource',...
    'ZDataSource','UDataSource',...
    'VDataSource','WDataSource',...
    'UData','VData','WData'});

% process XData
if strcmp(this.xdatamode,'manual')
    % Come up with names for input variables:
    xName = get(this,'XDataSource');
    xName = code.cleanName(xName,'X');

    arg = codegen.codeargument('Name',xName,'Value',this.xdata,'IsParameter',true,...
        'Comment',[constName ' X']);
    addConstructorArgin(code,arg);
end

% process YData
if strcmp(this.ydatamode,'manual')
    % Come up with names for input variables:
    yName = get(this,'YDataSource');
    yName = code.cleanName(yName,'Y');

    arg = codegen.codeargument('Name',yName,'Value',this.ydata,'IsParameter',true,...
        'Comment',[constName ' Y']);
    addConstructorArgin(code,arg);
end

% process ZData
if is3D
    % Come up with names for input variables:
    zName = get(this,'ZDataSource');
    zName = code.cleanName(zName,'Z');

    arg = codegen.codeargument('Name',zName,'Value',this.zdata,'IsParameter',true,...
        'Comment',[constName ' Z']);
    addConstructorArgin(code,arg);
end

% process UData
% Come up with names for input variables:
uName = get(this,'UDataSource');
uName = code.cleanName(uName,'U');

arg = codegen.codeargument('Name',uName,'Value',this.udata,'IsParameter',true,...
    'Comment',[constName ' U']);
addConstructorArgin(code,arg);

% process VData
% Come up with names for input variables:
vName = get(this,'VDataSource');
vName = code.cleanName(vName,'V');

arg = codegen.codeargument('Name',vName,'Value',this.vdata,'IsParameter',true,...
    'Comment',[constName ' V']);
addConstructorArgin(code,arg);

% process WData
if is3D
    % Come up with names for input variables:
    wName = get(this,'WDataSource');
    wName = code.cleanName(wName,'W');

    arg = codegen.codeargument('Name',wName,'Value',this.wdata,'IsParameter',true,...
        'Comment',[constName ' W']);
    addConstructorArgin(code,arg);
end

% process Color
if strcmp(this.CodeGenColorMode,'auto')
  ignoreProperty(code,'Color')
end

generateDefaultPropValueSyntax(code);