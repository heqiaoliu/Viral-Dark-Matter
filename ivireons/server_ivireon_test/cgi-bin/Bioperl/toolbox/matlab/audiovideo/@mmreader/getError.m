function eMsg = getError(msgID, varargin)
%GETERROR Returns the error messages for the mmreader object.
%
%    GETERROR(MSGID) returns the message string corresponding to
%    the error message ID, MSGID.
%

%    DH NH DL
%    Copyright 2004-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $  $Date: 2010/03/04 16:22:58 $

switch lower(msgID)
    case 'matlab:mmreader:nofile'
        eMsg = 'FILENAME must be specified.';
    case 'matlab:mmreader:nommreaderobj'
        eMsg = 'OBJ must be an mmreader object.';
    case 'matlab:mmreader:nocatenation'
        eMsg = 'mmreader objects cannot be concatenated.';
    case 'matlab:mmreader:filenotfound'
        eMsg = sprintf('The filename specified was not found in the MATLAB path.');
    case 'matlab:mmreader:loadset'
        eMsg = sprintf('Could not load mmreader object properly.  ''%s'' property was not set.', varargin{1});
    case 'matlab:mmreader:invalidreadindex'
        eMsg = sprintf('INDEX must be a numeric scalar or 1x2 vector.');
    case 'matlab:class:setprohibited'
        eMsg = sprintf('Setting the ''%s'' property of the ''%s'' class is not allowed.', varargin{:});
    case 'matlab:class:mustbestring'
        eMsg = sprintf('Parameter must be a string.');
    case 'matlab:mmreader:inspectobsolete'
        eMsg = sprintf('INSPECT is obsolete for mmreader and will be removed in future versions. Open the variable in the Workspace browser or use <a href="matlab:help OPENVAR">openvar(''name'')</a>.' );     
    case 'matlab:mmreader:nonscalar'
        eMsg = sprintf('OBJ must be a scalar mmreader object.');
    otherwise
        eMsg = ['Error: ' msgID varargin{:}];
end
