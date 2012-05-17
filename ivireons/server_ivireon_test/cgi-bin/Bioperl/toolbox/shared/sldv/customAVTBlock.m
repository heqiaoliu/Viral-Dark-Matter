function customAVTBlockIntervals = customAVTBlock(blockH, command, varargin)
%   This function updates pre-packed custom Simulink Design Verifier blocks based on the values of mask parameters.
%

%   Copyright 2001-2008 The MathWorks, Inc.

if (nargin < 2)
   customAVTBlock(0, 'help');
   error('SLDV:Blocks:ArgNum', 'Not enough input arguments');

end

switch lower(command)
    case  'help'
        help = sprintf('%s\n', 'customAVTBlock(gcbh, command, options)');
        help = sprintf('%s%s\n', help, 'e.g.:');
        help = sprintf('%s%s\n', help, 'customAVTBlock(gcbh, ''update'', ''{1,2,[3,4], [-inf,7],}'')');
        help = sprintf('%s%s\n', help, 'customAVTBlock(0, ''parse_params'', {1,2,[3,4], [-inf,7],})');
        help = sprintf('%s%s\n', help, 'customAVTBlock(gcbh, ''disable'')');
        display(help);

    case  'update'
        if (~isequal(nargin,3) || ~ ischar(varargin{1}))
          error('SLDV:Blocks:UnknownParam', 'Unknown parameter!');
        end
        set_param(blockH, 'intervals', varargin{1});
    case  'enable'
        set_param(blockH, 'enabled', 'on');
    case  'disable'
        set_param(blockH, 'enabled', 'off');
    case  'updatedisp'
        update_value_display(blockH);
    case  'update_from_mask'
        customAVTBlockIntervals = update_all(blockH, varargin{1});
    case  'parse_params'
        if ~isequal(nargin,3)
           error('SLDV:Blocks:UnknownParam', 'Unknown parameter!');
        end
        try
            [customAVTBlockIntervals errMsg] = checkSldvSpecification(varargin{1});
            if ~isempty(errMsg)
                 error('SLDV:Blocks:Specification', errMsg);
            end
        catch Mex   %#ok<NASGU>
        end 
    otherwise
      error('SLDV:Blocks:UnknownCommand', 'Unknown command!');
end

function customAVTBlockIntervals = update_all(blockH, intervals)

    update_type(blockH);

    customAVTBlockIntervals = [];
    if ~isempty(intervals)
        [customAVTBlockIntervals errMsg] = checkSldvSpecification(intervals);
        if ~isempty(errMsg) 
            error('SLDV:Blocks:Syntax', get_param(blockH, 'MaskType')); 
        end
    end
    update_icon(blockH);
    update_outport(blockH);
    update_value_display(blockH);

% if it is pass through show outputport
function update_outport(blockH)

  hasOut = isequal(length(get_param(blockH,'Blocks')),3);

  bfN = getfullname(blockH);
  if isequal(get_param(blockH,'outEnabled'),'on')
      if(~hasOut)
          load_system('simulink');
          nbh = add_block('simulink/Sinks/Out1', [bfN, '/Out1']);
          set_param(nbh, 'Position', [275    28   305    42]);

          iph = get_param([bfN, '/In1'], 'PortHandles');
          oph = get_param(nbh, 'PortHandles');
          add_line(blockH, iph.Outport, oph.Inport);

      end
  elseif (hasOut)
         iph = get_param([bfN, '/In1'], 'PortHandles');
         oph = get_param([bfN, '/Out1'], 'PortHandles');
         delete_line(blockH, iph.Outport, oph.Inport);
         delete_block([bfN, '/Out1']);
  end


% update icon, mask  text
function update_type(blockH)
    type =  get_param(blockH, 'customAVTBlockType');
    type = ['Design Verifier ' type];
    old_type = get_param(blockH, 'masktype');
    if strcmp(type, old_type)
         return;
    end
    set_param(blockH, 'masktype', type);
    helpText = '';
    descr = '';
    switch(type)
       case 'Design Verifier Test Condition'
          descr = [ ...
        'Constrains signal values in Simulink Design Verifier test cases. The ''Values'' ' ...
        'parameter constrains the block input signal.  Two element vectors specify ' ...
        'intervals.  Cell arrays specify lists.  The signal must satisfy at least one ' ...
        'of the values or intervals at every time step unless the ''Initial'' check box ' ...
        'is selected, when the constraint applies only to the first time step'];
        helpText = 'testcondition';
       case 'Design Verifier Assumption'
          descr = [ ...
        'Assumes signal values when Simulink Design Verifier proves model properties.  ' ...
        'The input signal is assumed to be one of the values listed in the ''Values'' ' ...
        'parameter.  Two element vectors specify intervals.  Cell arrays specify ' ...
        'lists. The signal must match one of the listed values or intervals at every ' ...
        'time step unless the ''Initial'' check box is enabled, in which case the ' ...
        'assumption is for only the first time step.'];
        helpText = 'proofassumption';
       case 'Design Verifier Test Objective'
          descr = [ ...
        'Obtains signal values in Simulink Design Verifier test cases.  The ''Values'' ' ...
        'parameter specifies the desired input signal values.  Two element vectors ' ...
        'specify intervals.  Cell arrays specify lists.  Each list entry might result ' ...
        'in a separate test case.'];
        helpText = 'testobjective';
       case  'Design Verifier Proof Objective'
          descr = [ ...
        'Proves signal values using Simulink Design Verifier.  The ''Values'' parameter ' ...
        'specifies input signal values to prove. Two element vectors specify intervals.  ' ...
        'Cell arrays specify lists. Signals are proven to satisfy at least one of the ' ...
        'values or intervals at every time step.'];
        helpText = 'proofobjective';
    end

    descr = [descr char(10) ...
            'Example Values:' char(10) ...
            'true'  char(10) ...
            '{[0 1], 2, [4 5], 6}'  char(10) ...
            '{Sldv.Interval(-2, -1), Sldv.Point(0), Sldv.Interval(0, 1, ''()''), 1}'];



    set_param(blockH, 'MaskDescription', descr);
    helpText = ['helpview(fullfile(docroot, ''toolbox'',''sldv'',''sldv.map''),''' helpText ''')'];
    set_param(blockH, 'MaskHelp', helpText);
%
% update icons
%
function update_icon(blockH)
    maskType = get_param(blockH, 'masktype');
    disabled = strcmp(get_param(blockH,'enabled'),'off');
    iconFileName = get_icon_name(maskType, disabled);

    position = get_param(blockH, 'position');
    size     = [position(3)-position(1), position(4)-position(2)];

    set_param(blockH, 'MaskIconUnits','pixels');

    imgPosStr = ['[3 3 ' num2str(size(1)-6) ' ' num2str(size(2)-6) ']'];

    iconStr = ['image(imread(''' iconFileName  ''',''BackGroundColor'',[1 1 1]),' ...
                imgPosStr '); hide_arrows(true);'];

    oldIconStr = get_param(blockH, 'MaskDisplay');
    newIconStr = sprintf(iconStr);
    if ~strcmp(oldIconStr,newIconStr)
        set_param(blockH, 'MaskDisplay', newIconStr);
    end

function update_value_display(blockH)
    % Add or remove the values parameter from the 
    % AttributesFormatString based on the dispValues
    % parameter.
    try
        dispValuesStr = get_param(blockH,'dispValues');
    catch Mex %#ok<NASGU>
        dispValuesStr = [];
    end

    if isempty(dispValuesStr)
        return;
    end

    dispValues = strcmp(dispValuesStr,'on');
    annotStr = get_param(blockH,'AttributesFormatString');
    hasDispValues = ~isempty(findstr(annotStr,'%<intervals>'));

    if (dispValues && ~hasDispValues)
        if isempty(annotStr)
            annotStr = '%<intervals>';
        else
            if (annotStr(1)==' ' || annotStr(1)==',')
                annotStr = ['%<intervals>' annotStr];
            else
                annotStr = ['%<intervals> ' annotStr];
            end
        end
        set_param(blockH,'AttributesFormatString',annotStr);
    elseif (~dispValues && hasDispValues);
        annotStr = strrep(annotStr,'%<intervals>','');
        set_param(blockH,'AttributesFormatString',annotStr);
    end

function iconFileName = get_icon_name(maskType, disabled)
    switch(lower(maskType))
    case 'design verifier test objective'
        root = 'sldvicon_o';
    case 'design verifier test condition';
        root = 'sldvicon_c';
    case 'design verifier proof objective'
        root = 'sldvicon_p';
    case 'design verifier assumption'
        root = 'sldvicon_a';
    otherwise
        error('SLDV:Blocks:MaskType', 'Unexpected Mask Type');
    end

    if disabled
        iconFileName = [root '_disabled.png'];
    else
        iconFileName = [root '_normal.png'];
    end

