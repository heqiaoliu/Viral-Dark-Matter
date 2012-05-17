function index = end(sys,position,numindices)
%END  Overloaded END for dynamic system objects.
%
%   END(SYS,POSITION,NUMINDICES) returns the index
%   corresponding to the last entry along the dimension
%   POSITION in the dynamic system or system array SYS.
%   NUMINDICES is the number of indices used in the
%   indexing expression.
%
%   For example,
%      SYS(end,1)   extracts the subsystem from the first
%                   input to the last output
%      SYS(2,1,end) extracts the mapping from first input
%                   to second output in the last model of
%                   the system array SYS.
%
%   You can use the command
%      SYS(:,:,end+1) = RHS,
%   to grow an array SYS of dynamic systems.

%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:48 $
sizes = size(sys);
if position==numindices && numindices<length(sizes)
   % END is in the last position and there are fewer
   % indices than dimensions
   if position<3
      index = prod(sizes(position:2));   % collapse i/o dims
   else
      index = prod(sizes(position:end)); % collapse array dims
   end
else
   sizes = [sizes 1]; % '1' allows trailing singleton dims
   index = sizes(min(position,end));
end