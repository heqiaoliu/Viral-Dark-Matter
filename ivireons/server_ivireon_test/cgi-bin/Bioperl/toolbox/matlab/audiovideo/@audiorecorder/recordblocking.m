function recordblocking(obj, time)
%RECORDBLOCKING Synchronous recording from audio device.
%
%    RECORDBLOCKING(OBJ, T) records for length of time, T, in seconds;
%                           does not return until recording is finished.
%
%    Use the RECORD method for asynchronous recording.
%
%    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
%              16 bits, and one channel.  Speak into the microphone, then 
%              stop the recording.  Play back what you've recorded so far.
% 
%       r = audiorecorder(22050, 16, 1);
%       recordblocking(r, 5);     % speak into microphone...
%       p = play(r);   % listen to complete recording
%
%    See also AUDIORECORDER, METHODS, AUDIORECORDER/PAUSE, 
%             AUDIORECORDER/STOP, AUDIORECORDER/RECORD.
%             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.

%    Copyright 2003-2006 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2006/06/02 20:06:42 $

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(2, 2, nargin, 'struct'));

if (~isnumeric(time) || (numel(time) > 1 ))
    error('MATLAB:audiorecorder:invalidTime', ...
        audiorecordererror('MATLAB:audiorecorder:invalidTime'));
end

recordblocking(obj.internalObj, time);