function [Fout,OutputHasLocalFimath] = eml_checkfimathforbinaryops(a,b)
% Private function that checks that the fimaths of fis a & b match if they are operands in a binary operation
%#eml

%   Copyright 2008-2009 The MathWorks, Inc.

eml_transient;

% Get the fimaths of a & b and also determine if these fimaths are actually attached to the fi objects
fa = eml_fimath(a); 
fb = eml_fimath(b); 
aHasLocalFimath = eml_const(eml_fimathislocal(a));
bHasLocalFimath = eml_const(eml_fimathislocal(b));

% Initialize output fimath and output's fimathislocal flag
OutputHasLocalFimath = eml_const(aHasLocalFimath || bHasLocalFimath);

% Check for fimaths to be equal if they are both local to the fis
if eml_const(aHasLocalFimath && bHasLocalFimath && ~isequal(fa,fb))
    Fout = fa;
    eml_assert(0,'FIMATH of both operands must be equal.');
else
    if aHasLocalFimath
        Fout = fa;
    elseif bHasLocalFimath
        Fout = fb;
    else % a & b have inherited fimaths
        Fout = fa;
    end
end
