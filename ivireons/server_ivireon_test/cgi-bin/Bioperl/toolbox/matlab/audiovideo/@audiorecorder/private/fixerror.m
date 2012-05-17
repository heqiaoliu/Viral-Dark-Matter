function fixedException = fixerror( exception )
%FIXERROR Modify a given exception to hide any audiorecorder object references.
%
%    FIXERROR replaces an exceptions error message references
%    to the Java or UDD audiorecorder object with more generic 'audiorecorder object',
%    and returns the new error as a cell array suitable to be passed into ERROR.
%
%    See Also: ERROR

%    JCS
%    Copyright 2003-2006 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:25:17 $

lerr = exception.message;
lid = exception.identifier;

% look for the java object references in the text and replace the text with
% more generic version
lerr = strrep(lerr, 'in the ''com.mathworks.toolbox.matlab.audiovideo.JavaAudioRecorder'' class', 'in the ''audiorecorder'' class');
lerr = strrep(lerr, 'property of javahandle.com.mathworks.toolbox.matlab.audiovideo.JavaAudioRecorder', ...
    'property of an audiorecorder object');
lerr = strrep(lerr, 'property of audiorecorders.winaudiorecorder', ...
    'property of an audiorecorder object');
lerr = strrep(lerr, 'com.mathworks.toolbox.matlab.audiovideo.JavaAudioRecorder', 'audiorecorder objects');
lerr = strrep(lerr, 'audiorecorders.winaudiorecorder', 'audiorecorder objects');
lerr = strrep(lerr, 'winaudiorecorder', 'audiorecorder');

% get the "error using" string
errUsingString = xlate('Error using ==>');

% check for prepending trace lines.
while strncmp(lerr,errUsingString,length(errUsingString)) == 1
    [firstline rem] = strtok(lerr,[10 13]);
    lerr = rem(2:length(rem));
end

% assign the cleaned up message to the output exception
fixedException = MException( lid, lerr );

end
