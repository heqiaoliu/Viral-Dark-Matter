%LASTWARN Last warning message.
%   LASTWARN, by itself, returns a string containing the last warning message
%   issued by MATLAB.
%
%   [LASTMSG, LASTID] = LASTWARN returns two strings, the first containing the
%   last warning message issued by MATLAB and the second containing the last
%   warning message's corresponding message identifier (see HELP WARNING for
%   more information on message identifiers).
%
%   LASTWARN('') resets the LASTWARN function so that it will return an empty
%   string matrix for both LASTMSG and LASTID until the next warning is
%   encountered.
%   
%   LASTWARN('MSG', 'MSGID') sets the last warning message to MSG and the last
%   warning message identifier to MSGID.  MSGID must be a legal message
%   identifier (or an empty string).
%
%   The WARNING function will update LASTWARN's state irrespective of
%   whether the warning invoked was on or off at the time.
%
%   See also WARNING, MException.last.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2009/03/30 23:41:01 $
%   Built-in function.
