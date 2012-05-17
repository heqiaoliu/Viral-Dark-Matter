function slSetFrameUpgradeParameter(blkh, paramName, paramVal)
%SLSETFRAMEUPGRADEPARAMETER  If appropriate, set the a frame upgrade
%parameter to its appropriate value.  For example, this function is used to
%set the 'Input processing' parameter to 'Inherited' when loading a pre-10b
%model.
%
% Input arguments:
%   blkh      - handle of block to be updated
%   paramName - parameter name (string)
%   paramVal  - new value of parameter (string)

% If the model is pre-10b, and it is being loaded for the first time, then
% set the frame upgrade parameter appropriately.  The model state can be
% determined by the presence of the 'hasInheritedOption' field in the
% block's UserData structure.

% Copyright 2010 The MathWorks, Inc.
% $Date: 2010/03/15 23:38:03 $ $Revision: 1.1.6.1 $

block = get_param(blkh,'object');
if ~isfield(block.UserData, 'hasInheritedOption')
    % Create and save the UserData
    block.UserData.hasInheritedOption = true;
    set_param(gcbh, 'UserDataPersistent', 'on', ...
                    'UserData', block.UserData, ...
                    paramName, paramVal);
end

% [EOF]