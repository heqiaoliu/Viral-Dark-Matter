function opensmf(smf_file)
%OPENSMF Load Simulink Manifest File (.smf) and show as HTML in web browser.
%
%   Helper function for OPEN.
%
%   See OPEN.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 

newdepset = dependencies.MDLDepSet.Load(smf_file);
temp_report_file = [tempname '.html'];
temp_smf_file = [tempname '.smf'];
newdepset.Report(temp_smf_file,temp_report_file,'multiplehtml');
web(temp_report_file);
delete(temp_smf_file);

end
