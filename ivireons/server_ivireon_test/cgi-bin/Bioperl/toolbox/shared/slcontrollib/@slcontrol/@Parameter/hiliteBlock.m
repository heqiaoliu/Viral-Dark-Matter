function hiliteBlock(this)
% HILITEBLOCK Highlights the blocks referring to the parameter represented by
% this object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/11/09 21:02:12 $

blocks = this.ReferencedBy;
for ct = 1:length(blocks)
  try
    parent = get_param(blocks{ct}, 'Parent');
    open_system( parent )
    set_param( blocks{ct}, 'HiliteAncestors', 'default' )
  catch
    ctrlMsgUtils.error( 'SLControllib:general:InvalidBlockName', blocks{ct} );
  end
end
