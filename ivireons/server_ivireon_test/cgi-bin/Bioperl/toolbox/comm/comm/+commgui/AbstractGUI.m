classdef AbstractGUI < hgsetget
    %AbstractGUI Define the AbstractGUI class
    %
    %   Warning: This undocumented function may be removed in a future release.
    
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2009/05/23 07:48:11 $
    
    %===========================================================================
    % Protected/Transient properties
    properties (Access = protected, Transient)
        Parent = -1;            % Parent ui object handle
    end
    
    %===========================================================================
    % Protected properties
    properties (Access = protected)
        WidgetHandles           % Structure of widget handles
        Rendered = false;       % Flag to determine if the scope face is
        % rendered
        Exception = [];         % Stores the exception generated during
        % rendering a scope face.  This can be an
        % MException or a warning message (string).
    end
    
    %===========================================================================
    % Abstract Public methods
    methods (Abstract)
        render(this)
        update(this)
        reset(this)
    end
    
    %===========================================================================
    % Public methods
    methods
        function unrender(this)
            % Remove the widgets from the parent figure
            
            if this.Rendered
                handles = this.WidgetHandles;
                fnames = fieldnames(handles);
                
                % Start deleting from the bottom to delete children before 
                % parents.
                for p=length(fnames):-1:1
                    hField = handles.(fnames{p});
                    if ishghandle(hField)
                        delete(hField);
                    end
                end
                
                this.Rendered = 0;
            end
        end
        %-----------------------------------------------------------------------
        function setException(this, me)
            % Save the exception generated during rendering of the scope
            % face
            this.Exception = me;
        end
        %-----------------------------------------------------------------------
        function checkException(this)
            % Check if there was an exception during the rendering of the
            % scope face.  If there was one, then render an error/warning
            % message.
            
            % Get the exception
            me = this.Exception;
            if isempty(me)
                % Nothing to do
            else
                if ischar(me)
                    % This is a warning
                    commscope.notifyWarning(this.Parent, me);
                else
                    % This is an error
                    commscope.notifyError(this.Parent, me);
                end
                this.Exception = [];
            end
        end
        %-----------------------------------------------------------------------
        function flag = isRendered(this)
            flag = this.Rendered;
        end
        %-----------------------------------------------------------------------
        % Testability support functions
        function handles = getWidgetHandles(this)
            handles = this.WidgetHandles;
        end
    end
    
    %===========================================================================
    % Static methods
    methods (Static)
        function renderErrorDialog(exception, windowTitle)
            %RENDERERRORDIALOG Display an error message dialog box
            %   RENDERERRORDIALOG(H, EXCEPTION, WINDOWTITLE) displays the error message of
            %   the MException EXCEPTION in an error dialog with title WINDOWTITLE.
            %
            %   RENDERERRORDIALOG(H, MSG, WINDOWTITLE) displays the error message MSG in
            %   an error dialog with title WINDOWTITLE.  MSG must be a string.
            
            if ischar(exception)
                % An error message is passed by the GUI.  Display the message.
                msg = exception;
            else
                % An error was caught and the exception is passed by the GUI.  Display the
                % exception message.
                msg = cleanerrormsg(exception.message);
            end
            
            uiwait(errordlg(msg, windowTitle, 'modal'));
        end
        %-----------------------------------------------------------------------
        function renderWarningDialog(msg, windowTitle)
            %RENDERWARNINGDIALOG Render a warning dialog window.
            
            uiwait(warndlg(msg, windowTitle, 'modal'));
        end
    end
    
    %===========================================================================
    % Static/Hidden methods
    methods (Static, Hidden)
        function sz = baseGuiSizes
            %BASEGUISIZES Returns a structure of spacings and generic sizes
            
            pf = get(0,'screenpixelsperinch')/96;
            if isunix,
                pf = 1;
            end
            sz.pixf = pf;
            
            % Spacing
            sz.hel = 10*pf;     % horizontal spacing between elements and labels
            sz.hcc = 10*pf;     % horizontal spacing between control and control
            sz.vcc = 10*pf;     % vertical spacing between control and control
            sz.hcl = 10*pf;     % horizontal spacing between control and label
            sz.hcf = 10*pf;     % horizontal spacing between control and frame
            sz.vcf = 10*pf;     % vertical spacing between control and frame
            sz.hff = 10*pf;     % horizontal spacing between frame and frame/figure
            sz.vff = 15*pf;     % vertical spacing between frame and frame/figure
            
            % Sizes
            sz.tbh  = 15*pf;    % text box height
            sz.ebh  = 20*pf;    % edit box height
            sz.ebw  = 90*pf;    % edit box width
            sz.bh   = 25*pf;    % pushbutton height
            sz.bw   = 75*pf;    % pushbutton width
            sz.tw   = 100*pf;   % text width
            sz.toolbh  = 20*pf;    % toolbar height
            sz.tcs  = 2*pf;     % table column separation
            
            % Unix needs a bigger font size
            if ispc
                sz.fs = 8;
            else
                sz.fs = 10;
            end
            
            lang = get(0, 'language');
            if strncmpi(lang, 'ja', 2) && 0 % We need to turn this off until GUI is localized
                sz.fs = sz.fs+2; end
            
            sz.lh = (sz.fs+10)*pf;  % label height
            
            sz.MenuHeight = 21*pf;  % Height of the menu bar
            
            % Tweak factors
            sz.lblTweak = 3*pf;   % text ui tweak to vertically align popup labels
            sz.puwTweak = 22*pf;  % Extra width for popup
            sz.rbwTweak = 15*pf;  % Extra width for radio button
            sz.sbTweak = -(sz.vcc - 2*pf);  % Reduced vertical distance for slider bar labels
            sz.plTweak = 7*pf;    % Extra vertical distance to align the panel frame
            sz.ptTweak = 12*pf;   % Extra vertical distance at the top of the panel and its components
            sz.bwTweak = 5*pf;    % Width for a tight button
            sz.lbwTweak = 15*pf;  % The horizontal space occupied by listbox scroll bar
            sz.ptbTweak = 3*pf;   % space between panel and textbox inside
            sz.lbhTweak = 10*pf;  % Label height tweak
            sz.tbl1clTweak = 34*pf; % The width of the first column of the uitable that
            % needs to be subtracted from the table width to get the
            % available width
            sz.cbTweak = 20*pf;   % Space occupied by the checkbox except text
        end
        %-----------------------------------------------------------------------
        function sz = setFontParams(sz)
            %SETFONTPARAMS Set the font size and name
            %   Set the default uicontrol font size and name to the ones defined by the SZ
            %   structure.  Also, store the system default so that they can be restored once
            %   we are done rendering.
            
            % Set up the defaults for GUI sizes
            sz.origFontSize = get(0, 'defaultuicontrolfontsize');
            set(0, 'defaultuicontrolfontsize', sz.fs');
            if ~ispc
                sz.origFontName = get(0, 'defaultuicontrolfontname');
                set(0, 'defaultuicontrolfontname', 'Helvetica');
            end
        end
        %-----------------------------------------------------------------------
        function restoreFontParams(sz)
            %RESTOREFONTPARAMS Restore the system font size and name
            %   Restore the default uicontrol font size and name to the ones stored in the
            %   SZ structure.
            
            % Restore the defaults.  These were set to local values in setFontParams
            set(0, 'defaultuicontrolfontsize', sz.origFontSize);
            if ~ispc
                set(0, 'defaultuicontrolfontname', sz.origFontName);
            end
        end
    end
    
end
