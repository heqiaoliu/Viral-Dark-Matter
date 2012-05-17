classdef AbstractFileHandler < uiscopes.AbstractDataHandler
    %ABSTRACTFILEHANDLER Define the AbstractFileHandler class.

    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.11 $  $Date: 2009/10/07 14:23:24 $

    properties
        FileName = '';
        FilterSpec = {'*.avi','Multimedia files (*.avi)'; ...
                    '*.*',  'All Files (*.*)'};
    end

    methods
        function this = AbstractFileHandler(srcObj)
            this@uiscopes.AbstractDataHandler(srcObj);
        end
        
        % -----------------------------------------------------------------
        function args = commandLineArgs(this)
            %COMMANDLINEARGS Return command-line arguments to
            %   instantiate this DataConnectFile connection.

            % Get actual playback rate, not "source rate"
            playbackRate = this.Data.FrameRate;

            % Filename as one arg passed to command-line
            % Pass frame rate as 2nd command-line arg
            args = {this.Source.Name, playbackRate};
        end

        % -----------------------------------------------------------------
        function varName = getExportFrameName(this)
            %GETEXPORTFRAMENAME Returns string name for use when exporting
            %   frame of video data, specific to data files.

            % This must be a valid MATLAB variable name
            %
            % Construct name including file name and frame number
            %   filename_###
            % Do not include file extension, as "." is not a valid
            % MATLAB variable name

            frameNum = this.Source.Controls.CurrentFrame;
            [p,fname] = fileparts(this.Source.NameShort);
            varName = sprintf('%s_%d', fname, frameNum);

            varName = uiservices.generateVariableName(varName);
        end

        % -----------------------------------------------------------------
        function openFile(this,hSource,newFileName,fps)
            %OPENFILE

            if nargin < 3
                % Bring up a file browser to same path it was last opened
                % returns true if cancel not pressed
                hSource.FileBrowse.InitialDir = hSource.LastConnectFileOpened;
                hSource.FileBrowse.FilterSpec = this.FilterSpec;
                % ******** TO-DO: g551941 ******** START
                % Using a filter list adds support to additional
                % file types in MPlay. MMREADER has limitations
                % handling a few of them on specific platforms.
                % We decided not to use this filter list in R2010a 
                % until such limitations get handled.
                
                % Get the list of file formats mmreader can read
                % fileFormats = mmreader.getFileFormats();
                % Create a filter list for our file open dialog
                % filterSpec = fileFormats.getFilterSpec();
                % hSource.FileBrowse.FilterSpec = filterSpec;
                % this.FilterSpec = filterSpec;
                % ******** TO-DO: g551941 ******** END
                cancelPressed = ~select(hSource.FileBrowse);
                if cancelPressed
                    this.ErrorStatus = 'cancel';
                    return
                end
                newFileName = fullfile(hSource.FileBrowse);
            end

            this.FileName = newFileName;

            try
                % Could fail; might not be a string, etc
                % Sets .ErrorStatus accordingly.
                reopen(this, newFileName);

            catch e
                % Unknown error condition occurred
                this.ErrorStatus = 'failure';
                this.ErrorMsg = uiservices.cleanErrorMessage(e);
            end

            % Make nice error messages
            %
            switch this.ErrorStatus
                case 'success'
                    if nargin > 3
                        if fps > 100
                             fps = 100;
                             uiscopes.errorHandler({ ...
                                 sprintf('Frame rate cannot exceed 100 frames/sec.'), ...
                                 'Setting rate to maximum.'});
                        end
                        this.Data.FrameRate = fps;  % otherwise, assume default
                    end
                case 'failure'

                    % Remove backtrace info (first line of error string)
                    errMsg = this.ErrorMsg;
                    % Get file name (no path, just for brevity)
                    [p,n,i]=fileparts(this.FileName);
                    fname = [n i];
                    % Put it all together
                    this.ErrorMsg = sprintf('%s\n%s\n\n%s\n%s', ...
                        'Error occurred while attempting to read file:', ...
                        fname, ...
                        'Details of error:', ...
                        errMsg);
            end
        end

        % -----------------------------------------------------------------
        function reopen(this, newFileName)
            this.ErrorStatus = 'success';
        end

        % -----------------------------------------------------------------
        function reconnectData(this)
            %RECONNECTDATA Re-opens a closed video stream connection.

            % For DataConnectFile, reconnecting is reopening
            reopen(this);

        end
    end
    methods (Abstract)
        disconnectData(this)
    end
end
