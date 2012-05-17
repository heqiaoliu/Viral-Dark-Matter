function [selectedColor] = uisetcolor_deprecated(varargin)
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/24 19:20:02 $

%%%%%%%%%%%%%%%%
% Error messages
%%%%%%%%%%%%%%%%

%bad1ArgMessage      = 'First of two args cannot be a string' ;
bad2ArgMessage      = 'Second argument (dialog title) must be a string.' ;
badTitleMessage     = 'title must be the last parameter passed to uisetcolor.' ;
badNumArgMessage    = 'Too many input arguments.' ;
badRgbAryMessage    = 'Color value contains NaN, or element out of range 0.0 <= value <= 1.0.' ;
badObjTypMessage    = 'Color selection is not supported for light objects.' ;
badPropertyMessage  = 'Color selection is only supported for objects with Color or ForeGroundColor properties.' ;
badColorValMessage  = 'Color value must be a 3 element numeric vector.' ;
badColorSelMessage1 = 'Color selection is not supported for' ;
badColorSelMessage2 = ' objects, but only for objects with Color or ForeGroundColor properties.' ;

maxArgs = 2 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the number of args - must be <= maxArgs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numArgs = nargin ;

if( numArgs > maxArgs )
    error( badNumArgMessage )
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Restrict new version to the mac
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If we are on the mac, default to using non-native
% dialog. If the root property UseNativeSystemDialogs
% is false, use the non-native version instead.

useNative = true; %#ok<NASGU>

% If we are on the Mac & swing is available, set useNative to false,
% i.e., we are going to use Java dialogs not native dialogs.

% Comment the following line to disable java dialogs on Mac.
useNative = ~( ismac && usejava('awt') ) ;

% If the root appdata is set and swing is available,
% honor that overriding all other prefs.

% if isequal(0, getappdata(0,'UseNativeSystemDialogs')) && usejava('awt')
%     useNative = false ;
% end

if useNative

    try
        if nargin == 0
            [selectedColor] = native_uisetcolor ;
        else
            [selectedColor] = native_uisetcolor( varargin{:} ) ;
        end
    catch ex
        rethrow(ex)
    end

    return

end % end useNative


%%%%%%%%%%%%%%%%%
% General globals
%%%%%%%%%%%%%%%%%

%dcc          = '' ; % dColorChooser - our Java ColorChooser
rgbArray     = '' ;
%sz           = '' ;
objectType   = '' ;
%propertyName = '' ;
firstArg     = '' ;
propUsed     = '' ;
userTitle    = '' ;
sys          = char( computer ) ; % String the type of computer - PCWIN, MAC, ...ui

%%%%%%%
% Flags
%%%%%%%

typeFound      = false ;

rgbHandedIn    = false ;
objectHandedIn = false ;

arg1IsBad      = false ;
arg1IsRGB      = false ;
arg1IsChar     = false ;
arg1IsHgHandle = false ;

%rgbError     = false ;

%%%%%%%%%%%%%%%%%%%%%%
% Default color values
%%%%%%%%%%%%%%%%%%%%%%

red   = 1.0 ;
green = 1.0 ;
blue  = 1.0 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check the first arg if there is one
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( 1 <= numArgs )

    firstArg = varargin{1} ;
    getArg1Type() ;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Bail out if the first arg is not the correct type
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if( arg1IsBad )

        if( ishandle( firstArg ) )

            try
                objectType = get( firstArg , 'Type' ) ;
                typeFound = true ;
            catch
            end

        end % end if( ishandle( firstArg ) )

        if( ~typeFound )
            error( badPropertyMessage ) ;
        else
            objectType = strcat( '  ' ,  objectType ) ;
            error( strcat( badColorSelMessage1 , objectType , badColorSelMessage2 ) ) ;
        end

        return ;

        % end if( arg1IsBad )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Check to see that we really do have an RGB arg
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif( arg1IsRGB )

        % Check for 3 vals

        if ~( 3 == length( firstArg ) )
            error( badColorValMessage ) ;
        end

        rgbArray = firstArg;

        % Check that vals are in range
        rgbError = checkRGB() ;

        if( rgbError )
            error( badRgbAryMessage )
        end

        % Overwrite the default rgb values

        red   = rgbArray( 1 , 1 )  ;
        green = rgbArray( 1 , 2 )  ;
        blue  = rgbArray( 1 , 3 )  ;

        rgbHandedIn = true ;

        % end if( arg1IsRGB )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Make sure that if first arg is a string, then it's the only arg
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif( arg1IsChar )

        if~( 1 == numArgs )
            error( badTitleMessage )
        end

        % We'll use the string as a title

        userTitle = firstArg ;

        %end if( arg1IsChar )

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Make sure the object is not of type 'light' (cpmpat)
        % and that it has the Color or ForegroundColor property
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    else
        if( arg1IsHgHandle )

            objectType = get( firstArg , 'Type' ) ;

            % The current uisetcolor does not support "light" objects

            %if( strcmp( 'light' , lower( objectType ) ) )
            if (strcmpi('light',objectType))
                error( badObjTypMessage )
            end

            hasColorProperty = false ;
            hasForegroundProperty = false ;

            % Make sure the object has either the
            % Color or ForegroundColor property.

            propFound = false ;

            try
                rgbArray = get( firstArg , 'Color' ) ;
                hasColorProperty = true ;
                propUsed = 'Color' ;
                propFound = true ;
            catch

            end

            if( ~propFound )
                try
                    rgbArray = get( firstArg , 'ForegroundColor' ) ;
                    hasForegroundProperty = true ;
                    propUsed =  'ForegroundColor' ;
                catch
                end
            end % end if( ~propFound )

            if( ~hasColorProperty && ~hasForegroundProperty )
                error( badPropertyMessage )
            end

            % Overwrite the default rgb values

            red   = rgbArray( 1 , 1 )  ;
            green = rgbArray( 1 , 2 )  ;
            blue  = rgbArray( 1 , 3 )  ;

            objectHandedIn = true ;
            
        end % end if( arg1IsHgHandle )

    end % end of if/elseif

end % end if( 1 <= numArgs )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If there are two args, the second must be a character string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( 2 == numArgs )

    arg2 = varargin{ 2 } ;

    if( ~( ischar( arg2 ) ) )
        error( bad2ArgMessage )
    end

    if( ~( 1 == size( arg2 , 1 ) ) )
        arg2 = arg2';

        if( ~( ischar( arg2 ) ) )
            error( bad2ArgMessage )
        end

    end % end if( ~( 1 == size( arg2 , 1 ) ) )

    userTitle = arg2 ;

end % end if( 2 == numArgs )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a dialog to hold our ColorChooser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% jp = handle(javax.swing.JPanel) ;
jp = awtcreate('com.mathworks.mwswing.MJPanel', ...
               'Ljava.awt.LayoutManager;', ...
               java.awt.BorderLayout);

% Dialog title is set later

d = mydialog( ...
    'Visible','off', ...
    'Color',get(0,'DefaultUicontrolBackgroundColor'), ...
    'Windowstyle','modal', ...
    'Resize','on' ) ;

% Create an MJPanel and put it into the dialog - this is for resizing

[panel, container] = javacomponent(handle(jp),[10 10 20 20],d);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a chooser with the appropriate initial setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( objectHandedIn )

    % Some object was handed in.  Find its Color-related properties.

    s = set( firstArg ) ;
    flds = fields( s ) ;

    propArray = '' ;

    j = 1 ;

    % Create an array of "Color-related" properties for this figure

    for i = 1 : length( flds )

        if ~( isempty( findstr( flds{i} , 'Color' ) ) )
            propArray{ 1 , j } = flds{i}  ;
            j = j + 1 ;
        end % end if

    end % end for

    jcc = handle(com.mathworks.hg.util.dColorChooser( java.awt.Color( red , green , blue ) , propArray , propUsed , sys ));

    % Make the dialog large enough
    % to show the Color-related properties combo box

    set( d , 'Position' , [232 246 145 270] ) ;

else

    % No object was handed in.
    % No combo box - figure can be smaller

    set( d , 'Position' , [232 246 145 230] ) ;

    jcc = handle(com.mathworks.hg.util.dColorChooser( java.awt.Color( red , green , blue ) , [] , [] , sys ));

end % end if( objectHandedIn )

% Use supplied title if one was given else use default

if ~( strcmp( '' , userTitle ) )
    set( d , 'Name' , userTitle ) ;
else
    set( d , 'Name' , char( jcc.getDefaultTitle() ) )
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add the panel holding the actual chooser to the panel in the dialog
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dcc = jcc.getContentPanel() ;

awtinvoke(java(panel), 'add(Ljava.awt.Component;)', dcc);

set(container,'Units','normalized','position',[0 0 1 1]);

%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
% Set up callbacks
%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%

% jbOK = javax.swing.JButton() ;
jbOK = handle( jcc.getOkButton(), 'callbackproperties') ;
set(jbOK ,'ActionPerformedCallback', {@callbackHandler , firstArg , d , jcc , objectHandedIn , rgbHandedIn , rgbArray})

% jbCancel = javax.swing.JButton() ;
jbCancel = handle(jcc.getCancelButton(), 'callbackproperties') ;
set(jbCancel,'ActionPerformedCallback', {@callbackHandler , firstArg , d , jcc , objectHandedIn , rgbHandedIn , rgbArray})

%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
% Display everything
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

figure(d)
refresh(d)
% Set the default return value to 0
selectedColor = 0 ;
% If RGB or object handle is passed in, set default return value to the
% specified color. This is used if an error occurs or the user hits
% Cancel.
if( rgbHandedIn || objectHandedIn ) % changed 12-30-04 Dave Oppenheim
    selectedColor = rgbArray ;        % See comment at line 283
end

waitfor(d);

if  isappdata( 0 , 'uisetcolorData' )
    selectedColor = getappdata( 0 , 'uisetcolorData' ) ;
    rmappdata( 0 , 'uisetcolorData' ) ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Discover the type of the first arg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function getArg1Type()

        if( ishghandle( firstArg ) & ( 1 == length( firstArg ) ) )
            arg1IsHgHandle = true ;
        elseif ( ischar( firstArg ) )
            arg1IsChar = true ;
        elseif( isnumeric( firstArg ) && isvector( firstArg ) )
            arg1IsRGB = true ;
        else
            arg1IsBad = true ;
        end

    end % end getArg1Type()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check the values in an array
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function rgbErr = checkRGB()
        rgbErr = false;

        % Transpose if necessary ( maybe user handed in 3 by 1 array )
        if( ~( 1 == size( rgbArray , 1) ) )
            rgbArray = rgbArray' ;
        end

        % Validate size and component values OF rgbArray

        if( ~( 1 == size( rgbArray , 1 ) ) | ~( 3 == size( rgbArray , 2 ) ) | ...
                ( 1.0 < rgbArray(1) ) | ( rgbArray(1) < 0.0 ) | ...
                ( 1.0 < rgbArray(2) ) | ( rgbArray(2) < 0.0 ) | ...
                ( 1.0 < rgbArray(3) ) | ( rgbArray(3) < 0.0 ) )

            rgbErr = true ;
        end

    end % end function checkRGB()

    function out = mydialog(varargin)

        out = [];
        try
            out = dialog(varargin{:}) ;
        catch ex
            rethrow(ex)
        end
    end % end myDialog

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The callback function for the chooser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function callbackHandler( obj , evd , firstArg , d , jcc , objectHandedIn , rgbHandedIn , rgbArg )

cmd = char(evd.getActionCommand());

switch(cmd)

    case 'dColorChooserOK'

        red   = jcc.getColor.getRed/255 ;
        green = jcc.getColor.getGreen/255 ;
        blue  = jcc.getColor.getBlue/255 ;

        % If an object was handed in (via its handle),
        % set the appropriate color-related property
        % to the value selected by the user.

        if( objectHandedIn )
            propertyName = char(jcc.getProperty()) ;

            z = [ red green blue ] ;

            if ~( strcmp( propertyName , 'None' ) )
                set( firstArg , propertyName ,z ) ;
            end

        end % end if( objectHandedIn )

        % Set the return value

        selectedColor = [ red green blue ] ;

        setappdata( 0 , 'uisetcolorData' , selectedColor ) ;

        % Cleanup
        jcc.cleanup();
        if ishandle(d)
            close(d)
        end

    case 'dColorChooserCancel'
        % If user hits Cancel, we use the default values that are set up
        % accordingly.
        % Cleanup
        jcc.cleanup();
        if ishandle(d)
            close(d)
        end

    otherwise
        error('MATLAB:uisetcolor_deprecated:UnimplementedOption',[cmd ' Unimplemented'])
end
end % end callbackHandler


