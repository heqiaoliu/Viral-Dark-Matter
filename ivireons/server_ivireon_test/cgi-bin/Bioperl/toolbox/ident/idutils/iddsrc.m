function [Ts,TimeUnit,dataname]=iddsrc(CB,z)
% Mask initialization code for IDDATA source block in SLIDENT library.

% Copyright 2000-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $  $Date: 2008/10/02 18:51:28 $

if ~isa(z,'iddata') || ~strcmpi(z.Domain,'time')
    ctrlMsgUtils.error('Ident:simulink:iddataCheck1')
end

Ts=z.Ts;
if iscell(Ts)
    ctrlMsgUtils.error('Ident:simulink:iddataCheck2')
end
TimeUnit=z.TimeUnit;
if isempty(TimeUnit),
    TimeUnit = 'sec';
end
if lower(TimeUnit(1))=='m',
    Ts = Ts*60;
elseif  lower(TimeUnit(1))=='h',
    Ts = Ts*3600;
end

%{
inters = pvget(z,'InterSample');
if length(unique(inters))>1
    error('Ident:simulink:iddataCheck3',...
        'All inputs must have the same intersample behavior in the IDDATA object used as the data source.')
end
%}

porty = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','y');
portu = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','u');
[N,ny,nu]=size(z);
if nu == 0 && ~isempty(portu)
    delete_line(CB,'FromWorkspace/1','u/1');
    delete_block(portu{1})
    delete_block([CB,'/FromWorkspace'])
end
if nu>0 && isempty(portu)
    if ~isempty(porty) % This is only the get the right numbering of the ports
        delete_line(CB,'FromWorkspace1/1','y/1');
        delete_block(porty{1})
        delete_block([CB,'/FromWorkspace1'])
        porty={};
    end
    add_block('simulink/Sinks/Out1',[CB,'/u'])
    set_param([CB,'/u'],'Position','[360    43   390    57]')
    add_block('simulink/Sources/From Workspace',[CB,'/FromWorkspace']);
    %set_param(blk,'OutputAfterFinalValue','Setting to zero')
    set_param([CB,'/FromWorkspace'],'Position','[50    31   285    69]')
    set_param([CB,'/FromWorkspace'],'VariableName',...
        '[iddataobj.SamplingInstants, iddataobj.InputData]',...
        'OutputAfterFinalValue','Setting to zero')
    add_line(CB,'FromWorkspace/1','u/1');
end

if ny == 0 && ~isempty(porty)
    delete_line(CB,'FromWorkspace1/1','y/1');
    delete_block(porty{1})
    delete_block([CB,'/FromWorkspace1'])
end
if ny>0 && isempty(porty)
    add_block('simulink/Sinks/Out1',[CB,'/y'])
    set_param([CB,'/y'],'Position','[355   128   385   142]')
    add_block('simulink/Sources/From Workspace',[CB,'/FromWorkspace1']);
    set_param([CB,'/FromWorkspace1'],'Position','[50   116   285   154]')
    set_param([CB,'/FromWorkspace1'],'VariableName',...
        '[iddataobj.SamplingInstants, iddataobj.OutputData]',...
        'OutputAfterFinalValue','Setting to zero')
    add_line(CB,'FromWorkspace1/1','y/1');
end

%% Set interpolation behavior: always 'foh'
%{
blku = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','FromWorkspace');
%blky = find_system(CB,'LookUnderMasks','all','FollowLinks','on','Name','FromWorkspace1');

if ~isempty(blku)
    if strncmpi(inters,'z',1)
        set_param(blku{1},'Interpolate','off');
    else
        set_param(blku{1},'Interpolate','on');
    end
end
%}

%% Set the mask display property
MaskVal = get_param(CB,'MaskValues');
dataname = MaskVal{1};
if (ny == 0) && (nu == 0)
    maskdisplay = 'disp(dataname)';
elseif (ny == 0) && (nu ~= 0)
    maskdisplay = ['disp(dataname)',char(10),'port_label(''output'',1,''Input'')'];
elseif (ny ~= 0) && (nu == 0)
    maskdisplay = ['disp(dataname)',char(10),'port_label(''output'',1,''Output'')'];
else
    maskdisplay = ['disp(dataname)',char(10),'port_label(''output'',1,''Input'')',...
        char(10),'port_label(''output'',2,''Output'')'];
end

set_param(CB,'MaskDisplay',maskdisplay);


