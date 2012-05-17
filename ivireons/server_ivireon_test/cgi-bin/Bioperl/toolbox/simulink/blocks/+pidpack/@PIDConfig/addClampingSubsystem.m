function addClampingSubsystem(currentblock,posClamping)

% ADDCLAMPINGSUBSYSTEM  Adds the clamping logic circuit to be used with
% clamping based anti-windup implemented by the PID 1dof and PID 2dof blocks.

%   Author: Murad Abu-Khalaf, October 12, 2009
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2010/01/25 22:57:44 $

blkH = handle(currentblock);
blk = getfullname(currentblock);
sys = [blk '/Clamping circuit'];

commonLogicalOperator = {'AllPortsSameDT', 'on','OutDataTypeStr','boolean',...
    'SampleTime','-1','DisableCoverage','on'};

commonRelationalOperator = {'InputSameDT', 'on',...
    'OutDataTypeStr','boolean','ZeroCross',blkH.ZeroCross,...
    'SampleTime','-1','DisableCoverage','on'};

commonSignum = {'ZeroCross',blkH.ZeroCross,'SampleTime','-1','DisableCoverage','on'};

% Parallel
if strcmp(blkH.Form,'Parallel')
    
    posClampPort            = [25    103   55    117];
    posPreSatPort           = [345   43    375   57 ];
    posPostSatPort          = [345   98    375   112];
    posPreIntegratorPort    = [345   143   375   157];
    
    posSignPreSat           = [280    38   295    62];
    posNotEqual             = [280    89   300   111];
    posSignPreIntegrator    = [285   137   300   163];
    
    posEqual                = [175   106   200   124];
    
    posAnd                  = [125    90   155   125];
    
    posMemory               = [75    99   100   121];
    
    add_block('built-in/Subsystem',sys,'Position',posClamping,'Orientation','left');
    add_block('built-in/Inport', [sys '/preSat'],'Position',posPreSatPort,'Orientation','left');
    add_block('built-in/Inport', [sys '/postSat'],'Position',posPostSatPort,'Orientation','left');
    add_block('built-in/Inport', [sys '/preIntegrator'],'Position',posPreIntegratorPort,'Orientation','left');
    add_block('built-in/Outport',[sys '/Clamp'],'Position',posClampPort,'Orientation','left');
    
    add_block('built-in/Signum',[sys '/SignPreIntegrator'],'Position',posSignPreIntegrator,commonSignum{:},'Orientation','left');
    add_block('built-in/Signum',[sys '/SignPreSat'],'Position',posSignPreSat,commonSignum{:},'Orientation','left');
    add_block('built-in/RelationalOperator',[sys '/Equal'],'Position',posEqual,commonRelationalOperator{:},'Orientation','left','Operator','==');
    add_block('built-in/RelationalOperator',[sys '/NotEqual'],'Position',posNotEqual,commonRelationalOperator{:},'Orientation','left','Operator','~=');
    add_block('built-in/Logic',[sys '/AND'],'Position',posAnd,commonLogicalOperator{:},'Orientation','left');
    
    add_line(sys,'preSat/1','SignPreSat/1','autorouting','on');
    add_line(sys,'preSat/1','NotEqual/1','autorouting','on');
    add_line(sys,'postSat/1','NotEqual/2','autorouting','on');
    add_line(sys,'preIntegrator/1','SignPreIntegrator/1','autorouting','on');
    
    add_line(sys,'SignPreSat/1','Equal/1','autorouting','on');
    add_line(sys,'NotEqual/1','AND/1','autorouting','on');
    add_line(sys,'SignPreIntegrator/1','Equal/2','autorouting','on');
    
    add_line(sys,'Equal/1','AND/2','autorouting','on');
    
    if strcmp(blkH.TimeDomain,'Continuous-time')
        add_block('built-in/Memory',[sys '/Memory'],'Position',posMemory,'Orientation','left');
        add_line(sys,'AND/1','Memory/1','autorouting','on');
        add_line(sys,'Memory/1','Clamp/1','autorouting','on');
    else
        add_line(sys,'AND/1','Clamp/1','autorouting','on');
    end
    
    % Ideal
elseif strcmp(blkH.Form,'Ideal')
    
    posClampPort            = [ 15    98    45   112];
    posPreSatPort           = [555    33   585    47];
    posPostSatPort          = [555    88   585   102];
    posPreIntegratorPort    = [555   143   585   157];
    posPrePPort             = [555   233   585   247];
    
    posSignPreSat           = [485    28   500    52];
    posNotEqual             = [485    79   505   101];
    posSignPreIntegrator    = [485   137   500   163];
    posSignPreP             = [485   228   500   252];
    
    posEqual1               = [395   101   420   119];
    posEqual2               = [395   226   420   244];
    
    posNOT1                 = [330   186   360   204];
    posNOT2                 = [330   227   360   243];
    
    posAND1                 = [245   105   275   125];
    posAND2                 = [245   190   275   210];
    
    posOR                   = [190   111   215   129];
    
    posAND3                 = [140    75   165   135];
    
    posMemory               = [75    94   100   116];
    
    add_block('built-in/Subsystem',sys,'Position',posClamping,'Orientation','left');
    add_block('built-in/Inport', [sys '/preSat'],'Position',posPreSatPort,'Orientation','left');
    add_block('built-in/Inport', [sys '/postSat'],'Position',posPostSatPort,'Orientation','left');
    add_block('built-in/Inport', [sys '/preIntegrator'],'Position',posPreIntegratorPort,'Orientation','left');
    add_block('built-in/Inport', [sys '/preP'],'Position',posPrePPort,'Orientation','left');
    add_block('built-in/Outport',[sys '/Clamp'],'Position',posClampPort,'Orientation','left');
    
    add_block('built-in/Signum',[sys '/SignPreIntegrator'],'Position',posSignPreIntegrator,commonSignum{:},'Orientation','left');
    add_block('built-in/RelationalOperator',[sys '/NotEqual'],'Position',posNotEqual,commonRelationalOperator{:},'Orientation','left','Operator','~=');
    add_block('built-in/Signum',[sys '/SignPreSat'],'Position',posSignPreSat,commonSignum{:},'Orientation','left');
    add_block('built-in/Signum',[sys '/SignPreP'],'Position',posSignPreP,commonSignum{:},'Orientation','left');
    
    add_block('built-in/RelationalOperator',[sys '/Equal1'],'Position',posEqual1,commonRelationalOperator{:},'Orientation','left','Operator','==');
    add_block('built-in/RelationalOperator',[sys '/Equal2'],'Position',posEqual2,commonRelationalOperator{:},'Orientation','left','Operator','==');
    
    add_block('built-in/Logic',[sys '/NOT1'],'Position',posNOT1,commonLogicalOperator{:},'Orientation','left','Operator','NOT');
    add_block('built-in/Logic',[sys '/NOT2'],'Position',posNOT2,commonLogicalOperator{:},'Orientation','left','Operator','NOT');
    
    add_block('built-in/Logic',[sys '/AND1'],'Position',posAND1,commonLogicalOperator{:},'Orientation','left');
    add_block('built-in/Logic',[sys '/AND2'],'Position',posAND2,commonLogicalOperator{:},'Orientation','left');
    
    add_block('built-in/Logic',[sys '/OR'],'Position',posOR,commonLogicalOperator{:},'Orientation','left','Operator','OR');
    
    add_block('built-in/Logic',[sys '/AND3'],'Position',posAND3,commonLogicalOperator{:},'Orientation','left');
    
    add_line(sys,'preSat/1','SignPreSat/1','autorouting','on');
    add_line(sys,'preSat/1','NotEqual/1','autorouting','on');
    add_line(sys,'postSat/1','NotEqual/2','autorouting','on');
    add_line(sys,'preIntegrator/1','SignPreIntegrator/1','autorouting','on');
    add_line(sys,'preP/1','SignPreP/1','autorouting','on');
    
    add_line(sys,'SignPreSat/1','Equal1/1','autorouting','on');
    add_line(sys,'SignPreSat/1','Equal2/1','autorouting','on');
    
    add_line(sys,'NotEqual/1','AND3/1','autorouting','on');
    add_line(sys,'SignPreIntegrator/1','Equal1/2','autorouting','on');
    add_line(sys,'SignPreP/1','Equal2/2','autorouting','on');
    
    add_line(sys,'Equal1/1','AND1/1','autorouting','on');
    add_line(sys,'Equal1/1','NOT1/1','autorouting','on');
    add_line(sys,'Equal2/1','AND1/2','autorouting','on');
    add_line(sys,'Equal2/1','NOT2/1','autorouting','on');
    
    add_line(sys,'NOT1/1','AND2/1','autorouting','on');
    add_line(sys,'NOT2/1','AND2/2','autorouting','on');
    
    add_line(sys,'AND1/1','OR/1','autorouting','on');
    add_line(sys,'AND2/1','OR/2','autorouting','on');
    
    add_line(sys,'OR/1','AND3/2','autorouting','on');
    
    
    if strcmp(blkH.TimeDomain,'Continuous-time')
        add_block('built-in/Memory',[sys '/Memory'],'Position',posMemory,'Orientation','left');
        add_line(sys,'AND3/1','Memory/1','autorouting','on');
        add_line(sys,'Memory/1','Clamp/1','autorouting','on');
    else
        add_line(sys,'AND3/1','Clamp/1','autorouting','on');
    end
    
end

end