function hblk = downsample(hTar, name, N, libname,phase,render)
%DOWNSAMPLE Add a Downsample block to the model.
%   HBLK = DOWNSAMPLE(HTAR, NAME, N, LIBNAME, PHASE) adds a sum block named
%   NAME, and sets its downsample number to N, phase to the specified phase
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/06/10 14:34:19 $

error(nargchk(4,6,nargin,'struct'));

sys = hTar.system;

if nargin<6
    render=true;
end

if render
    hblk = add_block([libname '/Downsample'], [hTar.system '/' name], 'N', N); % add block
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','S-Function','Name',name); % Do not add block
    hblk=hblk1{1};
end

set_param(hblk,'InputProcessing','Inherited (this choice will be removed - see release notes)');
set_param(hblk,'smode','Allow multirate');
set_param(hblk,'fmode','Maintain input frame size');

if nargin > 4 && ~isempty(phase)
    set_param(hblk,'phase',phase);
end

%will hard error if dspblks are
