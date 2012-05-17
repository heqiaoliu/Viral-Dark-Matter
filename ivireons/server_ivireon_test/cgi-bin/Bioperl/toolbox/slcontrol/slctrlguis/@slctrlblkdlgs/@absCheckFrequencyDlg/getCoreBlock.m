function hBlk = getCoreBlock(hBlk) 
%

% Author(s): A. Stothert 07-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:35 $

% GETCOREBLOCK return underlying check block used to store the check block
% visualization handles
%

%Find check block under this masked subsystem. We use the appdata of
%this block to store the visualization handles.
hBlk = get_param(strcat(getFullName(hBlk),'/Check Freq. Characteristics'),'Object');
end