function drawdiagram(LoopData)
%DRAWDIAGRAM  Draws Simulink diagram for SISO Tool feedback loop.

%   Author(s): K. Gondoly and P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.11.4.9 $  $Date: 2010/05/10 16:58:58 $

%---Check if the User has Simulink
if license('test', 'SIMULINK')
    Answer = questdlg(...
        {'Before the diagram can be drawn, the plant and '
        'compensator data must be exported to the workspace.'
        ' '
        'The data will be stored in the variable names used' 
        'in the SISO Tool and may overwrite data currently '
        'in the Workspace.'
        ' '
        'Do you wish to continue?'},...
       xlate('Drawing Simulink Diagrams'),xlate('Yes'),xlate('No'),xlate('Yes'));
    if strcmp(Answer,xlate('Yes'))
        LocalDrawDiagram(LoopData)
    end
else
    WarnStr = {'Simulink must be included in your MATLAB path before',...
            'requesting a Simulink diagram of the closed-loop system'};
    warndlg(WarnStr,'SISO Tool Warning');
end 

%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDrawDiagram %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDrawDiagram(LoopData)

% Find adequate name for new diagram
AllDiagrams = find_system('Type','block_diagram');
% name must be a valid function name
DiagramName = strrep(LoopData.Name,' ','_'); %remove  spaces
DiagramName = strrep(DiagramName,')',''); % Remove (
DiagramName = strrep(DiagramName,'(',''); % Remove )
if ~isvarname(DiagramName)
    DiagramName = 'untitled';
end
if ~isempty(AllDiagrams)
   %---Look first for an exact match
   ExactMatch = strmatch(DiagramName,AllDiagrams,'exact');
   if ~isempty(ExactMatch)
      DiagramName = sprintf('%s_',DiagramName);
      % Look for an available name of the form DiagramName_xxx
      UsedInds = strmatch(DiagramName,AllDiagrams);
      if ~isempty(UsedInds)
         %---Look for minimum available number to use
         UsedNames = strvcat(AllDiagrams{UsedInds});
         %---Weed out names that don't end in scalar values.
         strVals = real(UsedNames(:,length(DiagramName)+1:end));
         strVals(find(strVals(:,1)<48 | strVals(:,1)>57),:)=[];
         RealVals = zeros(size(strVals,1),1);
         for ctR=1:size(strVals,1),
            RealVals(ctR,1) = str2double(char(strVals(ctR,:)));
         end
         if ~isnan(RealVals),
            NextInd = setdiff(1:max(RealVals)+1,RealVals);
            NextInd = NextInd(1);
         else
            NextInd=1;
         end
      else
         NextInd=1;
      end % if/else isempty(UsedInds)
      DiagramName = sprintf('%s%d',DiagramName,NextInd);
   end % if ~isempty(ExactMatch)
end % if ~isempty(AllDiagrams)

%---Open New Simulink diagram
NewDiagram = new_system;
set_param(NewDiagram,'Name',DiagramName);

% Write model data in workspace
NominalModelIdx = LoopData.Plant.getNominalModelIndex;
assignin('base',LoopData.Plant.G(1).Name,LoopData.Plant.G(1).Model(:,:,NominalModelIdx));
assignin('base',LoopData.Plant.G(2).Name,LoopData.Plant.G(2).Model(:,:,NominalModelIdx));
assignin('base',LoopData.C(2).Name,utCreateLTI(zpk(LoopData.C(2))));
assignin('base',LoopData.C(1).Name,utCreateLTI(zpk(LoopData.C(1))));

%---Open CSTBLOCKS, if not already open
BlockOpenFlag = find_system('Name','cstblocks');
if isempty(BlockOpenFlag)
   load_system('cstblocks');
end

switch LoopData.getconfig
    case {1,2,3,4}
        CompBlock = add_block('cstblocks/LTI System',[DiagramName,'/Compensator']);
        set_param(CompBlock,'MaskValueString',[LoopData.C(1).Name,'|[]']);
        InBlock = add_block('built-in/SignalGenerator',[DiagramName,'/Input']);
        OutBlock = add_block('built-in/Scope',[DiagramName,'/Output']);
        SumBlock = add_block('built-in/Sum',[DiagramName,'/Sum']);
        PlantBlock = add_block('cstblocks/LTI System',[DiagramName,'/Plant']);
        set_param(PlantBlock,'MaskValueString',[LoopData.Plant.G(1).Name,'|[]']);
        SensorBlock = add_block('cstblocks/LTI System',[DiagramName,'/Sensor Dynamics']);
        set_param(SensorBlock,'MaskValueString',[LoopData.Plant.G(2).Name,'|[]']);
        FilterBlock = add_block('cstblocks/LTI System',[DiagramName,'/Feed Forward']);
        set_param(FilterBlock,'MaskValueString',[LoopData.C(2).Name,'|[]']);
    case 5
        assignin('base',LoopData.Plant.G(3).Name,LoopData.Plant.G(3).Model(:,:,NominalModelIdx));
        CompBlock = add_block('cstblocks/LTI System',[DiagramName,'/Compensator']);
        set_param(CompBlock,'MaskValueString',[LoopData.C(1).Name,'|[]']);
        FilterBlock = add_block('cstblocks/LTI System',[DiagramName,'/Feed Forward']);
        set_param(FilterBlock,'MaskValueString',[LoopData.C(2).Name,'|[]']);
        InBlock = add_block('built-in/SignalGenerator',[DiagramName,'/Input']);
        InBlock2 = add_block('built-in/SignalGenerator',[DiagramName,'/Input2']);
        OutBlock = add_block('built-in/Scope',[DiagramName,'/Output']);
        SumBlock = add_block('built-in/Sum',[DiagramName,'/Sum']);
        PlantBlock1 = add_block('cstblocks/LTI System',[DiagramName,'/Plant']);
        set_param(PlantBlock1,'MaskValueString',[LoopData.Plant.G(1).Name,'|[]']);
        PlantBlock2 = add_block('cstblocks/LTI System',[DiagramName,'/Plant2']);
        set_param(PlantBlock2,'MaskValueString',[LoopData.Plant.G(2).Name,'|[]']);
        DisturbanceBlock = add_block('cstblocks/LTI System',[DiagramName,'/Disturbance Dynamics']);
        set_param(DisturbanceBlock,'MaskValueString',[LoopData.Plant.G(3).Name,'|[]']);
    case 6
        assignin('base',LoopData.Plant.G(3).Name,LoopData.Plant.G(3).Model(:,:,NominalModelIdx));
        assignin('base',LoopData.Plant.G(4).Name,LoopData.Plant.G(4).Model(:,:,NominalModelIdx));
        assignin('base',LoopData.C(3).Name,utCreateLTI(zpk(LoopData.C(3))));
        CompBlock1 = add_block('cstblocks/LTI System',[DiagramName,'/Compensator']);
        set_param(CompBlock1,'MaskValueString',[LoopData.C(1).Name,'|[]']);
        CompBlock2 = add_block('cstblocks/LTI System',[DiagramName,'/Compensator2']);
        set_param(CompBlock2,'MaskValueString',[LoopData.C(2).Name,'|[]']);
        FilterBlock= add_block('cstblocks/LTI System',[DiagramName,'/Prefilter']);
        set_param(FilterBlock,'MaskValueString',[LoopData.C(3).Name,'|[]']);
        InBlock = add_block('built-in/SignalGenerator',[DiagramName,'/Input']);
        OutBlock = add_block('built-in/Scope',[DiagramName,'/Output']);
        SumBlock = add_block('built-in/Sum',[DiagramName,'/Sum']);
        PlantBlock1 = add_block('cstblocks/LTI System',[DiagramName,'/Plant']);
        set_param(PlantBlock1,'MaskValueString',[LoopData.Plant.G(1).Name,'|[]']);
        PlantBlock2 = add_block('cstblocks/LTI System',[DiagramName,'/Plant2']);
        set_param(PlantBlock2,'MaskValueString',[LoopData.Plant.G(2).Name,'|[]']);
        SensorBlock1 = add_block('cstblocks/LTI System',[DiagramName,'/Sensor1']);
        set_param(SensorBlock1,'MaskValueString',[LoopData.Plant.G(3).Name,'|[]']);
        SensorBlock2 = add_block('cstblocks/LTI System',[DiagramName,'/Sensor2']);
        set_param(SensorBlock2,'MaskValueString',[LoopData.Plant.G(4).Name,'|[]']);
end

%---Close CSTBLOCKS, if it wasn't open before
if isempty(BlockOpenFlag),
   close_system('cstblocks')
end

if ((LoopData.getconfig~= 5) && (LoopData.getconfig~= 6))
if (LoopData.Plant.LoopSign(1)>0) 
   SumStr='++';
else
   SumStr='+-';
end	
set_param(SumBlock,'Inputs',SumStr)
set_param(NewDiagram,'Location',[70, 200, 560, 420])
set_param(SensorBlock,'Orientation','left');
end

open_system(NewDiagram)

% Diagram topology depends on loop configuration
switch LoopData.getconfig
    case 1 % Forward
        set_param(SumBlock,'Position',[165, 42, 195, 73])
        set_param(OutBlock,'Position',[440, 45, 465, 75])
        set_param(InBlock,'Position',[15, 35, 45, 65])
        set_param(PlantBlock,'Position',[315, 42, 380, 78])
        set_param(SensorBlock,'Position',[285, 112, 350, 148])
        set_param(CompBlock,'Position',[220, 42, 285, 78])
        set_param(FilterBlock,'Position',[65, 32, 130, 68])
        LinePos=[{[50 50; 60 50]};
            {[135 50; 160 50]};
            {[280 130; 150 130; 150 65; 160 65]};
            {[200 60;215 60]};
            {[290 60;310 60]};
            {[385 60;435 60]};
            {[400 60; 400 130;355 130]}];
    case 2 % Feedback
        set_param(SumBlock,'Position',[165, 42, 195, 73])
        set_param(OutBlock,'Position',[440, 45, 465, 75])
        set_param(InBlock,'Position',[15, 35, 45, 65])
        set_param(PlantBlock,'Position',[255, 42, 320, 78])
        set_param(SensorBlock,'Position',[310, 112, 375, 148])
        set_param(CompBlock,'Position',[200, 112, 265, 148],'Orientation','left')
        set_param(FilterBlock,'Position',[65, 32, 130, 68])
        LinePos=[{[305 130;270 130]};
            {[200 60;250 60]};
            {[195 130;150 130;150 65;160 65]};
            {[50 50;60 50]};
            {[135 50;160 50;]};
            {[325 60; 435 60]};
            {[400 60; 400 130; 380 130]}];
    case 3 % Filter in the Feedforward path
        set_param(SumBlock,'Position',[155 62 185 93])
        set_param(OutBlock,'Position',[485 60 510 90])
        set_param(InBlock,'Position',[15 55 45 85])
        set_param(PlantBlock,'Position',[370 57 435 93])
        set_param(SensorBlock,'Position',[285 137 350 173])
        set_param(CompBlock,'Position',[210 62 275 98])
        set_param(FilterBlock,'Position',[85 12 150 48])
        SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],'Position',[310 57 340 88],'Inputs','++');
        LinePos={[155 30;295 30;295 65;305 65] ; ...
            [50 70;60 70;60 30;80 30];...
            [60 70;150 70];...
            [280 155;130 155;130 85;150 85];...
            [190 80;205 80];...
            [280 80;305 80];...
            [345 75;365 75];...
            [440 75;455 75;455 155;355 155];...
            [455 75;480 75]};
    case 4 %  Filter in the Feedback path
        set_param(SumBlock,'Position',[80 37 110 68])
        set_param(OutBlock,'Position',[450 50 475 80])
        set_param(InBlock,'Position',[15 30 45 60])
        set_param(PlantBlock,'Position',[315 47 380 83])
        set_param(SensorBlock,'Position',[310 147 375 183])
        set_param(CompBlock,'Position',[135 37 200 73])
        set_param(FilterBlock,'Position',[187 105 253 145],'Orientation','up')
        if LoopData.Plant.LoopSign(2)>0,
            SumStr2='++';
        else
            SumStr2='+-';
        end
        SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],...
            'Position',[245 47 275 78],'Inputs',SumStr2);
        LinePos={[220 100;220 70;240 70];...
            [385 65;385 65;420 65;420 165;380 165];...
            [420 65;445 65];...
            [205 55;240 55];...
            [50 45;75 45];...
            [305 165;305 165;220 165;65 165;65 60;75 60];...
            [220 165;220 150];...
            [115 55;130 55];...
            [280 65;310 65]};

    case 5
        set_param(InBlock,'Position',[80 200 110 230]);
        set_param(FilterBlock,'Position',[145 197 205 233 ]);
        set_param(SumBlock,'Position',[245 207 295 243]);
        set_param(CompBlock,'Position',[340 207 400 243]);
        set_param(PlantBlock1,'Position',[490 207 550 243 ]);
        set_param(PlantBlock2,'Position',[490 287 550 323]);
        set_param(DisturbanceBlock,'Position',[475 142 535 178]);
        set_param(OutBlock,'Position',[840 179 870 211]);
        set_param(InBlock2,'Position',[375 145 405 175]);
        SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],'Position',[600 129  665 256],'Inputs','++');
        SumBlock3 = add_block('built-in/Sum',[DiagramName,'/Sum3'],'Position',[660 345 680 365],'IconShape','Round','orientation','down','Inputs','|-+');
        LinePos = {[115 215;140 215];[210 215;240 215];[670 370;230 370;230 235;240 235];...
           [300 225;335 225];[408 225;485 225];[420 225;420 305;485 305];...
           [540 160;595 160];[555 225;595 225];...
           [410 160;470 160];...
           [750 195;835 195];...
           [555 305;670 305;670 340];...
           [750 195;750 355;685 355];...
           [670 195;750 195]}; 
    case 6
        set_param(InBlock,'Position',[80 200 110 230]);
        set_param(FilterBlock,'Position',[140 197 200 233]);
        set_param(SumBlock,'Position',[245 207 295 243]);
        set_param(CompBlock1,'Position',[340 207 400 243]);
        set_param(CompBlock2,'Position',[520 217 580 253]);
        set_param(PlantBlock1,'Position',[620 217 680 253]);
        set_param(PlantBlock2,'Position',[750 217 810 253]);
        set_param(SensorBlock1,'Position',[565 307 625 343],'Orientation','left');
        set_param(SensorBlock2,'Position',[755 397 815 433],'Orientation','left');
        set_param(OutBlock,'Position',[920 219 950 251]);
        SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],'Position',[430 217 480 253],'Inputs','+-');
        LinePos = {[115 215;135 215];[205 215;240 215];[750 415;205 415;205 235;240 235];[685 235;710 235];[815 235;855 235];...
           [300 225;335 225];[405 225;425 225];[560 325;405 325;405 245;425 245];...
           [485 235;515 235];[585 235;615 235];[710 235;745 235];[855 235;915 235];...
           [710 235;710 325;630 325];[855 235;855 415;820 415]};
       
end


for ctLine = 1:length(LinePos)
   add_line(NewDiagram,LinePos{ctLine});
end

open_system(NewDiagram);




