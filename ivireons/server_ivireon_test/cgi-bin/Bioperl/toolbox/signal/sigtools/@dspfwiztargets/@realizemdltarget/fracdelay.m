function  hblk = fracdelay(hTar, name,RCF,qparam, ~,render)
%FRACDELAY 


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:31 $

error(nargchk(5,6,nargin,'struct'));

if nargin<6
    render=true;
end

if ~render  % then do not generate the Fractional Delay subsystem
    return
end

RCF = str2num(RCF); %#ok<ST2NM>

L = RCF(1);
M = RCF(2);

sys = hTar.system;
idx = findstr(sys, '/');
set_param(0,'CurrentSystem',sys(1:idx(end)-1));

hTarFracDelay = dspfwiztargets.realizemdltarget;
hTarFracDelay.destination = 'current';
idx = findstr(sys,'/');
if length(idx) == 1
    blockpath = hTar.blockname;
else
    blockpath = sys(idx(end)+1:end);
end

hTarFracDelay.blockname = [blockpath '/' name];
pos = createmodel(hTarFracDelay);
hsubsys = add_block('built-in/subsystem',hTarFracDelay.system,'Tag','FilterWizardFractionalDelay');
set_param(hsubsys,'Position',pos);
subsys = hTarFracDelay.system;

%% fractional delay generator

constblkname = 'RateChangeFactor';
hblk = hTarFracDelay.constant(constblkname);
set_param(hblk,'Position',inportpos(1)-[250 155 250 155]);
set_param(hblk,'Value',num2str(M/L+eps,18));

sumblkname = 'Tnext';    
hblk = hTarFracDelay.sum(sumblkname,'++|',qparam);
set_param(hblk,'Position',inportpos(1)-[150 155 150 155]);
set_param(hblk,'orientation','right');

funblkname = 'Modfun';    
hblk = hTarFracDelay.mathfun(funblkname);
set_param(hblk,'Position',inportpos(1)-[50 150 50 150]);
set_param(hblk,'Operator','mod');
set_param(hblk,'orientation','right');

constblkname1 = 'Unit';
hblk = hTarFracDelay.constant(constblkname1);
set_param(hblk,'Position',inportpos(1)-[250 100 250 100]);
set_param(hblk,'Value',num2str(1,18));

delayblkname = 'Delay';
hblk = hTarFracDelay.delay(delayblkname,'1');
set_param(hblk,'Position',inportpos(1)-[-25 150 -25 150]);
set_param(hblk,'orientation','right');

compblkname = 'CompareThreshold';
val = num2str(1-eps,18); ops = '<';
hblk = hTarFracDelay.comparetoconstant(compblkname,val,ops);
set_param(hblk,'Position',inportpos(1)-[-100 150 -100 150]);
set_param(hblk,'orientation','right');

mpsblkname = 'Multiswitch';
hblk = hTarFracDelay.multiportswitch(mpsblkname,'2','on');
set_param(hblk,'Position',inportpos(1)-[-200 150 -225 50]);

constblkname2 = 'One';
hblk = hTarFracDelay.constant(constblkname2);
set_param(hblk,'Position',inportpos(1)-[-300 50 -300 50]);
set_param(hblk,'Value',num2str(1,18));

constblkname3 = 'Zero';
hblk = hTarFracDelay.constant(constblkname3);
set_param(hblk,'Position',inportpos(1)-[-100 100 -100 100]);
set_param(hblk,'Value',num2str(0,18));

sumblkname1 = 'Sum';    
hblk = hTarFracDelay.sum(sumblkname1,'-+|',qparam);
set_param(hblk,'Position',inportpos(1)-[-375 50 -375 50]);
set_param(hblk,'orientation','right');

blkname = 'FDelay';
hblk = outport(hTarFracDelay,blkname);
set_param(hblk,'Position',inportpos(1)+[450 -50 450 -50]);

add_line(subsys,[constblkname '/1'],[sumblkname '/2'],'autorouting','on');
add_line(subsys,[mpsblkname '/1'], [sumblkname '/1'], 'autorouting','on');
add_line(subsys,[sumblkname '/1'],[funblkname '/1'],'autorouting','on');

add_line(subsys,[constblkname1 '/1'],[funblkname '/2'],'autorouting','on');
add_line(subsys,[funblkname '/1'],[delayblkname '/1'],'autorouting','on');

add_line(subsys,[delayblkname '/1'],[compblkname '/1'],'autorouting','on');
add_line(subsys,[compblkname '/1'], [mpsblkname '/1'],'autorouting','on');
add_line(subsys,[constblkname3 '/1'],[mpsblkname '/2'],'autorouting','on');
add_line(subsys,[delayblkname '/1'],[mpsblkname '/3'],'autorouting','on');

add_line(subsys,[mpsblkname '/1'], [sumblkname1 '/1'], 'autorouting','on');
add_line(subsys,[constblkname2 '/1'],[sumblkname1 '/2'],'autorouting','on');
add_line(subsys,[sumblkname1 '/1']',[blkname '/1'],'autorouting','on');

% ------------------------------
%       Utility functions
% ------------------------------

function pos = inportpos(stage)
pos = 100*[0 stage 0 stage]+[300 170 300 170]+[-20 -10 20 10];

% [EOF]
