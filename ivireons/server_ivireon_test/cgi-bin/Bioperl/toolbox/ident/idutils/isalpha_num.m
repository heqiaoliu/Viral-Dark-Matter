function s = isalpha_num(a)
%ISALPH_NUM returns True for alpha-numeric character, including '_'.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/10/02 18:51:40 $

error(nargchk(1, 1, nargin, 'struct'))
if ~ischar(a) || length(a)~=1
  ctrlMsgUtils.error('Ident:utility:isalphaNum1')
end

s = ~isempty(findstr(upper(a), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'));

% FILE END
