function s = exportinfo(Hd)
%EXPORTINFO Export information for the DFILT class.

%   This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:09:40 $

error(nargchk(1,1,nargin,'struct'));

% Both coefficientnames & coefficientvariables return cell arrays.
s.variablelabel = interspace(coefficientnames(Hd)); 
s.variablename = coefficientvariables(Hd);

% DFILTs can be exported as both objects and arrays.
s.exportas.tags = {'Coefficients','Objects'};

% DFILT object specific labels and names
s.exportas.objectvariablelabel = dfiltname(Hd);
s.exportas.objectvariablename  = dfiltvariable(Hd);

% Optional fields (destinations & constructors) if exporting to destinations other 
% than the 'Workspace','Text-file', or, 'MAT-file';
s.destinations  = {'Workspace','Coefficient File (ASCII)','MAT-File','SPTool'};
s.constructors  = {'','sigio.xp2coeffile','','sigio.xp2sptool'};

% [EOF]
