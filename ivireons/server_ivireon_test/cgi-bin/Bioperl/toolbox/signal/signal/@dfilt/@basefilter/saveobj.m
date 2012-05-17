function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:03:54 $

s.class   = class(this);
s.version = get(this, 'version');

% Save all of the public properties.
s = setstructfields(s, ...
    savepublicinterface(this));

% Save the reference coefficients.
s = setstructfields(s, ...
    savereferencecoefficients(this));

% Save the metadata.
s = setstructfields(s, ...
    savemetadata(this));

% Save the arithmetic information.
s = setstructfields(s, ...
    savearithmetic(this));

% Save any private data we might need to reproduce the filter.
s = setstructfields(s, ...
    saveprivatedata(this));

% [EOF]
