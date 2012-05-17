function audiorecorderreg(lockOrUnlock)
%AUDIOPLAYERREG
% Registers audiorecorder objects with system.
%

%    Author(s): Brian Wherry 
%    Copyright 1984-2008 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $  $Date: 2008/08/20 22:56:40 $ 

if ispc,
	WinAudioRecorder(lockOrUnlock);
else
	error('MATLAB:audiorecorder:invalidPlatform','This function is only for use with 32 bit Windows machines.');
end
