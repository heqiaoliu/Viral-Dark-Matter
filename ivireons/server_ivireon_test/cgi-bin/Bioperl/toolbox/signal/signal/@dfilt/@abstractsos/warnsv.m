function [msgid,msg] = warnsv(Hd)
%WARNSV Warn if too many scale values.
%   WARNSV Will send a warning is there are too many scale values.
%
%
%   See also DFILT.   
  
%   Author: R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 17:01:38 $
  
msgid = 'signal:dfilt:scalevalues';
msg = [];
nsecs = nsections(Hd);

if length(Hd.ScaleValues) > nsecs + 1,
    msg = sprintf('Too many scale values, only using the first %d.',nsecs+1);
end
