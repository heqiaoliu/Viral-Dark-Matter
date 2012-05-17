function hblk = interpcommutator(hTar, name, N, qparam, dspblklibname,render)
%INTERPCOMMUTATOR Add a Interpolation Commutator (N->1) block to the model.
%   HBLK = INTERPCOMMUTATOR(HTAR, NAME, N) adds a interpolation commutator
%   (N->1) block named NAME, sets its input number to N and returns a
%   handle HBLK to the block.   DSPBLKLIBNAME specifies the signal
%   processing toolbox so that upsample can be realized
%

% Copyright 2004-2008 The MathWorks, Inc.

error(nargchk(5,6,nargin,'struct'));

if nargin<6
    render=true;
end

if ~render  % then do not generate the InterpCommutator subsystem
    return
end

sys = hTar.system;
idx = findstr(sys, '/');
set_param(0,'CurrentSystem',sys(1:idx(end)-1));

hTarInterpCommutator = dspfwiztargets.realizemdltarget;
hTarInterpCommutator.destination = 'current';
idx = findstr(sys,'/');
if length(idx) == 1
    blockpath = hTar.blockname;
else
    blockpath = sys(idx(end)+1:end);
end

hTarInterpCommutator.blockname = [blockpath '/' name];
pos = createmodel(hTarInterpCommutator);
hsubsys = add_block('built-in/subsystem',hTarInterpCommutator.system,'Tag','FilterWizardInterpolatorCommutator');
set_param(hsubsys,'Position',pos);
subsys = hTarInterpCommutator.system;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% realize the commutator
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ischar(N)
    N = str2double(N);
end

N_str = num2str(N);

p = positions;

% counter limited
blkname = 'ringcounter';
hblk = hTarInterpCommutator.counterlimited(blkname,num2str(N-1));
set_param(hblk,'Position',[185 35 215 65]);

% multiple switch
blkname = 'multiswitch';
hblk = hTarInterpCommutator.multiportswitch(blkname,N_str,'on');
set_param(hblk,'Position',[280 30 370 N*min(100,32000/N)+100+30]);
add_line(subsys,'ringcounter/1','multiswitch/1','autorouting','on');



% inputs and upsamplers
for m = 1:N
    inblkname = ['input',num2str(m)];
    hblk = hTarInterpCommutator.inport(inblkname,qparam);
    set_param(hblk,'Position',inportpos(m,p,N));
    upblkname = ['upsamp',num2str(m)];
    hblk = hTarInterpCommutator.upsample(upblkname,N_str,dspblklibname);
    set_param(hblk,'Position',upsamplepos(m,p,N));
    add_line(subsys,[inblkname '/1'],[upblkname '/1'],'autorouting','on');
    if m==1
        add_line(subsys,[upblkname '/1'],['multiswitch/',num2str(m+1)],'autorouting','on');
    else
        delayblkname = ['delay',num2str(m-1)];
        hblk = hTarInterpCommutator.delay(delayblkname,num2str(m-1));
        set_param(hblk,'Position',delaypos(m,p,N));
        add_line(subsys,[upblkname '/1'],[delayblkname '/1'],'autorouting','on');
        add_line(subsys,[delayblkname '/1'],['multiswitch/',num2str(m+1)],'autorouting','on');
    end
end

% output
blkname = 'output';
hblk = outport(hTarInterpCommutator,blkname);
set_param(hblk,'Position',[435 min(50,32000/N)*N+35 465 min(50,32000/N)*N+65]);
add_line(subsys,'multiswitch/1','output/1','autorouting','on');

% ------------------------------
%       Utility functions
% ------------------------------

function p = positions

p.input = [-15 -8 15 8];
p.upsample = [-15 -15 15 15];
p.delay = [-15 -15 15 15];

function pos = inportpos(stage,p,N)
pos = min(100,32000/N)*[0 stage 0 stage]+[50 50 50 50]+p.input;

function pos = upsamplepos(stage,p,N)
pos = min(100,32000/N)*[0 stage 0 stage]+[120 50 120 50]+p.upsample;

function pos = delaypos(stage,p,N)
pos = min(100,32000/N)*[0 stage 0 stage]+[200 50 200 50]+p.delay;

