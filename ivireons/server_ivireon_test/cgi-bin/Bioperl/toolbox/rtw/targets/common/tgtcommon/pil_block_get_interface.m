function [pilInterface ...
          pilConfig ...
          pilBlock] = pil_block_get_interface(block)
% PIL_BLOCK_GET_INTERFACE: Returns handles to objects associated with a
% particular PIL Block
%
% [pilInterface, ...
%  pilConfig, ...
%  pilBlock] = pil_block_get_interface(block)
%
% Input argument:
% 
% block - Full Simulink system path to the PIL Block
%
% Output arguments: 
%
% pilInterface: Handle to the rtw.pil.SILPILInterface object.
%
% pilConfig: Handle to the rtw.connectivity.Config object.
%
% pilBlock: Handle to rtw.pil.SILPILBlock object.

%   Copyright 2005-2010 The MathWorks, Inc.

error(nargchk(1, 1, nargin, 'struct'));

% check reference block
if ~strcmp(get_param(block, 'ReferenceBlock'), 'pil_lib/PIL Block')
  TargetCommon.ProductInfo.error('common', 'InputArgNInvalid', 'Input', 'PIL Block');
end

% create an instance of SILPILBlock
pilBlock = rtw.pil.SILPILBlock(get_param(block, 'handle'));
% get the pilInterface
displayConfigHyperlink = true;
pilInterface = pilBlock.getPILInterface(displayConfigHyperlink);
% get the connectivity implementation
pilConfig = pilInterface.getConfig;