function errorHandler(msg,titleStr)
% Scope error-message handler
% Produces a modal dialog
% Accepts strings and cell-arrays of strings

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/05/23 08:12:02 $

error(nargchk(1, 2, nargin, 'struct'));

% If the error string is empty, return early.
if isempty(msg)
    return;
end

if nargin < 2
    titleStr = 'Scope Error';
end

if iscell(msg),
    % Each cell is a separate line
    % Formattting handled by 'errordlg'
    formattedMsg = msg;
else
    formattedMsg = sprintf('%s', msg);
end

errordlg( formattedMsg, titleStr, 'modal' );

% [EOF]
