function thisrender(h, hFig, pos)
%THISRENDER Render the destination options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:27:31 $

if nargin < 3 , pos =[]; end
if nargin < 2 , hFig = gcf; end

abstractxdwvars_thisrender(h,pos);

% [EOF]
