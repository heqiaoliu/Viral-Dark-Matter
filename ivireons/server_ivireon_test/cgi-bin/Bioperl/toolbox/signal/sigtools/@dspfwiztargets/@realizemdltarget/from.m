function hblk = from(hTar, name, gototag, render)
%FROM Add a From block to the model.

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:32 $

error(nargchk(3,4,nargin,'struct'));

sys = hTar.system;

if nargin<4
    render=true;
end

if render
    hblk = add_block('built-in/From', [hTar.system '/' name]);
    set_param(hblk, 'GotoTag', gototag);
else % do not add block just update
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','From','Name',name);
    hblk=hblk1{1};
end
