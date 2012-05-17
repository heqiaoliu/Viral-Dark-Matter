function audioplayerreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audioplayer objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2008 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $  $Date: 2008/08/20 22:56:39 $ 

if ispc,
	WinAudioPlayer(lockOrUnlock);
else
    error('MATLAB:audioplayer:invalidPlatform','This function is only for use with 32 bit Windows machines.');
end