function fixedException = fixerror( exception )
% Modify an exception to hide any audioplayer object references.
%
%    FIXERROR takes in an exception and replaces references
%    to the Java or UDD audioplayer object with more generic 'audioplayer object',
%    and returns the new error as a cell array suitable to be passed into ERROR or
%    thrown/rethrown as an exception.
%
%    See Also: ERROR

%    NCH, JCS
%    Copyright 2003-2008 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:25:10 $

lerr = exception.message;
lid = exception.identifier;

% look for the java object references in the text and replace the text with
% more generic version
lerr = strrep(lerr, 'in the ''com.mathworks.toolbox.matlab.audiovideo.JavaAudioPlayer'' class', 'in the ''audioplayer'' class');
lerr = strrep(lerr, 'com.mathworks.toolbox.matlab.audiovideo.JavaAudioPlayer', 'audioplayer objects');
lerr = strrep(lerr, 'audioplayers.winaudioplayer', 'audioplayer objects');
lerr = strrep(lerr, 'winaudioplayer', 'audioplayer');

% get the "error using" string
errUsingString = xlate('Error using ==>');

% check for prepending trace lines.
while strncmp(lerr, errUsingString ,length( errUsingString )) == 1
    [firstline rem] = strtok(lerr,[10 13]);
    lerr = rem(2:length(rem));
end

% assign the cleaned up message to the output exception
fixedException = MException( lid, lerr );

end