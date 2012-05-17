function set_mask_display(chartId)

% Copyright 2002-2006 The MathWorks, Inc.

chartType = sf('get', chartId, 'chart.type');
hBlock = chart2block(chartId);

if isempty(hBlock) || hBlock == 0 || ~ishandle(hBlock)
    % Early return if we don't get a valid block handle
    return;
end

maskDispStr = '';

switch(chartType)
    case 0 % Stateflow chart
        maskDispStr = ['plot(sf(''Private'',''sfblk'',''xIcon''),' ...
            'sf(''Private'',''sfblk'',''yIcon''));' ...
            'text(0.5,0,sf(''Private'', ''sfblk'', ''tIcon''),' ...
            '''HorizontalAl'',''Center'',''VerticalAl'',''Bottom'');'];

        if is_mealy_chart(chartId)
            maskDispStr = [maskDispStr 'text(0.5,0,''Mealy'',''HorizontalAl'',''Center'',''VerticalAl'',''Bottom'');'];
        elseif is_moore_chart(chartId)
            maskDispStr = [maskDispStr 'text(0.5,0,''Moore'',''HorizontalAl'',''Center'',''VerticalAl'',''Bottom'');'];
        end
    case 1 % Truthtable chart
        [vX, vY] = get_truth_table_blk_icon;
        maskDispStr = ['plot([' sprintf('%g ', vX) '], [' sprintf('%g ', vY) ']);'];
        if ~is_eml_truth_table_chart(chartId)
            maskDispStr = [maskDispStr 'text(0.5,0,''SF'',''HorizontalAl'',''Center'',''VerticalAl'',''Bottom'');'];
        end
    case 2 % eML chart
        emlFcnName = sf('get', chartId, 'chart.eml.name');
        if isempty(emlFcnName)
            emlFcnName = 'fcn';
        end
        
        set_param(hBlock, 'MaskIconFrame', 'on');
        maskDispStr = ['disp(''' emlFcnName ''');'];
    otherwise
        error('Stateflow:UnexpectedError','Unknown chart type.');
end

set_param(hBlock, 'MaskDisplay', maskDispStr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vX, vY] = get_truth_table_blk_icon

iconWidth = 0.28;
iL = 0.5 - iconWidth / 2;
iH = 0.5 + iconWidth / 2;
hb = iL + iconWidth * 2/3;
tM = iconWidth / 6; % text margin

vX = [0 0 1 1 0 NaN iL iH iH iL iL NaN 0.5 0.5 NaN iL iH]; % table frame
vY = [0 1 1 0 0 NaN iL iL iH iH iL NaN iL iH NaN hb hb];

tL = iL + tM;
tR = 0.5 - tM;
tC = (tL + tR) / 2;
tU = hb - tM;
tB = iL + tM;
vX = [vX NaN tL tR NaN tC tC]; % text "T"
vY = [vY NaN tU tU NaN tB tU];

tL = 0.5 + tM;
tR = iH - tM;
tC = (tL + tR) / 2;
vX = [vX NaN tL tR NaN tL tL NaN tL tC]; % text "F"
vY = [vY NaN tU tU NaN tB tU NaN (tU + tB)/2 (tU + tB)/2];

return;
