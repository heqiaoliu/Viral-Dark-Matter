function  hblk = fixptfracdelay(hTar,name,param,~,render)
%FIXPTFRACDELAY 


%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:30 $

error(nargchk(4,5,nargin,'struct'));

if nargin<5
    render=true;
end

if ~render              % then do not generate the Fractional Delay subsystem
    return
end

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

% Fractional Delay Generator
S = param;  
L  = S.L;                         % Interpolation Factor
M  = S.M;                         % Decimation Factor
Kstr = strcat('fixdt(0,',num2str(S.WL.K),',0)');
Mstr = strcat('fixdt(0,',num2str(S.WL.M),',0)');
diffstr = strcat('fixdt(1,',num2str(S.WL.Diff),',0)');
sumstr = strcat('fixdt(1,',num2str(S.WL.Sum),',0)');
scalestr = strcat('fixdt(0,',num2str(S.WL.Gain),',',num2str(S.FL.Gain),')');
fdstr = strcat('fixdt(0,',num2str(S.WL.FD),',',num2str(S.FL.FD),')');

decimblkname = 'DecimationFactor';
hblk = hTarFracDelay.constant(decimblkname);
set_param(hblk,'Position',[60 30 100 50]);
set_param(hblk,'Value',num2str(M,18),'OutDataTypeStr',Mstr);

compblkname = 'Threshold';
val = num2str(-S.K1,18); ops = '<=';
hblk = hTarFracDelay.comparetoconstant(compblkname,val,ops);
set_param(hblk,'Position',[60 95 100 115]);
set_param(hblk,'orientation','right');

k1blkname = 'K1';
hblk = hTarFracDelay.constant(k1blkname);
set_param(hblk,'Position',[60 135 100 155]);
set_param(hblk,'Value',num2str(S.K1,18),'OutDataTypeStr',Kstr);

k2blkname = 'K2';
hblk = hTarFracDelay.constant(k2blkname);
set_param(hblk,'Position',[60 175 100 195]);
set_param(hblk,'Value',num2str(S.K2,18),'OutDataTypeStr',Kstr);

mpsblkname = 'Multiswitch';
hblk = hTarFracDelay.multiportswitch(mpsblkname,'2','on');
set_param(hblk,'Position',[160 85 175 205]);

sumblkname = 'Sum';    
hblk = hTarFracDelay.sum(sumblkname,'++|',[]);
set_param(hblk,'Position',[230 130 260 160]);
set_param(hblk,'orientation','right','OutDataTypeStr',sumstr);

diffblkname = 'Diff';    
hblk = hTarFracDelay.sum(diffblkname,'-+|',[]);
set_param(hblk,'Position',[230 25 260 55]);
set_param(hblk,'orientation','down','OutDataTypeStr',diffstr);

delayblkname = 'Delay';
hblk = hTarFracDelay.delay(delayblkname,'1');
set_param(hblk,'Position',[310 135 350 155]);
set_param(hblk,'vinit',num2str(L,18));
set_param(hblk,'orientation','right');

scaleblkname = 'ScaleToFrac';    
hblk = hTarFracDelay.gain(scaleblkname,num2str(1/L,18),[]);
set_param(hblk,'Position',[400 130 430 160]);
set_param(hblk,'orientation','right', ...
    'ParamDataTypeStr',scalestr,'OutDataTypeStr',fdstr,...
    'RndMeth',rndmeth(S.RndMode));

blkname = 'FDelay';
hblk = outport(hTarFracDelay,blkname);
set_param(hblk,'Position',[460 137 490 153]);

add_line(subsys,[decimblkname '/1'],[diffblkname '/1'],'autorouting','on');
add_line(subsys,[diffblkname '/1'], [compblkname '/1'],'autorouting','on');
add_line(subsys,[compblkname '/1'], [mpsblkname '/1'],'autorouting','on');
add_line(subsys,[k1blkname '/1'], [mpsblkname '/2'],'autorouting','on');
add_line(subsys,[k2blkname '/1'], [mpsblkname '/3'],'autorouting','on');
add_line(subsys,[diffblkname '/1'],[sumblkname '/1'],'autorouting','on');
add_line(subsys,[mpsblkname '/1'], [sumblkname '/2'], 'autorouting','on');
add_line(subsys,[sumblkname '/1'], [delayblkname '/1'],'autorouting','on');
add_line(subsys,[delayblkname '/1'],[diffblkname '/2'],'autorouting','on');
add_line(subsys,[delayblkname '/1']',[scaleblkname '/1'],'autorouting','on');
add_line(subsys,[scaleblkname '/1']',[blkname '/1'],'autorouting','on');

%---------------------------------------------------------------------
function RndMeth = rndmeth(Roundmode)
% Convert from roundmode to RndMeth property of the block.

switch Roundmode
    case 'fix'
        RndMeth = 'Zero';
    case 'floor'
        RndMeth = 'Floor';
    case 'ceil'
        RndMeth = 'Ceiling';
    case 'round'
        RndMeth = 'Round';
    case 'convergent'
        RndMeth = 'Convergent';
    case 'nearest'
         RndMeth = 'Nearest';
end


% [EOF]
