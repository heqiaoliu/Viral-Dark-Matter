function msg = overflowmsg(q,oldnover,nover2)
%OVERFLOWMSG Quantizer overflow message
%   MSG = OVERFLOWMSG(Q, OLDNOVER) generates a warning message if
%   Q.NOVERFLOWS > OLDNOVER, where OLDNOVER is an integer.
%
%   MSG = OVERFLOWMSG(Q, NOVER1, NOVER2) generates a warning message if
%   NOVER2 > NOVER1.
%
%   This is useful for creating a warning message if new overflows occurred
%   during a calculation.
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/QUANTIZE

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:14:07 $

msg = '';
if nargin>=3
  newnover = nover2-oldnover;
else
  newnover = q.noverflows-oldnover;
end
if newnover > 0
  if newnover == 1
    overflows = 'overflow';
  else
    overflows = 'overflows';
  end
  msg = sprintf('%d %s.',newnover, overflows);
end

