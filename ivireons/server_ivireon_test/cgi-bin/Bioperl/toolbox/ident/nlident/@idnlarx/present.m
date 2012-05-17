function txt = present(sys)
%PRESENT presents IDNLARX or IDNLHW model properties

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:58:40 $

% Author(s): Qinghua Zhang

txt = display(sys);
tst = timestamp(sys);
rows = size(tst,1);
if ischar(tst)
  for k=1:rows
    txt = [txt sprintf('\n%s', tst(k,:))];
  end
end

if nargout==0
  disp(txt)
  clear txt
end

% FILE END