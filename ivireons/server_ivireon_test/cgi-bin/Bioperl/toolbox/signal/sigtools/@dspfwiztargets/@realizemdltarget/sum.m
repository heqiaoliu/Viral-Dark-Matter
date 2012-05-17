function hblk = sum(hTar, name, sum_str, param, render)
%SUM Add a Sum block to the model.
%   HBLK = SUM(HTAR, NAME, SUM_STR, param) adds a sum block named NAME,
%   sets the sign of its inputs according to SUM_STR, parameterize the blok
%   with PARAM and returns a handle HBLK to the block.


%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:59 $

error(nargchk(4,5,nargin,'struct'));

sys = hTar.system;

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/Sum', [hTar.system '/' name]);
    set_param(hblk, 'IconShape', 'round', 'Inputs', sum_str, ...
        'LockScale', 'off',...
        'InputSameDT','off');
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Sum','Name',name);
    hblk=hblk1{1};
end

try
    % Parameters may or may not be tunable (depends on model running or not)
    if isstruct(param)
        if ~isfield(param,'AccQ'), param.AccQ = param.sumQ; end
        set_param(hblk, ...
            'AccumDataTypeStr', ['fixdt(1,',num2str(param.AccQ(1)),',',num2str(param.AccQ(2)),')'], ...
            'OutDataTypeStr', ['fixdt(1,',num2str(param.sumQ(1)),',',num2str(param.sumQ(2)),')'], ...
            'RndMeth', rndmeth(param.RoundMode), ...  % Zero|Nearest|Ceiling|Floor
            'SaturateOnIntegerOverflow', dosatur(param.OverflowMode));
    else
            set_param(hblk, 'OutScaling', '1', ...
        'RndMeth', 'Nearest', ...
        'SaturateOnIntegerOverflow', 'on', ...
        'OutDataTypeMode', 'Same as first input');
    end
catch ME %#ok<NASGU> 

end


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

%---------------------------------------------------------------------
function DoSatur = dosatur(Overflowmode)
% Convert from overflowmode to DoSatur property of the block.

switch Overflowmode
    case 'saturate'
        DoSatur = 'on';
    case 'wrap'
        DoSatur = 'off';
end

