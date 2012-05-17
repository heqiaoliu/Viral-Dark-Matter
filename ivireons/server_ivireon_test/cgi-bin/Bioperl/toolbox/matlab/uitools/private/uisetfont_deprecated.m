function [fontStruct] = uisetfont_deprecated(varargin)
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/10/24 19:20:03 $

%%%%%%%%%%%%%%%%
% Error Messages
%%%%%%%%%%%%%%%%

badNumArgsMessage  = 'Too many input arguments.' ;
badObjTypeMessage1 = 'Font selection is not supported for ';
badObjTypeMessage2 = ' objects, but only for axes, text, and uicontrols.' ;
% badHandleMessage   = 'Invalid object handle.';
badTitleLocMessage = 'title must be the last parameter passed to uisetfont.' ;
badParamMessage    = 'Invalid first parameter - please check usage' ;
% badTitleMessage    = 'Second argument (dialog title) must be a string.' ;
badFontsizeMessage = 'Font size must be an integer.'; %#ok
badFontSize = false;
maxArgs = 2 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check the number of args - must <= maxArgs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numArgs = nargin ;

if( numArgs > maxArgs )
    error('MATLAB:uisetfont:TooManyInputs',  badNumArgsMessage ) ;
end % end if( numArgs > maxArgs )

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
useNative = ~( isequal( 'MAC' , computer ) && usejava('awt') ) ;

% % If the root appdata is set and swing is available,
% % honor that overriding all other prefs.
% if isequal(0, getappdata(0,'UseNativeSystemDialogs')) && usejava('awt')
%     useNative = false ;
% end

if useNative

    try
        if nargin == 0
            [fontStruct] = native_uisetfont ;
        else
            [fontStruct] = native_uisetfont( varargin{:} ) ;
        end
    catch ex
        rethrow(ex)
    end

    return

end % end useNative

%%%%%%%%%%%%%%%%%
% General Globals
%%%%%%%%%%%%%%%%%

arg1 = '' ;
arg2 = '' ;  %#ok

jfc = '' ;

arg1Type           = '' ;
suppliedType       = '' ;
suppliedFieldNames = '' ;
title              = '' ;

numberAppropriateFields = 0 ;

badType    = 'badType';
structType = 'struct' ;
objectType = 'object' ;
% stringType = 'string' ;

allowedObjectTypes = { 'axes' ; 'text' ; 'uicontrol' } ;

structFields = { 'FontName' ;...
    'FontUnits' ; ...
    'FontSize' ; ...
    'FontWeight' ; ...
    'FontAngle' } ;

%%%%%%%
% Flags
%%%%%%%

arg1OK             = false ;
% titleFound         = false ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default font values - used when there are 0 args
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fontStruct.FontName   = 'Arial' ;
fontStruct.FontUnits  = 'points' ;
fontStruct.FontSize   = 10 ;
fontStruct.FontWeight = 'normal' ;
fontStruct.FontAngle  = 'normal' ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The dialog that will hold our chooser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d = '' ;  %#ok

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the case of exactly one arg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( numArgs == 1 )

    arg1 = varargin{1} ;

    % Check out arg1 - it should be a struct having some specific
    % fields or a handle to an object of type text , uicontrol or axes.
    % FOR COMPATIBILITY,
    % It might also be a string we are going to use as a title.

    if( ischar( arg1 ) && isvector( arg1 ) )

        % Save dialog title

        if( 1 == size( arg1 , 1 ) )
            title = char( arg1 ) ;
        else
            title = char( arg1' ) ;
        end

        % Handle the case where arg1 is a struct or handle here

    elseif isstruct(arg1) || (isscalar(arg1) && ishandle(arg1))

        % Process arg1 - return if there's an error

        checkArg1() ;

        % Return if there's an error with an object (illegal type)
        % No errors are returned if a struct has been handed in

        if( ~arg1OK || ( strcmp( suppliedType , badType ) ) )

            if (badFontSize)
                error('MATLAB:uisetfont:InvalidParameter', badFontsizeMessage);
            else
                if ~( strcmp( suppliedType , char('') ) )
                    error('MATLAB:uisetfont:InvalidObjectType',  [ badObjTypeMessage1 suppliedType badObjTypeMessage2 ] ) ;
                else
                    error('MATLAB:uisetfont:InvalidParameter',  badParamMessage );
                end
            end

        end % if( ~arg1OK & ( strcmp( arg1Type , objectType ) ) )

        % Handle error of param type here

    else

        error( badParamMessage ) ;

    end % end if/elseif/else

end % if( numArgs == 1 )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handle the case of exactly two args
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if( numArgs == 2 )

    arg1 = varargin{1} ;
    arg2 = varargin{2} ;

    if ~( isstruct( arg1 ) || ishandle( arg1 ) )
        error('MATLAB:uisetfont:InvalidParameter',  badParamMessage ) ;
    end

    % The only "legit" combination here is to have
    % the first arg be a struct or a handle and to
    % have the second arg be a string (title).

    if( ~( ischar( arg2 ) && isvector( arg2 ) ) )
        error('MATLAB:uisetfont:TitleMustBeLastInput',  badTitleLocMessage ) ;
    end % end if ...

    checkArg1() ;

    % Return if arg1 is a handle to a type we don't support

    if( ~arg1OK || ( strcmp( arg1Type , objectType ) ) )
        if ~( strcmp( suppliedType , char('') ) )
            error('MATLAB:uisetfont:InvalidObjectType', [ badObjTypeMessage1 suppliedType badObjTypeMessage2 ] ) ;
        else
            if (badFontSize)
                error('MATLAB:uisetfont:InvalidParameter', badFontsizeMessage);
            else
                error('MATLAB:uisetfont:InvalidParameter',  badParamMessage )
            end
        end
    end % if( ~arg1OK & ( strcmp( arg1Type , objectType ) ) )

    % Set op the title for in the dialog

    if( 1 == size( arg2 , 1 ) )
        title = char( arg2 ) ;
    else
        title = char( arg2' ) ;
    end

end % end if( numArgs == 2 )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OK - set up and display the dialog.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Dialog title is set later

d = mydialog( ...
    'Visible','off', ...
    'DockControls','off', ...
    'Color',get(0,'DefaultUicontrolBackgroundColor'), ...
    'Windowstyle','modal', ...
    'Resize','on' ...
    );

set( d , 'Position' ,  [232 246 345 390] ) ;

% Create a chooser (JPanel) and put it into the dialog - this is for resizing

sys = char( computer ) ;
lf = listfonts;
fonts = javaArray('java.lang.String', length(lf));
for i=1:length(lf) %#ok<FXUP>
    fonts(i) = java.lang.String(lf{i});
end

jfc = awtcreate('com.mathworks.hg.util.FontChooser', ...
    '[Ljava/lang/String;Ljava/lang/String;', ...
    fonts , sys );

[jfc,container] = javacomponent( jfc,[10 10 20 20],d );

% Use supplied title if one was given else use default

if ~( strcmp( '' , title ) )
    set( d , 'Name' , title ) ;
else
    set( d , 'Name' , char( jfc.getDefaultTitle() ) )
end

% Initialize the font chooser using the fontStruct struct

initFontChooser() ;

awtinvoke( java(jfc), 'setUpAttributes()');
awtinvoke( java(jfc), 'updatePreviewFont()');

% Add some control buttons

jbSet = handle( awtcreate('com.mathworks.mwswing.MJButton', 'Ljava/lang/String;', 'OK'), ...
    'callbackproperties' ) ;

jbCancel = handle( awtcreate('com.mathworks.mwswing.MJButton', 'Ljava/lang/String;', 'Cancel'), ...
    'callbackproperties' ) ;

buttonPanel = handle( awtcreate('com.mathworks.mwswing.MJPanel') ) ;

awtinvoke(java(buttonPanel), 'add(Ljava.awt.Component;)', java(jbSet)) ;
awtinvoke(java(buttonPanel), 'add(Ljava.awt.Component;)', java(jbCancel)) ;

awtinvoke( java(jfc), 'add(Ljava.awt.Component;Ljava.lang.Object;)',...
    java(buttonPanel), java.awt.BorderLayout.SOUTH ) ;

set(container,'Units','normalized','position',[0 0 1 1]);
set(jbSet,'ActionPerformedCallback', {@callbackHandler, jfc , d , arg1})
set(jbCancel,'ActionPerformedCallback', {@callbackHandler, jfc , d , arg1})

% Go

fontStruct = 0 ;

figure(d)
refresh(d)

waitfor(d);

if isappdata( 0 , 'uisetfontData' )

    fontStruct = getappdata( 0 , 'uisetfontData' ) ;

    rmappdata( 0 , 'uisetfontData' ) ;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error check the first arg.  As a side effect, if
% arg1 is a struct, return the set of field names
% matching the "font-related set" ( 'FontName', 'FontSize', ... )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function checkArg1()

        % Cover the case where arg1 is a handle

        if( isscalar(arg1) && ishandle( arg1 ) )

            suppliedType = '' ;

            try
                %arg1Type = objectType ;
                suppliedType = get( arg1 , 'Type' ) ;

            catch
                arg1OK = false ;
                suppliedType = badType ;
                return ;
            end

            % Check type of supplied obj against allowed obj types (axes,text,...)

            len =  size( allowedObjectTypes , 1 ) ;

            for i = 1 : len %#ok<FXUP>

                if( strcmp( allowedObjectTypes( i , 1 ) , suppliedType ) )
                    arg1OK   = true ;
                    return ;
                end % end if( strcmp( allowedObjectTypes( i , 1 ) , arg1 ) )

            end % end for i = 1 : len

            % Bad object type

            arg1OK = false ;
            return ;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % End processing for handle
            % Do the case where arg1 is a struct
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        elseif( isstruct( arg1 ) )

            arg1Type = structType ;

            % Check the structure to see if has font-related fields

            len = size(  structFields , 1 );
            numberAppropriateFields = 0 ;

            for j = 1 : len

                % Get next font-related field name

                fieldName = char( structFields( j , 1 ) ) ;

                % If arg1 has a field of this name, store the field name

                if ( isfield( arg1 , fieldName ) )
                    if (strcmp(fieldName, 'FontSize'))
                        fieldVal = arg1.(fieldName);

                        % FontSize should be a number.
                        if ~isnumeric(fieldVal)
                            badFontSize = true;
                            arg1OK = false;
                            break;
                        end
                    end
                    arg1OK = true ;
                    numberAppropriateFields = numberAppropriateFields + 1 ;
                    suppliedFieldNames{ 1 , numberAppropriateFields } = char( fieldName ) ; %#ok<AGROW>
                end % end if j = 1 : size( structFields , 1 )

            end % end for

        else
            arg1OK = false ;

        end % end if/else

    end % end function checkArg1()


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the FontChooser with values given by the user or defaults
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function initFontChooser()

        % If arg1 is a handle to an object, get the font values of the object

        if( ishandle( arg1 ) )

            %%%%%%%%%%%%%%%%%%%%??????? should be char( get( arg1 , 'FontName' )
            %%%%%%%%%%%%%%%%%%%%)???????????????????????????????????????????????

            fontStruct.FontName   = get( arg1 , 'FontName' ) ;
            fontStruct.FontUnits  = get( arg1 , 'FontUnits' ) ;
            fontStruct.FontSize   = get( arg1 , 'FontSize' ) ;
            fontStruct.FontWeight = get( arg1 , 'FontWeight' ) ;
            fontStruct.FontAngle  = get( arg1 , 'FontAngle' ) ;

        end % end if( ishandle( arg1 ) )

        % If arg1 is a struct, use it's font-related field values

        if( isstruct( arg1 ) )

            if( numberAppropriateFields > 0 )

                % Get vals and set fields of the fontStruct structure

                for i = 1 : numberAppropriateFields %#ok<FXUP>
                    fieldName = char( suppliedFieldNames( 1 , i )) ;
                    val = arg1.(fieldName);
                    fontStruct.(fieldName) = val ;
                end % for i = 1 : numberAppropriateFields

            end % if( numberAppropriateFields > 0 )

        end % if( isStruct( arg1 ) )

        %disp( fontStruct ) ;

        % Now actually set the selections in the FileChooser
        awtinvoke(java(jfc), 'selectFontName(Ljava/lang/String;)', fontStruct.('FontName')) ;
        awtinvoke(java(jfc), 'selectFontSize(I)', fontStruct.('FontSize' )) ;

        %        fontAngle = '' ;
        %        fontWeight = '' ;

        fw = fontStruct.('FontWeight') ;

        fontStyle = 'Regular' ;

        fa = fontStruct.('FontAngle');

        if( strcmpi( fw , 'bold' ) )

            if( strcmpi( fa , 'italic' ) )
                fontStyle = 'Bold Italic';
            else
                fontStyle = 'Bold';
            end

        else

            if( strcmpi( fa , 'italic' ) )
                fontStyle = 'Italic';
            end

        end % end if( strcmp( fw , 'bold' )

        awtinvoke(java(jfc), 'selectFontStyle(Ljava/lang/String;)', char(fontStyle) ) ;

        jfc.addSampleTextActionListeners();
        awtinvoke( java(jfc), 'setUpAttributes()');
        awtinvoke( java(jfc), 'updatePreviewFont()');

    end % end function initFontChooser

    function out = mydialog(varargin)

        out = [];
        try
            out = dialog(varargin{:}) ;
        catch ex
            rethrow(ex)
        end
    end % end myDialog

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The callback from the chooser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function callbackHandler( obj , evd , jfc , d , arg1 )  %#ok

cmd = char(evd.getActionCommand());

switch(cmd)
    case 'Cancel'
        if ishandle(d)
            close(d)
        end
    case 'OK'
        % Set up the output variable

        fontStruct.FontName   = char( jfc.getFontName() ) ;
        fontStruct.FontSize   = jfc.getFontSize() ;
        fontStruct.FontWeight = char( jfc.getFontWeight() ) ;
        fontStruct.FontAngle  = char( jfc.getFontAngle() ) ;

        setappdata( 0 , 'uisetfontData' , fontStruct ) ;

        % If necessary, set the input obj's properties

        if( isscalar(arg1) &&  ishandle( arg1 ) )
            set( arg1 , 'FontName' , char( jfc.getFontName() ) ) ;
            set( arg1 , 'FontSize' , jfc.getFontSize() ) ;
            set( arg1 , 'FontWeight' , char( jfc.getFontWeight() ) ) ;
            set( arg1 , 'FontAngle' , char( jfc.getFontAngle() ) ) ;
        end % end if( ishandle( arg1 ) )

        if ishandle(d)
            close(d)
        end

    otherwise
        disp([cmd ' Unimplemented'])

end % end switch

end % end callbackHandler
