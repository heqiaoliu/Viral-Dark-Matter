function hblk = mult(hTar, name, ninputs, param,render)
%MULT  Add a Product block to the model.
%   HBLK = MULT(HTAR, NAME, NINPUTS, param) adds a gain block named NAME,
%   with NINPUTS inputs and returns a handle HBLK to the block. PARAM
%   specifies the arithmetic property and parameters of the filter.

%   Author(s): V. Pellissier
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:45 $

error(nargchk(4,5,nargin,'struct'));

sys = hTar.system;

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/Product', [sys '/' name]);
    set_param(hblk, 'Inputs', ninputs, ...
        'InputSameDT','off',...
        'LockScale', 'off');
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Product','Name',name);
    hblk=hblk1{1};
end

try
    % Parameters may or may not be tunable (depends on model running or not)
    if isstruct(param)
        fxptAvail = (exist('fixptlib') == 4);
        if ~fxptAvail,
            error(generatemsgid('NotSupported'),'Could not find Simulink Fixed Point.');
        end
        FL = param.qproduct(2);
        if FL<0,
            outscaling = ['2^',num2str(abs(FL))];
        else
            outscaling = ['2^-',num2str(abs(FL))];
        end
        set_param(hblk, ...
            'OutDataTypeMode', 'Specify via dialog', ...
            'OutDataType', ['sfix(',num2str(param.qproduct(1)),')'], ...
            'OutScaling', outscaling, ...
            'RndMeth', rndmeth(param.RoundMode), ...  
            'DoSatur', dosatur(param.OverflowMode),...
            'InputSameDT','off');

    else
        set_param(hblk, ...
            'OutDataTypeMode', 'Same as first input', ...
            'OutScaling', '1', ...
            'RndMeth', 'Nearest', ...  
            'DoSatur', 'on');

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

%----------------------------------------------------------------------
function DoSatur = dosatur(Overflowmode)
% Convert from quantizer/overflowmode to DoSatur property of the block.

switch Overflowmode
    case 'saturate'
        DoSatur = 'on';
    case 'wrap'
        DoSatur = 'off';
end
