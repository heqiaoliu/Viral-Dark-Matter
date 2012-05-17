function exportToWorkspace(this)
% EXPORTTOWORKSPACE  Export the linearization and operating point to the
% workspace
%
 
% Author(s): John W. Glass 30-Oct-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:31:05 $

% Export the lti object to the workspace
Label = regexprep(this.Label,' ','');
Label = regexprep(Label,'(','');
Label = regexprep(Label,')','');
if ~isvarname(Label)
    Label = 'Exported';
end
defaultnames = {sprintf('%s_sys',Label),sprintf('%s_op',Label)};
exporteddata = {this.LinearizedModel,this.getOperatingPoints};
export2wsdlg({'Linearized Model','Operating Point'},defaultnames,exporteddata)