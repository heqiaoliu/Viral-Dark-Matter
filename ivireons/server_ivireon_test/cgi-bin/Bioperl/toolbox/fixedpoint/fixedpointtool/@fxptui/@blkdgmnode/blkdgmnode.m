function h = blkdgmnode(varargin)
% BLKDGMNODE constructor
%

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:08 $

bd = [];
h = fxptui.blkdgmnode;
if nargin > 0
	bd = get_param(varargin{1}, 'Object');	
end
if(isempty(bd)); return; end
h = fxptui.createsubsys(bd);
h.populate;
h.firehierarchychanged;



% [EOF]

