classdef VideoFileHandler < scopeextensions.AbstractFileHandler
    %VIDEOFILEHANDLER Define the VideoFileHandler class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.11 $  $Date: 2010/03/08 21:43:41 $
    
    properties (Access = protected)
        
        StreamHandle = [];
        
        % reader: which set of functions are we using for reading files?
        %
        %   enumeration: 0=vipblks, 1=matlab
        Reader = 0;
    end
    
    methods
        function this = VideoFileHandler(hSource, varargin)
            %VIDEOFILEHANDLER Construct a VIDEOFILEHANDLER object
            
            this@scopeextensions.AbstractFileHandler(hSource);
            this.Data = scopeextensions.VideoData;
        end
        
        % -----------------------------------------------------------------
        function disconnectData(this)
            %disconnectData Closes just the video data stream,
            % leaving buttons/widgets as-is.
            
            if ~isempty(this.StreamHandle)
                if this.Reader ~= 2
                    % Close file stream
                    try
                        fclose(this.StreamHandle);
                    catch ME %#ok
                        % NO OP, it is already closed.
                    end
                end
                this.StreamHandle = [];
            end
        end
        
        % -----------------------------------------------------------------
        function y = getFrameData(this,idx)
            %GETFRAMEDATA Returns idx'th video frame from a random-access data source
            
            if nargin<2
                % Get data for current frame
                % Support export call which doesn't pass idx arg
                idx = this.Source.Controls.CurrentFrame; % .lastVideoFrameReadIdx
            end
            switch this.Reader
                case 0
                    % VIPBLKS
                    this.UserData = vipaviread(this.UserData,idx);
                    y = this.UserData.lastFrame;
                case 1
                    % MATLAB
                    
                    % AVIREAD isnow deprecated and warns upon use.  Turn
                    % off this warning.
                    warnState = warning('OFF', 'MATLAB:aviread:FunctionToBeRemoved');
                    cleaner = onCleanup(@()warning(warnState));
                    
                    x = aviread(this.FileName,idx);  % Read frame as a movie structure
                    y = x.cdata;                  % Peel off the video data
                case 2
                    y = read(this.StreamHandle,idx);
            end
        end
        
        % -----------------------------------------------------------------
        function reopen(this,fName)
            %REOPEN Reopen and reuse existing object
            
            % Set DataConnectFile properties
            % during object construction time
            
            if nargin < 2
                fName = this.FileName;
            end
            
            % Read multimedia file info
            %
            % Currently, we only recognize '.avi' extension
            %
            % Also, if we don't recognize the extension, we attempt to load the file as
            % if it was an AVI file.
            %
            try
                % Use mmreader
                full_name = use_mmrinfo_fcns(this, fName);
            catch e %#ok
                % g278318: We will first try to use MMREADER
                % on all platforms. However, if that fails
                % we will revert to using AVIREAD/VIPAVIREAD
                % until MMREADER issues get resolved.
                try
                    % Try to use VIP-specific reader, but it
                    % does not support compressed data stream
                    % currently
                    full_name = use_vipinfo_fcns(this, fName);
                catch e %#ok
                    % Try to use MATLAB reader - slower, but it
                    % handles some types of compression
                    full_name = use_aviinfo_fcns(this, fName);
                end
            end
            
            % Install full name, as identified by file readers
            % (completes file extension, etc)
            if strcmpi(this.ErrorStatus, 'success')
                install_source_name(this, full_name);
            end
        end
    end
    
    methods (Access = private)
        function full_name = use_mmrinfo_fcns(this, fName)
            
            try
                mmrobj = mmreader(fName);
                if ~isempty(this.StreamHandle)
                    delete(this.StreamHandle);
                    this.StreamHandle = [];
                end
                this.StreamHandle = mmrobj;
                this.Data.FrameRate  = get(mmrobj, 'FrameRate');
                this.Data.Dimensions = [get(mmrobj, 'Height') get(mmrobj, 'Width')];
                this.Data.NumFrames  = get(mmrobj, 'NumberOfFrames');
                this.Data.ColorSpace = 'rgb';
                
                % Set data type of video frames
                %
                this.Data.DataType = 'uint8';  % 'uint8', etc
                this.Data.FrameData = read(mmrobj,1);
                
                % Get colormap
                this.Data.ColorMap = [];
                
                % Get full file name as read by the read function
                % This heads off problems when the filename was specified without
                % an extension, and an MATLAB file exists with the same name.
                full_name = fullfile(mmrobj.Path, mmrobj.Name);
                
                % Success - indicate VIP file reader infrastructure
                this.Reader = 2;
                this.ErrorStatus = 'success';
            catch e
                this.ErrorMsg = uiservices.cleanErrorMessage(e);
                this.ErrorStatus='failure';
                throw(e);
            end
        end
        
        % -----------------------------------------------------------------
        function full_name = use_vipinfo_fcns(this, fName)
            
            % Must preset in case of error when read fcn is called
            
            % Caution:
            %  if a file is already opened, and a subsequent request comes in to
            %  (re)open the file, this fulfills the request by returning the SAME
            %  fid to the caller.
            all_fid = fopen('all'); % xxx
            fileInfo = vipaviread([],fName);
            duplicate_fid = any(all_fid == fileInfo.fid);
            
            % We will need the fileInfo during subsequent reads,
            % so cache a copy of this structure:
            this.UserData = fileInfo;
            
            switch fileInfo.aviInfo.VideoFrameHeader.ImageType
                case 'truecolor'
                    this.Data.ColorSpace = 'rgb';
                otherwise
                    this.Data.ColorSpace = 'intensity';
            end
            this.Data.FrameRate  = fileInfo.aviInfo.MainHeader.FramesPerSecond;
            this.Data.Dimensions = [fileInfo.aviInfo.MainHeader.Height ...
                fileInfo.aviInfo.MainHeader.Width];
            this.Data.NumFrames  = fileInfo.aviInfo.MainHeader.TotalFrames;
            
            % Get data type of video frames
            %
            temp = vipaviread(fileInfo,1);  % get 1st frame
            this.Data.DataType = class(temp.lastFrame);  % 'uint8', etc
            this.Data.FrameData = temp;
            
            % Get colormap
            this.Data.ColorMap = temp.colormap;
            
            % Store file FID:
            if duplicate_fid,
                % when close method invoked, don't allow it to close file
                % This fixes the problem where multiple players have the
                % same movie loaded, and the players close their window.
                % Without this fix, the file stream is closed, and all other
                % players stop working
                this.StreamHandle = [];
            else
                this.StreamHandle = fileInfo.fid;
            end
            
            % Get full file name as read by the read function
            % This heads off problems when the filename was specified without
            % an extension, and an MATLAB file exists with the same name.
            full_name = fileInfo.aviInfo.Filename;
            
            % Success - indicate VIP file reader infrastructure
            this.Reader = 0;
            this.ErrorStatus = 'success';
        end
        
        % -----------------------------------------------------------------
        function full_name = use_aviinfo_fcns(this, fName)
            
            % AVIINFO is now deprecated, and warns upon use.  Turn off this warning.
            aviinfoWarnState = warning('OFF', 'MATLAB:aviinfo:FunctionToBeRemoved');
            aviinfoWarnCleaner = onCleanup(@()warning(aviinfoWarnState));
            
            % AVIREAD is now deprecated, and warns upon use.  Turn off this warning.
            avireadWarnState = warning('OFF', 'MATLAB:aviread:FunctionToBeRemoved');
            avireadWarnCleaner = onCleanup(@()warning(avireadWarnState));
            
            % Must preset in case of error when read fcn is called
            full_name = '';
            
            try
                fileInfo = aviinfo(fName);
            catch e
                this.ErrorMsg = uiservices.cleanErrorMessage(e);
                this.ErrorStatus='failure';
                return
            end
            switch fileInfo.ImageType
                case 'truecolor'
                    this.Data.ColorSpace = 'rgb';
                case {'indexed','grayscale'}
                    this.Data.ColorSpace = 'intensity';
                otherwise
                    this.ErrorMsg = sprintf('Unsupported AVI image type "%s"', ...
                        fileInfo.ImageType);
                    this.ErrorStatus = 'failure';
                    return
            end
            this.Data.FrameRate = fileInfo.FramesPerSecond;
            this.Data.Dimensions = [fileInfo.Height fileInfo.Width];
            this.Data.NumFrames = fileInfo.NumFrames;
            
            % Get data type of video frames
            %
            % Need to actually read a frame to determine this
            temp = aviread(fName,1);
            this.Data.DataType = class(temp(1).cdata);  % 'uint8', etc
            
            % Get colormap
            this.Data.ColorMap = temp(1).colormap;
            
            % Store file FID
            % Note: for this reader, there is no cached file ID,
            %       (it's a slow reader), so store an empty:
            this.StreamHandle = [];
            
            % Get full file name as read by the read function
            % This heads off problems when the filename was specified without
            % an extension, and an MATLAB file exists with the same name.
            full_name = fName;
            
            % Success - indicate MATLAB file reader infrastructure
            this.Reader = 1;
            this.ErrorStatus = 'success';
        end
        
        % -----------------------------------------------------------------
        function install_source_name(this, fName)
            % Fill in the following properties:
            %  Source.Name, Source.NameShort
            
            % Get full path to specified file
            % Path could have been fully specified, or could have been a filename
            % only that is on the MATLAB path.  If it's not on the MATLAB path,
            % "which" returns an empty string
            full_file_name = which(fName);
            if isempty(full_file_name),
                % File was not on the MATLAB path, or original file name
                % was truly an empty string.  Use original name:
                full_file_name = this.FileName;
            end
            
            % Construct long source name for title bar option
            this.Source.Name = full_file_name; % source is a file
            % Construct shortened source name for title bar option
            [~,n,e] = fileparts(full_file_name);
            this.Source.NameShort = [n e];
            
        end
    end
end
