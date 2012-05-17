function reset(h)
%RESET Reset the modulator object H to its initial state. 

% @modem/@baseclass

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/05 17:45:41 $

warning([getErrorId(h) ':NoReset'], ...
    '%s does not have internal state information. Nothing to reset.', ...
    lower(class(h)));
