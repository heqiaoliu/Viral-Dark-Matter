function [ val ] = gf_Visible(h, val )
%GF_VISIBLE gets the visible property
%   OUT = GF_VISIBLE(h, val ) takes in a handle to a menugroup and 
%         if the group contains no children then its
%         visibility is set to 'off

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:43:29 $

if isempty(h.down)
%     val = 'off'; this is commented out to fix geck 493330 and we should
%     reevaluate as per geck 410637
end

% [EOF]
