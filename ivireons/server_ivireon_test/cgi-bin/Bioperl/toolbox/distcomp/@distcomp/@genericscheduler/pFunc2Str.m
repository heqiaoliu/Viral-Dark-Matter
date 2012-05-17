function str = pFunc2Str(obj, fcn) %#ok<INUSL>
; %#ok Undocumented
%pFunc2Str - return a string from a function handle or char
%
%  STR = pFunc2Str(SCHEDULER, FCN)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:45:00 $ 

if ischar( fcn )
    str = fcn;
elseif strcmp( class( fcn ), 'function_handle' )
    str = func2str( fcn );
else
    % Should never get here because of the "MATLAB Callback" check from UDD
    str = sprintf( 'object of type "%s"', class( fcn ) );
end