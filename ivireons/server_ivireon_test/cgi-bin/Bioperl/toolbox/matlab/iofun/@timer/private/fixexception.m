function exception = fixexception(exception)
%fixexception modifies the exception to hide any java timer object references.
%
%    FIXEXCEPTION replaces references
%    to the java timer object with more generic 'timer object'.
%
%    See Also: ERROR

%    Copyright 2001-2007 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2008/03/17 22:17:41 $

lerr = exception.message;

% look for the java object references in the text and replace the text with more generic version
lerr = strrep(lerr, 'javahandle.', '');
lerr = strrep(lerr, 'in the ''com.mathworks.timer.TimerTask'' class', 'for timer objects');
lerr = strrep(lerr, 'class com.mathworks.timer.TimerTask', 'timer objects');
lerr = strrep(lerr, 'com.mathworks.timer.TimerTask', 'timer objects');

exception = MException(exception.identifier, '%s', lerr);
