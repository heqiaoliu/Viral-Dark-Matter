function emlBlocks = eml_blocks_in(objectId)

% Copyright 2002-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/20 20:50:04 $
% returns the eML blocks in simulink that are powered
% by Stateflow
charts = charts_in(objectId);
emlBlocks = [];
for i=1:length(charts)
   if(is_eml_chart(charts(i)))
      emlBlocks = [emlBlocks,charts(i)];
   end
end

