function  hblk = farrowsrccommutator(hTar, name,RCF,qparam, ~,render)
%FARROWSRCCOMMUTATOR <short description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:28 $

error(nargchk(5,6,nargin,'struct'));
RCF = str2num(RCF); %#ok<ST2NM>

L = RCF(1);
M = RCF(2);
numinput = RCF(3);

if nargin<6
    render=true;
end

if ~render  % then do not generate the FarrowSrcCommutator subsystem
    return
end

sys = hTar.system;
idx = findstr(sys, '/');
set_param(0,'CurrentSystem',sys(1:idx(end)-1));

hTarFarrowSrcCommutator = dspfwiztargets.realizemdltarget;
hTarFarrowSrcCommutator.destination = 'current';
idx = findstr(sys,'/');
if length(idx) == 1
    blockpath = hTar.blockname;
else
    blockpath = sys(idx(end)+1:end);
end

hTarFarrowSrcCommutator.blockname = [blockpath '/' name];
pos = createmodel(hTarFarrowSrcCommutator);
hsubsys = add_block('built-in/subsystem',hTarFarrowSrcCommutator.system,'Tag','FilterWizardSampleRateConverterCommutator');
set_param(hsubsys,'Position',pos);
subsys = hTarFarrowSrcCommutator.system;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% realize the commutator
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% fractional delay generator
m = 1;
sum_str = '++|';

constblkname = 'const';
hblk = hTarFarrowSrcCommutator.constant(constblkname);
set_param(hblk,'Position',inportpos(m)-[250 200 250 200]);
set_param(hblk,'Value',num2str(M/L,18));

sumblkname = ['sum',num2str(numinput+1)];    
hblk = hTarFarrowSrcCommutator.sum(sumblkname,sum_str,qparam);
set_param(hblk,'Position',inportpos(m)-[150 200 150 200]);
set_param(hblk,'orientation','right');

funblkname = 'modfun';    
hblk = hTarFarrowSrcCommutator.mathfun(funblkname);
set_param(hblk,'Position',inportpos(m)-[50 150 50 150]);
set_param(hblk,'Operator','mod');
set_param(hblk,'orientation','right');

delayblkname = 'delay';
hblk = hTarFarrowSrcCommutator.delay(delayblkname,'1');
set_param(hblk,'Position',inportpos(m)-[-25 150 -25 150]);
set_param(hblk,'orientation','right');

constblkname1 = 'const1';
hblk = hTarFarrowSrcCommutator.constant(constblkname1);
set_param(hblk,'Position',inportpos(m)-[250 100 250 100]);
set_param(hblk,'Value','1');

constblkname2 = 'const2';
hblk = hTarFarrowSrcCommutator.constant(constblkname2);
set_param(hblk,'Position',inportpos(m)-[50 50 50 50]);
set_param(hblk,'Value','1');

sumblkname1 = ['sum',num2str(numinput+2)];    
hblk = hTarFarrowSrcCommutator.sum(sumblkname1,'-+|',qparam);
set_param(hblk,'Position',inportpos(m)-[-50 50 -50 50]);
set_param(hblk,'orientation','right');

add_line(subsys,[constblkname2 '/1'],[sumblkname1 '/2'],'autorouting','on');
add_line(subsys,[delayblkname '/1'],[sumblkname1 '/1'],'autorouting','on');
add_line(subsys,[constblkname '/1'],[sumblkname '/2'],'autorouting','on');
add_line(subsys,[delayblkname '/1'],[sumblkname '/1'],'autorouting','on');
add_line(subsys,[constblkname1 '/1'],[funblkname '/2'],'autorouting','on');
add_line(subsys,[sumblkname '/1'],[funblkname '/1'],'autorouting','on');
add_line(subsys,[funblkname '/1'],[delayblkname '/1'],'autorouting','on');

%%
m = 1;

inblkname = ['input',num2str(m)];
hblk = hTarFarrowSrcCommutator.inport(inblkname,qparam);
set_param(hblk,'Position',inportpos(m)+[-250 5 -250 5]);

multblkname = ['mult',num2str(m)];
hblk = hTarFarrowSrcCommutator.mult(multblkname,'2',qparam);
set_param(hblk,'Position',multpos(m)+[100 0 100 0]);
add_line(subsys,[inblkname '/1'],[multblkname '/2'],'autorouting','on');

for m = 2:numinput-1
    inblkname = ['input',num2str(m)];
    hblk = hTarFarrowSrcCommutator.inport(inblkname,qparam);
    set_param(hblk,'Position',inportpos(m)+[-250 0 -250 0]);
    
    sumblkname = ['sum',num2str(m)];      
    hblk = hTarFarrowSrcCommutator.sum(sumblkname,sum_str,qparam);
    set_param(hblk,'Position',sumpos(m));
    set_param(hblk,'orientation','right');
    
    multblkname_1 = ['mult',num2str(m-1)]; 
    multblkname = ['mult',num2str(m)]; 
    hblk = hTarFarrowSrcCommutator.mult(multblkname,'2',qparam);
    set_param(hblk,'Position',multpos(m)+[100 -5 100 -5]);
    
    add_line(subsys,[inblkname '/1'],[sumblkname '/2'],'autorouting','on');
    add_line(subsys,[multblkname_1 '/1'],[sumblkname '/1'],'autorouting','on');
    add_line(subsys,[sumblkname '/1'],[multblkname '/2'],'autorouting','on');
end
    
m = numinput;
inblkname = ['input',num2str(m)];
hblk = hTarFarrowSrcCommutator.inport(inblkname,qparam);
set_param(hblk,'Position',inportpos(m)+[-250 0 -250 0]);

sumblkname = ['sum',num2str(m)];
hblk = hTarFarrowSrcCommutator.sum(sumblkname,sum_str,qparam);
set_param(hblk,'Position',sumpos(m)+[15 0 15 0]);

add_line(subsys,[inblkname '/1'],[sumblkname '/2'],'autorouting','on');
add_line(subsys,[multblkname '/1'],[sumblkname '/1'],'autorouting','on');

% output
blkname = 'output';
hblk = outport(hTarFarrowSrcCommutator,blkname);
set_param(hblk,'Position',multpos(numinput)+[150 0 150 0]);
add_line(subsys,[sumblkname '/1']','output/1','autorouting','on');


for m = 1:numinput-1
    multblkname = ['mult',num2str(m)];
%    add_line(subsys,[delblkname '/1'],[multblkname '/1'],'autorouting','on');
    add_line(subsys,[sumblkname1 '/1'],[multblkname '/1'],'autorouting','on');
end

% ------------------------------
%       Utility functions
% ------------------------------

function pos = inportpos(stage)
pos = 100*[0 stage 0 stage]+[300 170 300 170]+[-20 -10 20 10];

function pos = sumpos(stage)
pos = inportpos(stage)+(stage)*[50 0 50 0];

function pos = multpos(stage)
pos = inportpos(stage)+(stage)*[100 0 100 0];


% [EOF]
