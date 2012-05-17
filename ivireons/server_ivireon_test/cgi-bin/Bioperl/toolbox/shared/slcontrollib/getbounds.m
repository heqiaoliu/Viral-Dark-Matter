function bnds = getbounds(blk) 
% GETBOUNDS return the requirement objects described by a model check block
%
 
% Author(s): A. Stothert 14-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:50:34 $


%Make sure the block is a model check block
if ~strncmp(get_param(blk,'MaskType'),'Checks_',7)
   error('SLControllib:checkpack:errInvalidCheckBlock',...
      DAStudio.message('SLControllib:checkpack:errInvalidCheckBlock'));
end

%Call static method associated with block to construct requirement object
cls = get_param(blk,'DialogControllerArgs');
if ischar(blk)
   blk = get_param(blk,'Object');
end
bnds = feval(strcat(cls,'.getBounds'),blk);
end