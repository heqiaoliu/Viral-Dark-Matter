% Audio and Video support.
%
% Audio input/output objects.
%   audioplayer   - Audio player object.
%   audiorecorder - Audio recorder object.
%
% Audio hardware drivers.
%   sound         - Play vector as sound.
%   soundsc       - Autoscale and play vector as sound.
%
% Audio file import and export.
%   aufinfo       - Return information about AU file.
%   auread        - Read NeXT/SUN (".au") sound file.
%   auwrite       - Write NeXT/SUN (".au") sound file.
%   wavfinfo      - Return information about WAV file.
%   wavread       - Read Microsoft WAVE (".wav") sound file.
%   wavwrite      - Write Microsoft WAVE (".wav") sound file.
%
% Video file import/export.
%   VideoReader   - Read video frames from a video file.
%   VideoWriter   - Write video frames to a video file.
%   mmfileinfo    - Return information for a multimedia file.
%   movie2avi     - Create AVI movie from MATLAB movie.
%   avifile       - Create a new AVI file.
%
% Utilities.
%   lin2mu        - Convert linear signal to mu-law encoding.
%   mu2lin        - Convert mu-law encoding to linear signal.
%
% Example audio data (MAT files).
%   chirp         - Frequency sweeps          (1.6 sec, 8192 Hz)
%   gong          - Gong                      (5.1 sec, 8192 Hz)
%   handel        - Hallelujah chorus         (8.9 sec, 8192 Hz)
%   laughter      - Laughter from a crowd     (6.4 sec, 8192 Hz)
%   splat         - Chirp followed by a splat (1.2 sec, 8192 Hz)
%   train         - Train whistle             (1.5 sec, 8192 Hz)
%
% See also IMAGESCI, IOFUN.

% Obsolete functions.
%   saxis         - Sound axis scaling.
%   mmreader      - Read video frames from a multimedia file.
%   wavplay       - Play sound using Windows audio output device.
%   wavrecord     - Record sound using Windows audio input device.
%   aviread       - Read movie (AVI) file.
%   aviinfo       - Return information about AVI file.
% 
% Utilities.
%   playsnd       - Implementation for SOUND.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/10 17:22:45 $
