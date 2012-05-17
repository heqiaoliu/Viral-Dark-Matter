function eMsg = getError(msgID, varargin)
%GETERROR Returns the error messages for the VideoReader object.
%
%    GETERROR(MSGID) returns the message string corresponding to
%    the error message ID, MSGID.
%

%    DH NH DL
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:03 $

switch lower(msgID)
    case 'matlab:videoreader:nofile'
        eMsg = 'FILENAME must be specified.';
    case 'matlab:videoreader:novideoreaderobj'
        eMsg = 'OBJ must be an VideoReader object.';
    case 'matlab:videoreader:nocatenation'
        eMsg = 'VideoReader objects cannot be concatenated.';
    case 'matlab:videoreader:filenotfound'
        eMsg = sprintf('The filename specified was not found in the MATLAB path.');
    case 'matlab:videoreader:loadset'
        eMsg = sprintf('Could not load VideoReader object properly.  ''%s'' property was not set.', varargin{1});
    case 'matlab:videoreader:invalidreadindex'
        eMsg = sprintf('INDEX must be a numeric scalar or 1x2 vector.');
    case 'matlab:class:setprohibited'
        eMsg = sprintf('Setting the ''%s'' property of the ''%s'' class is not allowed.', varargin{:});
    case 'matlab:class:mustbestring'
        eMsg = sprintf('Parameter must be a string.');
    case 'matlab:videoreader:inspectobsolete'
        eMsg = sprintf('INSPECT is obsolete for VideoReader and will be removed in future versions. Open the variable in the Workspace browser or use <a href="matlab:help OPENVAR">openvar(''name'')</a>.' );     
    case 'matlab:videoreader:nonscalar'
        eMsg = sprintf('OBJ must be a scalar VideoReader object.');
    otherwise
        eMsg = ['Error: ' msgID varargin{:}];
end
