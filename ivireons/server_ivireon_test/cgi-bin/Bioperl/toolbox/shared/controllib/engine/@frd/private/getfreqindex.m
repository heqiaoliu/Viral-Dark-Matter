function [indices,freqIndices] = getfreqindex(sys, indices)
% Looks through indices for frequency access indices,
% returns frequency indices and remaining indices

%   Author: S. Almy
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:17 $

nind = length(indices);
% RE: Since last 2 elements must be 'freq',freqIndices, look at last 
%     two indices only
keyword = indices{max(1,nind-1)};
freqIndices = {};
if nind>1 && strncmpi(keyword,'frequencypoints',length(keyword))
   % Beware that keyword in position 1,2 could be channel/group name
   if nind<=3  
      try %#ok<TRYNC>
         % Try matching keyword against I/O names and groups
         name2index(sys,keyword,nind-1); 
         return
      end
   end
   
   % keyword is Frequency
   ctrlMsgUtils.warning('Control:ltiobject:ObsoleteSyntaxFRDIndex')
   freqIndices = indices(nind);
   indices = indices(:,1:nind-2);
   if isempty(indices)
      indices = {':',':'};
   end
end
