function isLink = this_is_an_sflink(blockH)
%
% Determine if a block is a link
%

%   Jay Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2008/12/01 08:08:24 $

if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else
   isLink = 1;
end;
