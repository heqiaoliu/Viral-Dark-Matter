function eMsg = timererror(MSGID, varargin)
%TIMERERROR Returns the error messages for the timer object
%
%    TIMERERROR(MSGID) returns the message string corresponding to
%    the error message ID, MSGID.
%

%    RDD 11-20-2001
%    Copyright 2001-2007 The MathWorks, Inc.
%    $Revision: 1.7.4.7 $  $Date: 2008/03/17 22:17:44 $

switch lower(MSGID)
    case 'matlab:timer:fieldnames:singleobj',
        eMsg = 'OBJ must be a 1-by-1 timer object.';
 case {'matlab:timer:subsasgn:badsubscript', ['matlab:timer:subsref:' ...
                      'badsubscript']},
        eMsg = sprintf(['Function ''subsindex'' is not defined for values ' ...
                        'of class ''%s''.'], varargin{1});
    case 'matlab:timer:notimerobj',
        eMsg = 'OBJ must be a timer object.';
    case 'matlab:timer:emptytimerarray'
        eMsg = 'Creation or use of an empty timer object array is not allowed.\nUse CLEAR to clear objects from the workspace.';
    case 'matlab:timer:invalid'
        eMsg = '\n Invalid timer object.\n This object has been deleted and should be\n removed from your workspace using CLEAR.\n\n';
    case 'matlab:timer:someinvalid'
        eMsg = 'One or more invalid timer objects in input array.';
    case 'matlab:timer:sizemismatch'
        eMsg = 'Matrix dimensions must agree.';
    case 'matlab:timer:notenoughinputs'
        eMsg = 'Not enough input arguments.';
    case 'matlab:timer:nolhswithvector'
        eMsg = 'Vector of handles not permitted for GET(OBJ) with no left hand side.';
    case 'matlab:timer:singletonrequired'
        eMsg = 'OBJ must be a 1-by-1 timer object.';
    case 'matlab:timer:startat:notenoughparameters'
        eMsg = 'STARTAT requires at least two parameters. See help TIMER/STARTAT.';
    case 'matlab:timer:startat:numtimersanddelaymismatch'
        eMsg = 'STARTAT requires start delay values to be scalar or\nequal to OBJ length.  See help TIMER/STARTAT.';
    case 'matlab:timer:startat:invaliddatesyntax'
        eMsg = 'Error in specification of serial date number.  See help TIMER/STARTAT.';
    case 'matlab:timer:startat:startdelaynegative'
        eMsg = 'The specified start time has already passed.';
    case 'matlab:timer:startat:startdelayinvalid'
        eMsg = 'The specified start time resulted in an invalid startdelay.';
    case 'matlab:timer:wait:infinitetimer'
        eMsg = 'Can''t wait with a timer that has an infinite TasksToExecute.';
    case 'matlab:timer:inconsistentsubscript'
        eMsg = 'Inconsistently placed ''()'' in subscript expression.';
    case 'matlab:timer:badcellref'
        eMsg = 'Cell contents reference from a non-cell array object.';
    case 'matlab:timer:inconsistentdotref'
        eMsg = 'Inconsistently placed ''.'' in subscript expression.';
    case 'matlab:timer:exceedmatrixdim'
        eMsg = 'Index exceeds matrix dimensions.';
    case 'matlab:timer:badref'
        eMsg = sprintf('Unknown subscript expression type: %s.',varargin{:});
    case 'matlab:timer:assignelementsizemismatch'
        eMsg = 'In an assignment A(I)=B, the number of elements in B and I must be the same.';
    case 'matlab:timer:nontimer_assignment'
        eMsg = sprintf('Conversion from %s to timer object is not supported.',varargin{1});
    case 'matlab:timer:unhandledsyntax'
        eMsg = 'Syntax not supported.';
    case 'matlab:timer:nonpositiveindex'
        eMsg = sprintf('Subscript indices must either be real positive integers or logicals.');
    case 'matlab:timer:gapsnotallowed'
        eMsg = 'Gaps are not allowed in timer array indexing.';
    case 'matlab:timer:assigntonontimerobject'
        eMsg = 'Only timer objects may be concatenated.';
    case 'matlab:timer:assigntonull'
        eMsg = 'Use CLEAR to remove the object from the workspace.';
    case 'matlab:timer:errorinobjectarray'
        eMsg = 'One or more objects could not be started or have already been started.';
    case 'matlab:timer:noawt'
        eMsg = 'The timer objects require Java AWT support.';
    case 'matlab:timer:creatematrix'
        eMsg = 'Only a row or column vector of timer objects can be created.';
    case 'matlab:timer:negativestartdelay'
        eMsg = 'StartDelay must be a positive number.';
    case 'matlab:timer:start:alreadystarted'
        eMsg = 'Cannot start timer because it is already running.';
    case 'matlab:timer:deleterunning'
        eMsg = 'You are deleting one or more running timer objects.  MATLAB has automatically stopped them before deletion.';
    case 'matlab:timer:propnotenumtype'
        eMsg = sprintf('A timer object''s ''%s'' property does not have a fixed set of property values.\n', varargin{1});
    otherwise
        eMsg = ['Error: ' MSGID varargin{:}];
end




