function hblk = mpswitch(hTar, name,RCF,qparam, ~,render)
%MPSWITCH 
%   HBLK = DELAY(HTAR, NAME, LATENCY) adds a sum block named NAME, sets its
%   latency to LATENCY and returns a handle HBLK to the block.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:44 $

error(nargchk(5,6,nargin,'struct'));
RCF = str2num(RCF); %#ok<ST2NM>
L = RCF(1);
M = RCF(2);

phasesel = zeros(1,L);
for i = 0:L-1
    phasesel(i+1) = mod(M*i,L);
end

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
hsubsys = add_block('built-in/subsystem',hTarInterpCommutator.system,'Tag','FilterWizardSampleRateConverterCommutator');
set_param(hsubsys,'Position',pos);
subsys = hTarInterpCommutator.system;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% realize the commutator
%%%%%%%%%%%%%%%%%%%%%%%%%%%
L_str = num2str(L);

p = positions;

% counter limited
blkname = 'phaseselector';
hblk = hTarInterpCommutator.repeatingsequencestair(blkname);
set_param(hblk,'Position',[185 35 215 65]);
set_param(hblk,'OutValues',strcat('[',num2str(phasesel),']'));

% multiple switch
blkname = 'multiswitch';
hblk = hTarInterpCommutator.multiportswitch(blkname,L_str,'on');
set_param(hblk,'Position',[280 30 370 (L+1)*100+30]);
add_line(subsys,'phaseselector/1','multiswitch/1','autorouting','on');

% inputs 
for m = 1:L
    inblkname = ['input',num2str(m)]; 
    hblk = hTarInterpCommutator.inport(inblkname,qparam);
    set_param(hblk,'Position',inportpos(m,p));    
    add_line(subsys,[inblkname '/1'],['multiswitch/',num2str(m+1)],'autorouting','on');    
end

% output
blkname = 'output';
hblk = outport(hTarInterpCommutator,blkname);
set_param(hblk,'Position',[435 50*L+35 465 50*L+65]);
add_line(subsys,'multiswitch/1','output/1','autorouting','on');

% ------------------------------
%       Utility functions
% ------------------------------

function p = positions
p.input = [-15 -8 15 8];

function pos = inportpos(stage,p)
pos = 100*[0 stage 0 stage]+[50 50 50 50]+p.input;



% [EOF]
