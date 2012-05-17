function y = wavrecord(varargin)
%WAVRECORD Record sound using Windows audio input device.
%   WAVRECORD will be removed in a future release.  Use AUDIORECORDER
%   instead.
%
%   Y = WAVRECORD(N,FS,CH) records N audio samples at FS Hertz from
%   CH number of input channels from the Windows WAVE audio device.
%   Standard audio rates are 8000, 11025, 22050, and 44100 Hz.
%   CH can be 1 or 2 (mono or stereo).  Samples are returned in a matrix
%   of size N-by-CH.  If not specified, FS=11025 Hz, and CH=1.
%
%   Y = WAVRECORD(..., DTYPE) uses the data type specified by the string
%   DTYPE to record the sound. The string values for DTYPE are listed in
%   the following table along with corresponding bits per sample and
%   acceptable data ranges for Y.
%
%       DTYPE      Bits/sample  Y's Data range
%       --------   -----------  ---------------------
%       'double'       16         -1.0 <= Y < +1.0
%       'single'       16         -1.0 <= Y < +1.0
%       'int16'        16       -32768 <= Y <= +32767
%       'uint8'         8            0 <= Y <= 255
%
%   This function is for use only with 32-bit Windows machines. To record
%   audio data from audio input devices on other platforms use AUDIORECORDER. 
%
%   Example: Record and play back 5 seconds of 16-bit audio
%            sampled at 11.025 kHz
%       Fs = 11025;
%       y  = wavrecord(5*Fs, Fs, 'int16');
%       wavplay(y, Fs);
%
%   See also AUDIORECORDER, WAVREAD, WAVWRITE.

%   Author: D. Orofino
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/10 17:22:49 $

if ~ispc
   error('matlab:wavrecord:nonWinMachine', ...
       'WAVRECORD is only for use with Windows machines.');
end

[s,msgstruct] = parse_args(varargin{:});
error(msgstruct);

% Be sure to transpose data once it has been received:
y = recsnd(s.n, s.fs, s.bits, s.ch, s.dtype_id).';

return

% ------------------------------------------------
function [s,msgstruct] = parse_args(varargin)
% PARSE_ARGS

s = [];
msgstruct = nargchk(1,4,nargin,'struct');
if ~isempty(msgstruct), return; end

% dtype_id: 0=double, 1=int, 2-single
if ischar(varargin{end}),
   % trailing string arg is the data type: index 1='double' or 2='int'
   switch lower(varargin{end})
   case 'double'
      dtype_id = 0;
      bits     = 16;
   case 'single'
      dtype_id = 2;
      bits     = 16;
   case 'int16'
      dtype_id = 1;
      bits     = 16;
   case 'uint8'
      dtype_id = 1;
      bits     = 8;
   otherwise
      msgstruct = struct; 
      msgstruct.message = 'DTYPE must be ''double'', ''single'', ''int16'', or ''uint8''.';
      msgstruct.identifier = 'MATLAB:wavrecord:invaliddtype';
      return
   end
   varargin(end) = [];  % remove dtype arg from list
else
   % Default: double precision, 16-bit samples
   dtype_id = 0;  % 'double'
   bits     = 16;
end

nargs = length(varargin);
if nargs < 3, ch = 1;
else          ch = varargin{3};
end
if nargs < 2, fs = 11025;
else          fs = varargin{2};
end
n = varargin{1};

s.n        = n;        % # samples
s.fs       = fs;       % sample rate, Hz
s.ch       = ch;       % # channels
s.dtype_id = dtype_id; % 0=double, 1=int
s.bits     = bits;     % # bits/sample

% [EOF] wavrecord.m
