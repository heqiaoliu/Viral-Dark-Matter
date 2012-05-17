function s = exportinfo(Hwin)
%EXPORTINFO Export information for SIGWIN objects.

%   This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:16:56 $

% Both coefficientnames & coefficientvariables return cell arrays.
s.variablelabel = sigwinname(Hwin); 
s.variablename =  coefficientvariables(Hwin);

% SIGWINs can be exported as both objects and arrays.
s.exportas.tags = {'Coefficients','Objects'};

% SIGWIN object specific labels and names
s.exportas.objectvariablelabel = sigwinname(Hwin);
s.exportas.objectvariablename  = sigwinvariable(Hwin);

% Optional fields (destinations & constructors) if exporting to destinations other 
% than the built-in 'Workspace','Text-file', or, 'MAT-file';
s.destinations  = {'Workspace','Text-File','MAT-File'};
s.constructors  = {'','sigio.xp2winfile',''};



% [EOF]
