function ap = getplayer(obj)
%GETPLAYER Gets associated audioplayer object.
%
%    GETPLAYER(OBJ) returns the audioplayer object associated with
%    this audiorecorder object.
%
%    See also AUDIORECORDER, AUDIOPLAYER.

%    JCS
%    Copyright 2003-2006 The MathWorks, Inc.

ap = audioplayer(obj);

