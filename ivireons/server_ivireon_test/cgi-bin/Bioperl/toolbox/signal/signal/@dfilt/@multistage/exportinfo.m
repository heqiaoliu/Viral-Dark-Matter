function s = exportinfo(Hd)
%EXPORTINFO Export information for the DFILT class.

%   This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:09:25 $

error(nargchk(1,1,nargin,'struct'));

% Both coefficientnames & coefficientvariables return cell arrays.
s.variablelabel = {'Coefficients'};
s.variablename  = {'coef'};

% DFILTs can be exported as both objects and arrays.
s.exportas.tags = {'Coefficients','Objects'};

% DFILT object specific labels and names
s.exportas.objectvariablelabel = {'Discrete Filter'};
s.exportas.objectvariablename  = {'Hd'};

% Optional fields (destinations & constructors) if exporting to destinations other 
% than the 'Workspace','Text-file', or, 'MAT-file';
s.destinations  = {'Workspace','Coefficient File (ASCII)','MAT-File','SPTool'};
s.constructors  = {'','sigio.xp2coeffile','','sigio.xp2sptool'};

% [EOF]
