function hblk = firsrccommutator(hTar, name,RCF,qparam, ~,render)
%FIRSRCCOMMUTATOR Add a firsrc commutator to model


%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:29 $


error(nargchk(5,6,nargin,'struct'));

RCF = str2num(RCF); %#ok<ST2NM>
L = RCF(1);             % Interpolation Factor
M = RCF(2);             % Decimation Factor

% Determine the order of phase selection
phasesel = zeros(1,L);
for i = 0:L-1
    phasesel(i+1) = mod(M*i,L);
end

% This argument is enables tuning of model parameters when running the
% model
if nargin<6
    render=true;
end

if ~render  % then do not generate the FirsrcCommutator subsystem
    return
end

sys = hTar.system;
idx = findstr(sys, '/');
set_param(0,'CurrentSystem',sys(1:idx(end)-1));

hTarFirsrcCommutator = dspfwiztargets.realizemdltarget;
hTarFirsrcCommutator.destination = 'current';
idx = findstr(sys,'/');
if length(idx) == 1
    blockpath = hTar.blockname;
else
    blockpath = sys(idx(end)+1:end);
end

p = positions;

hTarFirsrcCommutator.blockname = [blockpath '/' name];
pos = createmodel(hTarFirsrcCommutator);
hsubsys = add_block('built-in/subsystem',hTarFirsrcCommutator.system,'Tag','FilterWizardSampleRateConverterCommutator');
set_param(hsubsys,'Position',pos);
subsys = hTarFirsrcCommutator.system;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% realize the commutator
%%%%%%%%%%%%%%%%%%%%%%%%%%%
L_str = num2str(L);

% repeating sequence
blkname = 'phaseselector';
hblk = hTarFirsrcCommutator.repeatingsequencestair(blkname);
set_param(hblk,'Position',[185 35 215 65]);
set_param(hblk,'OutValues',strcat('[',num2str(phasesel),']'));

% multi-port switch
blkname = 'multiswitch';
hblk = hTarFirsrcCommutator.multiportswitch(blkname,L_str,'on');
set_param(hblk,'Position',[280 30 370 L*min(100,32000/L)+100+30]);
add_line(subsys,'phaseselector/1','multiswitch/1','autorouting','on');

% inputs 
for m = 1:L
    inblkname = ['input',num2str(m)]; 
    hblk = hTarFirsrcCommutator.inport(inblkname,qparam);
    set_param(hblk,'Position',inportpos(m,p,L));    
    add_line(subsys,[inblkname '/1'],['multiswitch/',num2str(m+1)],'autorouting','on');    
end

% output
blkname = 'output';
hblk = outport(hTarFirsrcCommutator,blkname);
set_param(hblk,'Position',[435 50*L+35 465 50*L+65]);
add_line(subsys,'multiswitch/1','output/1','autorouting','on');


% ------------------------------
%       Utility functions
% ------------------------------

function p = positions
p.input = [-15 -8 15 8];

function pos = inportpos(stage,p,N)
pos = min(32000/N,100)*[0 stage 0 stage]+[50 50 50 50]+p.input;

% [EOF]
