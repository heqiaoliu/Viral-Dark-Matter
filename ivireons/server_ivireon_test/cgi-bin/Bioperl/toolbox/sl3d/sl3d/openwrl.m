function openwrl(file)
%OPENWRL Opens a VRML world file using Simulink 3D Animation.

%   Copyright 1998-2010 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/03/01 05:30:15 $ $Author: batserve $

% try opening the file in the viewer
try
  vrview(file);

% if that has failed, open it as text
catch ME
  
  % warn if the failure was due to missing license
  if strcmp(ME.identifier, 'VR:notpermittedindemo')
    h = warndlg(['Opening this file in Simulink 3D Animation viewer is not permitted in the demonstration version of the product.', ...
                 'The file will be opened as text.'], ...
                'Simulink 3D Animation demonstration version', 'modal');
    uiwait(h);
  end

  edit(file);
end
