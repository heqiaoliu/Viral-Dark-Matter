function hblk = outport(hTar, name, render)
%OUTPORT Add a Outport block to the model.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:52 $

error(nargchk(2,3,nargin,'struct'));

sys = hTar.system;

if nargin<3
    render=true;
end

if render 
    hblk = add_block('built-in/Outport', [hTar.system '/' name]);
else % do not add block just update
    hblk2=find_system(sys,'SearchDepth',1,'BlockType','Outport','Name',name);
    hblk=hblk2{1};
end
