function set_currentwin(hManag, index)
%SET_CURRETWIN Set the Currentwin property

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2007/12/14 15:20:13 $

% Error ckecking
if index < 0 | ~isequal(index,floor(index)) | length(index)>1,
    error(generatemsgid('InternalError'),'winmanagement internal error : Value must be a positive integer.')
end
selection = get(hManag, 'Selection');
if index > length(selection),
    error(generatemsgid('InternalError'),'winmanagement internal error : Index exceed matrix dimension');
end

% Sets the Currentwin property
set(hManag, 'Currentwin', selection(index));


% [EOF]
