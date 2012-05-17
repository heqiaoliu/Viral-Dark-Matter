function varargout = obsoletemethod(altname)
%OBSOLETEMETHOD Produces a warning that a method is obsolete.
%   OBSOLETEMETHOD produces a warning that the calling method is obsolete.
%
%   OBSOLETEMETHOD(NAME) produces a warning which instructs the user to use
%   the method specified by the string NAME.
%
%   WARNMSG = OBSOLETEMETHOD returns the warning structure instead of
%   throwing the warning directly.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:41:26 $

d = dbstack;
name = d(2).name;

warnmsg.identifier = generatemsgid('obsoleteMethod');
warnmsg.message    = sprintf('The %s method is obsolete.', upper(name));

if nargin
    warnmsg.message = sprintf('%s  Use %s instead.', warnmsg.message, upper(altname));
end

if nargout
    varargout = {warnmsg};
else
    warning(warnmsg.identifier, warnmsg.message);
end


% [EOF]
