function play(obj, varargin)
%PLAY Plays audio samples in audioplayer object.
%
%    PLAY(OBJ) plays the audio samples from the beginning.
%
%    PLAY(OBJ, START) plays the audio samples from the START sample.
%
%    PLAY(OBJ, [START STOP]) plays the audio samples from the START sample
%    until the STOP sample.
%
%    Use the PLAYBLOCKING method for synchronous playback.
%
%    Example:  Load snippet of Handel's Hallelujah Chorus and play back 
%              only the first three seconds.
%
%       load handel;
%       p = audioplayer(y, Fs); 
%       play(p, [1 (get(p, 'SampleRate') * 3)]);
%
%    See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET, AUDIOPLAYER/PLAYBLOCKING.

%    JCS
%    Copyright 2003-2004 The MathWorks, Inc. 
%    $Revision: 1.1.6.3 $  $Date: 2009/07/16 19:17:19 $

% Error checking.
if ~isa(obj, 'audioplayer')
     error('MATLAB:audioplayer:noAudioplayerObj', ...
           audioplayererror('MATLAB:audioplayer:noAudioplayerObj'));
end

error(nargchk(1, 2, nargin, 'struct'));

if (isa(obj.internalObj, 'char'))
    warning('MATLAB:audioplayer:noAudioOutputDevice', ['Unable to play audio: ', obj.internalObj]);
    return;
end

if isempty(varargin)
    play(obj.internalObj);
else
    play(obj.internalObj, double(varargin{:}));
end
