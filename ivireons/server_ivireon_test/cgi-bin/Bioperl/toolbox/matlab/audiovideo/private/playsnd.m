function playsnd(y,fs,bits)
%PLAYSND Implementation for SOUND
%   PLAYSND(Y,FS,BITS)

%   IF a MEX file version exists, it is called; otherwise, this file is
%   used when a MEX file is not available for the platform.  Sound is
%   simply using the audioplayer, which is supported on all platforms.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/10/31 06:19:40 $

% Use the java audio player to play back our sound.
if usejava('jvm')
    try
        ap = audioplayer(y, fs, bits);
        playblocking(ap);
    catch exception
        throw(exception);
    end
    return;
else
    warning('MATLAB:sound:unsupportedoption', ...
        'This platform does not support specifing FS or BITS when not using Java.');
end
    
end
