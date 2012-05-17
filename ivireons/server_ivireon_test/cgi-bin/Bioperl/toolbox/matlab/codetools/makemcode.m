function [out,hCodeTree] = makemcode(varargin)
% This undocumented function may change in a future release.

%MAKEMCODE Generates readable m-code function based on input object(s)
%
%  MAKEMCODE(H) Generates m-code for re-creating the input handle
%               and its childen.
%
%  MAKEMCODE(H,'Output','-editor') Display code in the desktop editor
%
%  STR = MAKEMCODE(H,'Output','-string') Output code as a string variable
%
%  MAKEMCODE(H,'Output','D:/Work/mycode.m') Output code as a file
%
%  MAKEMCODE(H,...,'ShowStatusBar',[true]/false) Displays status bar
%
%  MAKEMCODE(H,...,'MLint',true/[false]) Will error if the generated code
%  contains MLint warnings
%
%  MAKEMCODE(H,...,'Debug',true/[false]) Will send errors to the command
%  window rather than displaying them in the GUI.
%
%  Use SAVE and/or HGSAVE for full object serialization.
%
%  Limitations
%  Using MAKEMCODE to generate code for graphs containing a large
%  number (e.g., greater than 20 plotted lines) of graphics objects
%  may be impractical.
%
%  Example:
%
%  surf(peaks);
%  makemcode(gcf);

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.22 $  $Date: 2010/05/20 02:24:15 $

% Undocumented syntax for internal use:
%
% MAKEMCODE(H,param,val,...)
%   'OutputTopNode'   true/[false]
%   'ReverseTraverse' true/[false]
%
%
% MAKEMCODE('RegisterHandle',hContainer,....
%           'IgnoreHandle',hTarget,...
%           'FunctionName','callingfunction')
% Call this syntax for plot types that currently don't support code
% generation. This will generate a nice warning in the generated code
% so that at least the user can see the original calling function.
%   'RegisterHandle'    Register this handle (i.e. group object, primitive)
%   'IgnoreHandle'      Array of handles contained by 'ContainerHandle'
%   'FunctionName'      Generate this name in the warning message
%
% MAKEMCODE('RegisterHandle',hContainer,...
%           'MCodeConstructorFcn',function_handle,...
%           'MCodeIgnoreHandleFcn',function_handle)
%   'RegisterHandle'    Register this handle (i.e. group object, primitive)
%   'MCodeConstructorFcn' Callback function_handle

hwait = [];

% Undocumented handle registration syntax (see above)
if length(varargin)>0 && ischar(varargin{1}) && strcmp(varargin{1},'RegisterHandle')
    localRegisterHandle(varargin{:});
    return
end

[h,options] = local_parse_input(varargin{:});
show_status_bar = options.ShowStatusBar;
uion = show_status_bar;
doDebug = options.Debug;

h = handle(h);
ERROR_ID = 'MATLAB:codetools:makemcode';

if length(h)~=1 || isempty(h) || ~ishandle(h)
    error(ERROR_ID,'Valid input object required');
end

if ~local_does_support_codegen(h)
    error(ERROR_ID,'This object does not support code generation');
end

% HG seems to connect graphics objects in a backwards way with respect
% to connectivity, so reverse traversal if this is not an HG hierarchy
if ~isa(h,'hg.GObject')
    options.ReverseTraverse = ~(options.ReverseTraverse);
end

% Flush graphics queue before inspecting objects
drawnow

% Display wait bar for status feedback
if show_status_bar,
    hwait = waitbar(.1,...
        'Traversing object hierarchy, please wait...',...
        'Name','M-Code Generation');
end

pk = findpackage('codegen');
cls = findclass(pk,'codetree');
hListener = handle.listener(cls,'MomentoComplete',{@local_update_wait_bar,hwait,.25,...
    'Generating syntax tree, please wait...',show_status_bar});
% Traverse object hierarchy and create a syntax tree of code blocks, where
% each code block represnts the creation of an object. Within a code block
% object there will generally be one constructor object and helper
% function object placed before or after the constructor.
if doDebug
    hCodeTree = codegen.codetree(h,options);
else
    try
        hCodeTree = codegen.codetree(h,options);
    catch myException
        local_handle_error(uion,hwait,myException.message);
        return;
    end
end

% Update wait bar
if show_status_bar,
    waitbar(.65,hwait,'Generating variable list, please wait...');
    drawnow;
end

hProgram = codegen.codeprogram;
hProgram.addSubFunction(hCodeTree);
hListener = handle.listener(hProgram,'TextComplete',{@local_update_wait_bar,hwait,.95,...
    'Generating final text representation, please wait...',show_status_bar});

% Traverse code block tree and build up the final text that represents
% the generated code.
if doDebug
    mcode_str = hProgram.toMCode(options);
else
    try
        mcode_str = hProgram.toMCode(options);
    catch myException
        local_handle_error(uion,hwait,myException.message);
        return;
    end
end

% Close wait bar
if show_status_bar, close(hwait); end

% Check code with MLint. This is a debugging flag and is off by default.
str = [];
for n = 1:length(mcode_str)
    str = [str,mcode_str{n},sprintf('\n')];
end

if options.MLint
    messages = com.mathworks.widgets.text.mcode.MLint.getMessages(str,[]);
    % Convert the messages to text:
    messageArray = messages.toArray;
    msgStr = '';
    for i=1:length(messageArray)
        currMessage = messageArray(i);
        msgText = sprintf('%d %s',currMessage.getLineNumber,currMessage.getMessage.toCharArray');
        if i~=1
            msgStr = [msgStr char(10) msgText];
        else
            msgStr = msgText;
        end
    end
    if ~isempty(msgStr)
        if doDebug
            error(ERROR_ID,'The following MLint Messages were detected:\n%s',msgStr);
        else
            try
                error(ERROR_ID,'The following MLint Messages were detected:\n%s',msgStr);
            catch myException
                local_handle_error(uion,hwait,myException.message);
                return;
            end
        end
    end
end

% Display to command window or widget
if doDebug
    local_display_mcode(str,options);
else
    try
        local_display_mcode(str,options);
    catch myException
        local_handle_error(uion,hwait,myException.message);
        return;
    end
end

if strcmp(options.Output,'-string') && nargout>0
    out = str;
end

%----------------------------------------------------------%
function local_handle_error(uion,hwait,msg)

if uion
    if ishandle(hwait)
        delete(hwait);
    end
    errordlg(msg,'Code Generation Error');
    return;
else
    disp(msg)
end

%----------------------------------------------------------%
function local_update_wait_bar(obj,evd,hwait,val,string,show_status_bar)
% Update wait bar
if show_status_bar,
    waitbar(val,hwait,string);
    drawnow;
end

%----------------------------------------------------------%
function [h,options] = local_parse_input(varargin)
% Parse input arguments
h = [];
options.Output = '-editor';
options.OutputTopNode = false;
options.ReverseTraverse = false;
options.ShowStatusBar = true;
options.MFileName = '';
options.MLint = false;
options.Debug = false;

if nargin==0,
    h = gcf;
elseif nargin==1
    arg1 = varargin{1};
    if ishandle(arg1)
        h = arg1;
    elseif ischar(arg1)
        h = gcf;
        option.Display = arg1;
    end
elseif nargin==2
    error('MATLAB:codetools:makemcode','Incorrect number of input arguments.');
elseif nargin>2
    h = varargin{1};
    varargin(1) = [];
    while ~isempty(varargin)
        switch lower(varargin{1})
            case 'outputtopnode'
                options.OutputTopNode = varargin{2};
                varargin(1:2) = [];
            case 'reversetraverse'
                options.ReverseTraverse = varargin{2};
                varargin(1:2) = [];
            case 'showstatusbar'
                options.ShowStatusBar = varargin{2};
                varargin(1:2) = [];
            case 'output'
                options.Output = varargin{2};
                varargin(1:2) = [];
                if ~ischar(options.Output)
                    error('MATLAB:codetools:makemcode','Invalid filename');
                end
                if ( ~strcmp(options.Output,'-editor') && ...
                        ~strcmp(options.Output,'-string') && ...
                        ~strcmp(options.Output,'-cmdwindow') )
                    options.MFileName = local_get_mfilename(options.Output);
                end
            case 'mlint'
                options.MLint = varargin{2};
                varargin(1:2) = [];
                if ~islogical(options.MLint)
                    error('MATLAB:codetools:makemcode','MLint flag must be true or false');
                end
            case 'debug'
                options.Debug = varargin{2};
                varargin(1:2) = [];
                if ~islogical(options.Debug)
                    error('MATLAB:codetools:makemcode','Debug flag must be true or false');
                end
            otherwise
                error('MATLAB:codetools:makemcode','Invalid input');
        end % switch
    end % while
end % elseif

%----------------------------------------------------------%
function [mfile_name] = local_get_mfilename(full_filename)
% Determine function name from full file name

[dir_name, mfile_name, ext_name] = fileparts(full_filename); %#ok

%----------------------------------------------------------%
function local_display_mcode(mcode_str,option)
% Display code

% Display in command window
if strcmp(option.Output,'-cmdwindow')
    disp(mcode_str);

    % Display in the editor
elseif strcmp(option.Output,'-editor')

    % Throw to command window if java is not available
    err = javachk('mwt','The MATLAB Editor');
    if ~isempty(err)
        local_display_mcode(mcode_str,'cmdwindow');
    end
    % Convert to char array, add line endings
    editorDoc = editorservices.new(mcode_str);
    editorservices.matlab.smartIndentContents(editorDoc);
    % Scroll document to line 1
    editorDoc.goToLine(1);
    
elseif strcmp(option.Output,'-string')

    % Write to a file
else
    fid = fopen(option.Output,'w');
    if(fid<0)
        error('MATLAB:codetools:makemcode',['Could not create file: ',option.Output]);
    end
    fprintf(fid,'%s',mcode_str);
    fclose(fid);
end

%----------------------------------------------------------%
function localRegisterHandle(varargin) %ok
%
% LOCALREGISTERHANDLE('RegisterContainer',hContainer,....
%                     'IgnoreHandle',hTarget,...
%                     'FunctionName','callingfunction')
% Call this syntax for plot types that currently don't support code
% generation. This will generate a nice warning in the generated code
% so that at least the user can see the original calling function.
%   'RegisterHandle'    Register this handle (i.e. group object, primitive)
%   'IgnoreHandle'      Array of handles contained by 'ContainerHandle'
%   'FunctionName'      Generate this name in the warning message
%
% LOCALREGISTERHANDLE('RegisterHandle',hContainer,...
%                     'MCodeConstructorFcn',function_handle,...
%                     'MCodeIgnoreHandleFcn',function_handle)
%   'RegisterHandle'    Register this handle (i.e. group object, primitive)
%   'MCodeConstructorFcn' Callback function_handle

% Use appdata instead of behavior to ensure fast performance
if length(varargin)>5 && strcmp(varargin{3},'IgnoreHandle')
    hContainer = varargin{2};
    hTarget = varargin{4};
    func_name = varargin{6};
    info.MCodeIgnoreHandleFcn = {@localMCodeIgnoreHandle,hTarget};
    info.MCodeConstructorFcn = {@localMCodeConstructor,func_name};
    for n = 1:length(hContainer)
        setappdata(hContainer(n),'MCodeGeneration',info)
    end
elseif length(varargin)>3 && strcmp(varargin{3},'MCodeConstructorFcn')
    hContainer = varargin{2};
    info.MCodeConstructorFcn = varargin{4};
    if length(varargin)>5 && strcmp(varargin{5},'MCodeIgnoreHandleFcn')
        info.MCodeIgnoreHandleFcn = varargin{6};
    end
    for n = 1:length(hContainer)
        setappdata(hContainer(n),'MCodeGeneration',info)
    end
end

%--------------------------------------------------------%
function localMCodeConstructor(hContainer,hCode,fname) %#ok
% Generate a warning message in the generated code
% hContainer: handle
% hCode: codegen.codeblock class
% fname: char array

hFunc = getConstructor(hCode);
str = sprintf('%% %s(...)',fname);
comment = sprintf('%s currently does not support code generation, enter ''doc %s'' for correct input syntax\n',fname,fname);
set(hFunc,'Comment',comment);
set(hFunc,'Name',str);

%--------------------------------------------------------%
function bool = localMCodeIgnoreHandle(hContainer,hInput,hIgnore) %#ok
% Ignore handle if the input handle is the same as the specified target
% handle.

bool = any(isequal(handle(hInput),handle(hIgnore)));

%----------------------------------------------------------%
function [retval] = local_does_support_codegen(h)
% Object must be an HG primitives or implement the mcode generation
% interface

retval = true;
if ishandle(h)
    package_name = get(get(classhandle(h),'Package'),'Name');
    if ~strcmp(package_name,'hg') && ...
            ~ismethod(h,'mcodeConstructor') && ...
            ~ismethod(h,'mcodeIgnoreHandle')
        retval = false;
    end
end
