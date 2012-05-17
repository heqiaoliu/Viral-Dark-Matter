function fileInfo = mmfileinfo(filename)
%MMFILEINFO Information about a multimedia file.
%
%   INFO = MMFILEINFO(FILENAME) returns a structure whose fields contain
%   information about FILENAME's audio and/or video data.  FILENAME
%   is a string that specifies the name of the multimedia file.  
%
%   The set of fields for the INFO structure are:
%
%      Filename - A string, indicating the name of the file.
%
%      Path     - A string, indicating the absolute path to the file.
%
%      Duration - The length of the file in seconds.
%
%      Audio    - A structure whose fields contain information about the
%                 audio component of the file.
%      
%      Video    - A structure whose fields contain information about the
%                 video component of the file.
%
%   The set of fields for the Audio structure are:
%
%      Format           - A string, indicating the audio format.
%      
%      NumberOfChannels - The number of audio channels.
%      
%   The set of fields for the Video structure are:
%    
%      Format          - A string, indicating the video format.
%           
%      Height          - The height of the video frame.
%           
%      Width           - The width of the video frame.
%
%   See also AUDIOVIDEO.

% JCS
% Copyright 1984-2008 The MathWorks, Inc.
% $ Date: $ $Revision: 1.1.8.9 $

% Check number of input arguments.
error(nargchk(1, 1, nargin, 'struct'));

% Currently, this function supports every platform but Solaris
if (strcmp(computer(),'SOL64'))
    error('MATLAB:mmfileinfo:invalidPlatform','This function is not available for use on Solaris systems.');
end

% Make sure that only characters are being passed in.
if ( isempty(filename) || ~ischar(filename))
    error('MATLAB:mmfileinfo:mustBeString', 'FILENAME must be a non-empty string.');
end

try
    filename = mmreader.getFullPathName(filename);

    if ispc
        % Call the MEX-function which gets all of the information about the
        % file.
        [filepath, filename, fileext] = fileparts(filename);
        fileInfo = WinMMFileInfo(filepath, [filename fileext]);
    else 
        fileInfo = MMReaderMMFileInfo(filename);
    end

catch exception
    throw(exception);
end

end

function fileInfo = MMReaderMMFileInfo(filename)


% save the last warning message/id
[lastWarnMsg,lastWarnID] = lastwarn;

% turn off the matlab:mmreader:unknownNumFrames warning
warnState=warning('off', 'matlab:mmreader:unknownNumFrames'); 

% open this file using MMReader
obj = mmreader( filename );

% restore warning state
warning( warnState );
lastwarn( lastWarnMsg, lastWarnID );


fileInfo.Filename = obj.Name;
fileInfo.Path = obj.Path;
fileInfo.Duration = obj.Duration;

if hasAudio(obj)
    fileInfo.Audio.Format = obj.AudioCompression; % unsupported by mmreader on Windows (for use in mmfileinfo only)
    fileInfo.Audio.NumberOfChannels = obj.NumberOfAudioChannels;    % unsupported by mmreader on Windows (for use in mmfileinfo only)
else
    fileInfo.Audio.Format = '';
    fileInfo.Audio.NumberOfChannels = [];
end

if hasVideo(obj)
    fileInfo.Video.Format = obj.VideoCompression; % unsupported by mmreader on Windows (for use in mmfileinfo only)
    fileInfo.Video.Height = obj.Height;
    fileInfo.Video.Width = obj.Width;
else
    fileInfo.Video.Format = '';
    fileInfo.Video.Height = [];
    fileInfo.Video.Width = [];
end

end
