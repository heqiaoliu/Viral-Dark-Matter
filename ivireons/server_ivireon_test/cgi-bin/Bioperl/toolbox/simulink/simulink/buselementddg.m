function dlgstruct = buselementddg(h, name)
% BUSELEMENTDDG Dynamic dialog for Simulink BusElement type objects.

% To lauch this dialog in MATLAB, use:
%    >> a = Simulink.BusElement;
%    >> DAStudio.Dialog(a);

% Copyright 2003-2007 The MathWorks, Inc.
% $Revision: 1.1.6.6 $

    dlgstruct = structelementddg(h, name, true);

% EOF
