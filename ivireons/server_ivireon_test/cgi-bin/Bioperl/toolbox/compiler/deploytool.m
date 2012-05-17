function deploytool(varargin)

%DEPLOYTOOL Deployment product user interface
%
%    This function will start the Deployment Tool. You can create,
%    build and package various deployment projects using the Graphical
%    User Interface (GUI), or you can build and package existing 
%    projects from the Command Line Interface.
%
%    USAGE:
%    deploytool will bring up an empty tool with information on how to
%    open an existing project or create a new project.
%
%    deploytool projectname will open an existing project. If the project
%    does not exist, an error will be generated and the program will exit.
%
%    deploytool -build projectname will build an existing project 
%    from the Command Line Interface.
% 
%    deploytool -package projectname packagename will package 
%    an existing project from the Command Line Interface. Specifying
%    packagename is optional. By default, a project is packaged into a
%    zip file. On Windows, if the packagename ends with .exe, the
%    project will be packaged into a self-extracting EXE.
%
%    DEPLOYTOOL -? will display this message.
%
%    See also mcc, mbuild

% Copyright 1984-2007 The MathWorks, Inc.

% error(nargchk(0,1,nargin, 'struct'));

% show help info for "deploytool -?", otherwise call Java to parse the command line.
if (nargin == 1 && (strcmp(varargin{1}, '-?') || strcmp(varargin{1}, '/?')))
    disp(usage());              
    return;
else    
    com.mathworks.mde.deploytool.plugin.PluginManager.allowMatlabThreadUse()
    com.mathworks.toolbox.compiler.plugin.DeploytoolCommandLineParser.parse(varargin, pwd);
end

% switch(nargin)
%     case 0
%         % open the project manager without a project
%         try
%              com.mathworks.mde.deploytool.NewOrOpenDialog.invoke;
%         catch ex
%             error('Compiler:deploytool:couldNotOpenProject',...
%             ['Error opening the deployment tool. Please restart MATLAB. \n'...
%              'If the problem persists, please contact technical support \n'...
%              'by filling out the online support request form at \n'...
%              '<a href="http://www.mathworks.com/support/contact_us/index.html">'...
%              'http://www.mathworks.com/support/contact_us/index.html</a>. \n'...
%              'Attach the following information in the request\n\n'...
%              '============ BEGIN HERE ============\n %s\n'...
%              '============= END HERE =============\n'], ex.message);
%         end
%     case 1
%         % open an existing project
%         if ( strncmp(varargin{1}, '-', 1) )
%             if ( strcmpi(varargin{1},'-n') )
%                 try
%                     com.mathworks.mde.deploytool.NewOrOpenDialog.invoke;
%                     return;
%                 catch
%                     error('Compiler:deploytool:couldNotCreateNewProject',...
%                         'Could not create a new project');
%                 end
%             end
%             if ( strcmp(varargin{1}, '-?') )
%                 disp(usage());
%                 return;
%             else
%                 error('Compiler:deploytool:invalidOption',...
%                     'Invalid option ''%s''', varargin{1});
%             end
%         end
%         if(ischar(varargin{1}) )
%             file = varargin{1};
%             [pathstr,name,ext] = fileparts(file);
%             if( isempty(ext))
%                 ext = '.prj';
%             end
% 
%             file = [name, ext];
%             if( isempty(pathstr) )
%                 file=which(file);
%             else
%                 file = fullfile(pathstr,file);
%             end
%             if( exist(file,'file')  && ...
%                 exist(file,'file') ~= 7) % ensure its not a directory
% 
%                 try
%                     com.mathworks.mde.deploytool.DeployTool.invoke(file);
%                 catch ex
%                     error('Compiler:deploytool:errorOpeningPrj',...
%                         ['The following error occurred when opening ''%s''.\n',...
%                          ex.message], varargin{1});
%                 end
%             else
%                 error('Compiler:deploytool:invalidProjectFile',...
%                     '''%s'' does not exist or is a directory.', varargin{1});
%             end
%         else
%             error('Compiler:deploytool:invalidInput',...
%                 'Invalid input passed to deploytool');
%         end
% end
% 
 function str=usage()
 str=evalc(['help ' mfilename]);
