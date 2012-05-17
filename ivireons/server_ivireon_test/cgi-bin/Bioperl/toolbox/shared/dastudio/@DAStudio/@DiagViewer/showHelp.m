function showHelp
%  showHelp
%  Displays help for the Diagnostic Viewer in the MATLAB
%  help browser.
%  Copyright 2008 The MathWorks, Inc.
   
try
    helpview([docroot,'/mapfiles/simulink.map'],'diagnostic_viewer');
catch ME
    disp(ME.message);
end