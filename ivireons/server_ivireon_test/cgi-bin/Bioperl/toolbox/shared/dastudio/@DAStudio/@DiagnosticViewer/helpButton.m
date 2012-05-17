function helpButton(h)
%  HELPBUTTON
%  helpButton provides the gateway to get to the help
%  info about the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.3 $ 
try
    helpview([docroot,'/mapfiles/simulink.map'],'diagnostic_viewer');
catch
    errmsg=lasterr('');
    disp(errmsg);
end