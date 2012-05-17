function hblk = terminator(hTar, name, render)
%TERMINATOR Add a Terminator block to the model

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:50:00 $

error(nargchk(2,3,nargin,'struct'));

sys = hTar.system;

if nargin<3
    render=true;
end

if render
     hblk = add_block('built-in/Terminator', [hTar.system '/' name]);
else % just update block
   hblk2=find_system(sys,'SearchDepth',1,'BlockType','Terminator','Name',name);
    hblk=hblk2{1};
end


% [EOF]
