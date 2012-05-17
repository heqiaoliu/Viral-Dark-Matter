function playblocking(obj, varargin)
%PLAYBLOCKING Synchronous playback of audio samples in audioplayer object.
%
%    PLAYBLOCKING(OBJ) plays from beginning; does not return until 
%                      playback completes.
%
%    PLAYBLOCKING(OBJ, START) plays from START sample; does not return until
%                      playback completes.
%
%    PLAYBLOCKING(OBJ, [START STOP]) plays from START sample until STOP sample;
%                      does not return until playback completes.
%
%    Use the PLAY method for asynchronous playback.
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PLAY.

%    JCS
%    Copyright 2003-2006 The MathWorks, Inc. 
%    $Revision: 1.1.6.4 $  $Date: 2009/07/16 19:17:20 $

% Error checking.
if ~isa(obj, 'audioplayer')
     error('MATLAB:audioplayer:noAudioplayerObj', ...
           audioplayererror('MATLAB:audioplayer:noAudioplayerObj'));
end

error(nargchk(1, 2, nargin, 'struct'));

if ( (nargin == 2) && (~isnumeric(varargin{1}) || (numel(varargin{1}) > 2 )) )
    error('MATLAB:audioplayer:invalidIndex', ...
        audioplayererror('MATLAB:audioplayer:invalidIndex'));
end

if (isa(obj.internalObj, 'char'))
    warning('MATLAB:audioplayer:noAudioOutputDevice', ['Unable to play audio: ', obj.internalObj]);
    return;
end

playblocking(obj.internalObj, varargin{:});
