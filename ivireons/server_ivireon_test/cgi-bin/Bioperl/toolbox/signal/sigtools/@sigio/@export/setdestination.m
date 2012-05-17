function destobj = setdestination(this, destobj)
%SETDESTINATION   Pre-set function for the Destination Property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:27:44 $

olddestobj = get(this, 'Destination');

if isa(olddestobj, 'sigio.abstractxpdestwvars')
    allvardest = getcomponent(this, '-isa', 'sigio.abstractxpdestwvars', ...
        '-not', '-class', class(olddestobj));
    olddb     = getnamedatabase(olddestobj);
    for indx = 1:length(allvardest)
        
        setnamedatabase(allvardest(indx), olddb);
    end
    
elseif isa(destobj, 'sigio.abstractxpdestwvars'),
    allvardest = getcomponent(this, '-isa', 'sigio.abstractxpdestwvars', ...
        '-not', '-class', class(destobj));
    if ~isempty(allvardest),
        olddb     = getnamedatabase(allvardest(1));
        setnamedatabase(destobj, olddb);
    end
end

% [EOF]
