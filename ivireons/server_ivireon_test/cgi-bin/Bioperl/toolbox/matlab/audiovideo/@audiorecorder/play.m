function player = play(obj, varargin)
%PLAY Plays recorded audio samples in audiorecorder object.
%
%    P = PLAY(OBJ) plays the recorded audio samples at the beginning and
%    returns an audioplayer object.
%
%    P = PLAY(OBJ, START) plays the audio samples from the START sample and
%    returns an audioplayer object.
%
%    P = PLAY(OBJ, [START STOP]) plays the audio samples from the START
%    sample until the STOP sample and returns an audioplayer object.
%
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%             AUDIORECORDER/SET, AUDIORECORDER/RECORD.

%    JCS
%    Copyright 2003-2006 The MathWorks, Inc. 
%    $Revision: 1.1.6.4 $  $Date: 2006/06/02 20:06:34 $

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin, 'struct'));

player = audioplayer(obj);
play(player, varargin{:})
