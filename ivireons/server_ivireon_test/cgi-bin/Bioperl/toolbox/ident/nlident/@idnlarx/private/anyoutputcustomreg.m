function  yflag = anyoutputcustomreg(custreg, ny)
%ANYOUTPUTCUSTOMREG returns True if any custom regressor involves output
%  yflag = anyoutputcustomreg(custreg, ny)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:48 $

% Author(s): Qinghua Zhang

if ~iscell(custreg)
  custreg = {custreg};
end
yflag = false;
for ky=1:numel(custreg)
  if ~isempty(custreg{ky}) && isa(custreg{ky},'customreg')
    ncr = numel(custreg{ky});
    for kcr=1:ncr
      if any(custreg{ky}(kcr).ChannelIndices<=ny)
        yflag = true;
        return
      end
    end
  end
end

% FILE END