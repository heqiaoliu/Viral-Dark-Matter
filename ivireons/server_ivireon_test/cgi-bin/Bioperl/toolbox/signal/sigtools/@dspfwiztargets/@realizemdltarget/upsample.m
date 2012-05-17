function hblk = upsample(hTar, name, N, libname,phase,render)
%UPSAMPLE Add a Upsample block to the model.
%   HBLK = UPSAMPLE(HTAR, NAME, N, LIBNAME, PHASE) adds a sum block named
%   NAME, and sets its upsample number to N, phase to the specified phase
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $  $Date: 2010/06/10 14:34:20 $

error(nargchk(4,6,nargin,'struct'));
sys = hTar.system;

if nargin<6
    render=true;
end

if render
    hblk = add_block([libname '/Upsample'], [hTar.system '/' name], 'N', N);
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','S-Function','Name',name); % Do not add block
    hblk=hblk1{1};
end

set_param(hblk,'RateOptions','Allow multirate processing');
set_param(hblk,'InputProcessing','Inherited (this choice will be removed - see release notes)');

if nargin > 4 && ~isempty(phase)
    set_param(hblk,'phase',phase);
end

%will hard error if dspblks are
