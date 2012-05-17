function LicenseOK = utFreqLicenseCheck 
% UTLICENSECHECK  utility function to check valid license installed for
% frequency domain requirements
%
 
% Author(s): A. Stothert 31-Oct-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:20 $

persistent LicenseFlag;

if isempty(LicenseFlag)
   %Check CST installed
   LicenseFlag = license('test','control_toolbox') && ~isempty(ver('control'));
end
LicenseOK = LicenseFlag;

if ~LicenseFlag
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errInstallCST')
end
