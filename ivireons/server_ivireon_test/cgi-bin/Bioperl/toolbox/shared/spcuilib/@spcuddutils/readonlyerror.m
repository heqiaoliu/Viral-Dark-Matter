function varargout = readonlyerror(prop, enabprop, enabvalue, b)
%READONLYERROR Produces an error that a property is read-only.
%   READONLYERROR(PROP) produces an error that PROP is a read-only
%   property.
%
%   READONLYERROR(PROP, EPROP, EVALUE) produces an error that PROP is
%   read-only and tells the user to set the EPROP property to EVALUE in
%   order to enable PROP.
%
%   READONLYERROR(PROP, EPROP, EVALUE, false) produces an error that tells
%   the user to set to the EPROP property to any value except EVALUE to
%   enable PROP.
%
%   ERRMSG = READONLYERROR(...) returns the error structure instead of
%   throwing the error directly.


%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/11/17 22:41:27 $


if nargin < 2
    errmsg.identifier = generatemsgid('readOnly');
    errmsg.message    = sprintf('Changing the ''%s'' property is not allowed.', ...
        prop);
else
    if nargin < 4
        modstr = '';
    else
        if b, modstr = '';
        else  modstr = 'not ';
        end
    end

    % If the "enable value" is a string, wrap it in extra quotation marks.
    if ischar(enabvalue)
        enabvalue = sprintf('''%s''', enabvalue);
    else
        enabvalue = mat2str(enabvalue);
    end
    
    errmsg.identifier = generatemsgid('readOnly');
    errmsg.message    = sprintf('%s %s', ...
        sprintf('Changing the ''%s'' property is only allowed when the', prop), ...
        sprintf('''%s'' property is %sset to %s.', enabprop, modstr, enabvalue));
end

if nargout
    varargout = {errmsg};
else
    error(errmsg);
end

% [EOF]
