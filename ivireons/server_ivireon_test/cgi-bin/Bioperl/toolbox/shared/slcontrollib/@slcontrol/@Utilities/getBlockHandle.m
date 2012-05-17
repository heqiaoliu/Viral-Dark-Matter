function h = getBlockHandle(this, block)
% GETBLOCKHANDLE Get the handle of the BLOCK
%
% BLOCK is a Simulink block name or handle.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/07/14 17:12:08 $

% Get Simulink object corresponding to block
if ischar(block)
  try
    h = get_param(block, 'Object');
  catch E
    ctrlMsgUtils.error( 'SLControllib:general:InvalidBlockName', block );
  end
elseif ishandle(block)
  h = handle(block);
  if ~isa(h, 'Simulink.Block')
    ctrlMsgUtils.error( 'SLControllib:slcontrol:InvalidSimulinkBlock', class(h) );
  end
else
  ctrlMsgUtils.error( 'SLControllib:general:InvalidArgument', 'BLOCK', ...
		      'getBlockHandle', 'slcontrol.Utilities.getBlockHandle');
end

% Check if the Simulink object is a block
if ~strcmp(h.Type, 'block')
  ctrlMsgUtils.error( 'SLControllib:slcontrol:InvalidSimulinkBlock', ...
		      h.getFullName );
end
