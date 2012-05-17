function addSatWindupTracking(currentblock)

% ADDSATWINDUPTRACKING  Adds the appropriate saturation and anti-windup
% circuitry to the block diagram of the PID 1dof and PID 2dof blocks.

%   Author: Murad Abu-Khalaf, October 12, 2009
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2010/01/25 22:57:48 $

blkH = handle(currentblock);
blk = getfullname(currentblock);

isTrackingmode = find_system(blk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','all','Name','TR');

if strcmp(blkH.MaskType,'PID 1dof')
    posSumI2        = [550   190   570   210];
    posSumI3        = [550   360   570   380];
    posSumI1        = [170   110   200   140];
    posKb           = [465   185   495   215];
    posKt           = [465   355   495   385];
    posSaturation   = [545   110   575   140];
    posConstant     = [210    60   230    80];
    posSwitch       = [260    87   290   133];
    posClamping     = [165   161   245   199];
    outStr = 'y';
elseif strcmp(blkH.MaskType,'PID 2dof')
    posSumI2        = [655   190   675   210];
    posSumI3        = [655   350   675   370];
    posSumI1        = [285   110   315   140];
    posKb           = [565   185   595   215];
    posKt           = [565   345   595   375];
    posSaturation   = [675   110   705   140];
    posConstant     = [360    55   380    75];
    posSwitch       = [385    87   415   133];
    posClamping     = [280   176   360   214];
    outStr = 'u';
else
    error('Unknown MaskType');
end

% Add saturation if requested
if strcmp(blkH.LimitOutput,'on')
    h = handle(get_param([blk '/' outStr],'handle'));
    Src = h.PortConnectivity(1).SrcBlock;
    Src = handle(Src);
    Srcname = Src.Name;
    delete_line(blk,[Srcname '/1'],[outStr '/1']);
    add_block('built-in/Saturation',[blk '/Saturation'],'Position',posSaturation);
    add_line(blk,'Saturation/1',[outStr '/1']);
    add_line(blk,[Srcname '/1'],'Saturation/1');
end

%  Connect the ARW & Tracking mode loops
if ~(strcmp(blkH.Controller,'P') || strcmp(blkH.Controller,'PD'))
    if strcmp(blkH.LimitOutput,'on') &&  strcmp(blkH.AntiWindupMode,'back-calculation')
        add_block('built-in/Sum',[blk '/SumI2'],'Position',posSumI2,'IconShape', 'round','Orientation','left','Inputs', '-+|');
        add_block('built-in/Gain',[blk '/Kb'],'Position',posKb,'Orientation','left');
        add_line(blk,'SumI2/1','Kb/1','autorouting','on');
        h = handle(get_param([blk '/' outStr],'handle'));
        Src = h.PortConnectivity(1).SrcBlock;
        Src = handle(Src);
        Srcname = Src.Name;
        add_line(blk,[Srcname '/1'],'SumI2/2','autorouting','on');
        h = handle(get_param([blk '/Saturation'],'handle'));
        Src = h.PortConnectivity(1).SrcBlock;
        Src = handle(Src);
        Srcname = Src.Name;
        add_line(blk,[Srcname '/1'],'SumI2/1','autorouting','on');
        add_block('built-in/Sum',[blk '/SumI1'],'Position',posSumI1,'IconShape', 'round','Inputs','|++');
        add_line(blk,'Kb/1','SumI1/2','autorouting','on');
        delete_line(blk,'Integral Gain/1','Integrator/1');
        add_line(blk,'SumI1/1','Integrator/1','autorouting','on');
        add_line(blk,'Integral Gain/1','SumI1/1','autorouting','on');
    end
    if strcmp(blkH.LimitOutput,'on') &&  strcmp(blkH.AntiWindupMode,'clamping')
        pidpack.PIDConfig.addClampingSubsystem(currentblock,posClamping)
        add_block('built-in/Switch',[blk '/Switch'],'Position',posSwitch,'Orientation','right');
        add_block('built-in/Constant',[blk '/Constant'],'Position',posConstant,'Orientation','down');
        
        h = handle(get_param([blk '/Saturation'],'handle'));
        Src = h.PortConnectivity(1).SrcBlock;
        Src = handle(Src);
        Srcname = Src.Name;
        add_line(blk,[Srcname '/1'],'Clamping circuit/1','autorouting','on');
        
        h = handle(get_param([blk '/' outStr],'handle'));
        Src = h.PortConnectivity(1).SrcBlock;
        Src = handle(Src);
        Srcname = Src.Name;
        add_line(blk,[Srcname '/1'],'Clamping circuit/2','autorouting','on');
        
        h = handle(get_param([blk '/Integrator'],'handle'));
        Src = h.PortConnectivity(1).SrcBlock;
        Src = handle(Src);
        Srcname = Src.Name;
        add_line(blk,[Srcname '/1'],'Clamping circuit/3','autorouting','on');
        
        add_line(blk,'Constant/1','Switch/1','autorouting','on');
        add_line(blk,'Clamping circuit/1','Switch/2','autorouting','on');
        delete_line(blk,[Srcname '/1'],'Integrator/1');
        add_line(blk,[Srcname '/1'],'Switch/3','autorouting','on');
        add_line(blk,'Switch/1','Integrator/1','autorouting','on');
        
        if strcmp(blkH.Form,'Ideal')
            h = handle(get_param([blk '/Proportional Gain'],'handle'));
            Src = h.PortConnectivity(1).SrcBlock;
            Src = handle(Src);
            Srcname = Src.Name;
            add_line(blk,[Srcname '/1'],'Clamping circuit/4','autorouting','on');
        end
        
    end
end
if ~isempty(isTrackingmode) % Check for errors by verifying that strcmp(blkH.TrackingMode,'on'), maybe for P control
    add_block('built-in/Sum',[blk '/SumI3'],'Position',posSumI3,'IconShape', 'round','Orientation','left','Inputs', '-+|');
    add_block('built-in/Gain',[blk '/Kt'],'Position',posKt,'Orientation','left');
    add_line(blk,'SumI3/1','Kt/1','autorouting','on');
    h = handle(get_param([blk '/' outStr],'handle'));
    Src = h.PortConnectivity(1).SrcBlock;
    Src = handle(Src);
    Srcname = Src.Name;
    add_line(blk,[Srcname '/1'],'SumI3/1','autorouting','on');
    add_line(blk,'TR/1','SumI3/2','autorouting','on');
    if strcmp(blkH.LimitOutput,'off') || strcmp(blkH.AntiWindupMode,'none')
        add_block('built-in/Sum',[blk '/SumI1'],'Position',posSumI1,'IconShape', 'round','Inputs','|++');
        add_line(blk,'Kt/1','SumI1/2','autorouting','on');
        delete_line(blk,'Integral Gain/1','Integrator/1');
        add_line(blk,'SumI1/1','Integrator/1','autorouting','on');
        add_line(blk,'Integral Gain/1','SumI1/1','autorouting','on');
    elseif strcmp(blkH.LimitOutput,'on') &&  strcmp(blkH.AntiWindupMode,'back-calculation')
        set_param([blk '/SumI1'], 'Inputs', '||+++');
        add_line(blk,'Kt/1','SumI1/3','autorouting','on');
    elseif strcmp(blkH.LimitOutput,'on') &&  strcmp(blkH.AntiWindupMode,'clamping')
        add_block('built-in/Sum',[blk '/SumI1'],'Position',posSumI1,'IconShape', 'round','Inputs','|++');
        add_line(blk,'Kt/1','SumI1/2','autorouting','on');
        delete_line(blk,'Integral Gain/1','Switch/3');
        delete_line(blk,'Integral Gain/1','Clamping circuit/3');
        add_line(blk,'Integral Gain/1','SumI1/1','autorouting','on');
        add_line(blk,'SumI1/1','Switch/3','autorouting','on');
        add_line(blk,'SumI1/1','Clamping circuit/3','autorouting','on');
    end
end

end
