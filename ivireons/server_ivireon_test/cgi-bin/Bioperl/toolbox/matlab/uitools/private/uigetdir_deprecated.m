function [directoryname] = uigetdir_deprecated(varargin)
% $Revision: 1.1.6.6 $  $Date: 2010/05/20 02:30:28 $
% Copyright 2006-2008 The MathWorks, Inc.
%UIGETDIR Standard open directory dialog box
%   DIRECTORYNAME = UIGETDIR(STARTPATH, TITLE)
%   displays a dialog box for the user to browse through the directory
%   structure and select a directory, and returns the directory name
%   as a string.  A successful return occurs if the directory exists.
%
%   The STARTPATH parameter determines the initial display of directories
%   and files in the dialog box.
%
%   When STARTPATH is empty the dialog box opens in the current directory.
%
%   When STARTPATH is a string representing a valid directory path, the
%   dialog box opens in the specified directory.
%
%   When STARTPATH is not a valid directory path, the dialog box opens
%   in the base directory.
%
%   Windows:
%   Base directory is the Windows Desktop directory.
%
%   UNIX:
%   Base directory is the directory from which MATLAB is started.
%   The dialog box displays all filetypes by default. The type
%   of files that are displayed can be changed by changing the filter
%   string in the Selected Directory field of the dialog box. If the
%   user selects a file instead of a directory, then the directory
%   containing the file is returned.
%
%   Parameter TITLE is a string containing a title for the dialog box.
%   When TITLE is empty, a default title is assigned to the dialog box.
%
%   Windows:
%   The TITLE string replaces the default caption inside the
%   dialog box for specifying instructions to the user.
%
%   UNIX:
%   The TITLE string replaces the default title of the dialog box.
%
%   When no input parameters are specified, the dialog box opens in the
%   current directory with the default dialog title.
%
%   The output parameter DIRECTORYNAME is a string containing the
%   directory selected in the dialog box. If the user presses the Cancel
%   button it is set to 0.
%
%   Examples:
%
%   directoryname = uigetdir;
%
%   Windows:
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB');
%   directoryname = uigetdir('D:\APPLICATIONS\MATLAB', 'Pick a Directory');
%
%   UNIX:
%   directoryname = uigetdir('/home/matlab/work');
%   directoryname = uigetdir('/home/matlab/work', 'Pick a Directory');
%
%   See also UIGETFILE, UIPUTFILE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 02:30:28 $
%   Built-in function.

%%%%%%%%%%%%%%%%
% Error messages
%%%%%%%%%%%%%%%%

badNumArgsMessage    = 'Too many input arguments.' ;
badTitleMessage      = 'TITLE argument must be a string.' ;
badStartPathMessage  = 'STARTPATH argument must be a string.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the number of args - must be 0 , 1 , or 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxArgs = 2 ;
numArgs = nargin ;

if( numArgs > maxArgs )
    error( badNumArgsMessage )
    return
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restrict new version to the mac
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If we are on the mac, default to using non-native
% dialog. If the root property UseNativeSystemDialogs
% is false, use the non-native version instead.

useNative = true;  %#ok

% If we are on the Mac & swing is available, set useNative to false,
% i.e., we are going to use Java dialogs not native dialogs.

% Comment the following line to disable java dialogs on Mac.
useNative = ~( ismac && usejava('awt') ) ;

% If the root appdata is set and swing is available,
% honor that overriding all other prefs.

%if isequal(0, getappdata(0,'UseNativeSystemDialogs')) && isempty( javachk('swing') )
%    useNative = false ;
%end

if useNative

    try
        if nargin == 0
            [directoryname] = native_uigetdir ;
        else
            [directoryname] = native_uigetdir( varargin{:} ) ;
        end
    catch ex
        rethrow(ex)
    end

    return

end % end useNative


%%%%%%%%%%%%%%%%%
% General globals
%%%%%%%%%%%%%%%%%

dirName       = '' ;
userTitle     = '' ;
% fileSeparator = filesep ;  
% pathSeparator = pathsep ;
directoryname = '' ;  %#ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the case of exactly one argument.
% The argument must be a string specifying a directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( 1 <= numArgs )

    dirName = varargin{ 1 } ;

    % First arg must be a string

    if ~( ischar( dirName ) ) || ~( isvector( dirName ) )
        error( badStartPathMessage ) ;
    end

    if~( 1 == size( dirName , 1 ) )
        dirName = dirName' ;
    end

    % If the string is not a directory name,
    % dirName to the "base" directory.  On
    % Windows, it's the Windows Desktop dir.
    % On UNIX systems, it's the MATLAB dir.

    if ~( isdir( dirName ) )

        if ispc
            dirName = char(  com.mathworks.hg.util.dFileChooser.getUserHome() ) ;
            dirName = strcat( dirName , '\Desktop' ) ;

        else
            dirname = char( matlabroot ) ;  %#ok
        end

    end

end % end if( 1 <= numArgs )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the case of two args.
% The second arg must be a title string.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( 2 == numArgs )

    % The 2nd arg must be a string
    title = varargin{ 2 } ;

    if~( ischar( title ) && isvector( title ) )
        % Not a string
        error( badTitleMessage ) ;
    end

    % Transpose if necessary

    if( ~( 1 == size( title , 1 ) ) )
        title = title' ;
    end

    userTitle = title ;

end % if( 2 == numArgs )

directoryname = 0 ;  %#ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build the dialog that holds our file chooser and add the chooser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% jp = handle(javax.swing.JPanel) ;
jp = awtcreate('com.mathworks.mwswing.MJPanel', ...
               'Ljava.awt.LayoutManager;', ...
               java.awt.BorderLayout);

% Title is set later

d = mydialog( ...
    'Visible','off', ...
    'DockControls','off', ...
    'Color',get(0,'DefaultUicontrolBackgroundColor'), ...
    'Windowstyle','modal', ...
    'Resize','on' ...
    );

% Create a JPanel and put it into the dialog - this is for resizing

[panel, container] = javacomponent(jp,[10 10 20 20],d);

% Create a JFileChooser - 'false' means do not show as 'Save' dialog

sys = char( computer ) ;

stringSys = java.lang.String( sys ) ;

jfc = awtcreate('com.mathworks.hg.util.dFileChooser');

% Set the dialog's title

if ~( strcmp( userTitle , char('') ) )
    set( d , 'Name' , userTitle ) ;
else
    set( d , 'Name' , char( jfc.getDefaultGetdirTitle() ) )
end

awtinvoke( jfc , 'init(ZLjava/lang/String;)' , false , stringSys ) ;
%jfc.init( false , sys ) ;

awtinvoke( jfc , 'setFileSelectionMode(I)' , javax.swing.JFileChooser.DIRECTORIES_ONLY) ;

%jfc.setFileSelectionMode(javax.swing.JFileChooser.DIRECTORIES_ONLY) ;

% file = java.io.File(dirName) ; 

if ~( strcmp( dirName , char('') ) )
    awtinvoke( jfc , 'setCurrentDirectory(Ljava/io/File;)' , java.io.File(dirName) ) ;
    %jfc.setCurrentDirectory( java.io.File(dirName) ) ;
end

awtinvoke( java(panel), 'add(Ljava.awt.Component;)', jfc );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the case of no args.  In this case
% open in the user's current working dir.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( 0 == numArgs )

    % Set the chooser's current directory

    if ispc 
        awtinvoke( jfc , 'setCurrentDirectory(Ljava/io/File;)' , java.io.File(pwd) ) ;
        % jfc.setCurrentDirectory( java.io.File(pwd) ) ;
    else
        awtinvoke( jfc , 'setCurrentDirectory(Ljava/io/File;)' , java.io.File(matlabroot) ) ;
        %jfc.setCurrentDirectory( java.io.File(matlabroot) ) ;
    end % end if( 0 == numArgs )

end % end if( 0 == numArgs )


set(container,'Units','normalized','position',[0 0 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up a callback to this MATLAB file and show the dialog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jfcHandle = handle(jfc , 'callbackproperties' );

set(jfcHandle,'PropertyChangeCallback',{ @callbackHandler , d })

figure(d)
refresh(d)

awtinvoke( jfc , 'listen()' ) ;

waitfor(d);

directoryname = 0 ;

% Get the data stored by the callback

if( isappdata( 0 , 'uigetdirData' ) )
    directoryname = getappdata( 0 , 'uigetdirData' ) ;
    rmappdata( 0 , 'uigetdirData' ) ;
end

    function out = mydialog(varargin)
        out = [];
        try
            out = dialog(varargin{:}) ;
        catch ex
            rethrow(ex)
        end
    end % end myDialog

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the callback from the JFileChooser.  If the user
% selected "Open", return the name of the selected file,
% the full pathname and the index of the current filter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function callbackHandler(obj , evd , d )

jfc = obj ;
directoryname = '' ;  %#ok

cmd = char(evd.getPropertyName());

switch(cmd)
    %case 'CancelSelection'
    case 'mathworksHgCancel'
        if ishandle(d)
            directoryname = 0 ;
            setappdata( 0 , 'uigetdirData' , directoryname ) ;
            close(d) ;            
        end
    case 'mathworksHgOk'
        directoryname = char(jfc.getSelectedFile.toString) ;
        setappdata( 0 , 'uigetdirData' , directoryname ) ;
        close(d) ;

end % end switch


end % end callbackHandler
