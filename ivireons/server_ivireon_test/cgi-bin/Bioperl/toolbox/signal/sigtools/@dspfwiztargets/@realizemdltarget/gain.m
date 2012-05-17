function hblk = gain(hTar, name, coeff, param, render)
%GAIN Add a Gain block to the model.
%   HBLK = GAIN(HTAR, NAME, COEFF, param) adds a gain block named NAME,
%   sets its value to COEFF and returns a handle HBLK to the block. qparam
%   specifies the arithmetic property and parameters of the filter.
%

% Copyright 2004-2008 The MathWorks, Inc.

error(nargchk(4,5,nargin,'struct'));

sys = hTar.system;

if nargin<5
    render=true;
end

if render
    hblk = add_block('built-in/Gain', [hTar.system '/' name]);
    set_param(hblk, 'ParameterDataTypeMode', 'Specify via dialog',...
        'LockScale', 'off', ...
        'ParameterScalingMode', 'Use specified scaling',...
        'VecRadixGroup', 'Use Specified Scaling');
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','Gain','Name',name);
    hblk=hblk1{1};
end

try
    % Parameters may or may not be tunable (depends on model running or not)
    if isstruct(param)
        % Fixed -Point
        if length(param.qcoeff)>1 && length(param.qproduct)>1,

            fxptAvail = (exist('fixptlib') == 4);
            if ~fxptAvail,
                error(generatemsgid('NotSupported'),'Could not find Simulink Fixed Point.');
            end

            FL = param.qcoeff(2);
            if FL<0,
                pscaling = ['2^',num2str(abs(FL))];
            else
                pscaling = ['2^-',num2str(abs(FL))];
            end
            if param.Signed,
                set_param(hblk, ...
                    'ParameterDataType', ...
                    ['sfix(',num2str(param.qcoeff(1)),')'], ...
                    'ParameterScaling', pscaling);
            else
                set_param(hblk, ...
                    'ParameterDataType', ...
                    ['ufix(',num2str(param.qcoeff(1)),')'], ...
                    'ParameterScaling', pscaling);
            end
            FL = param.qproduct(2);
            if FL<0,
                outscaling = ['2^',num2str(abs(FL))];
            else
                outscaling = ['2^-',num2str(abs(FL))];
            end
            set_param(hblk, ...
                'OutDataTypeMode', 'Specify via dialog', ...
                'OutputDataTypeScalingMode', 'Specify via dialog',...
                'OutDataType', ['sfix(',num2str(param.qproduct(1)),')'], ...
                'OutScaling', outscaling, ...
                'RndMeth', rndmeth(param.RoundMode), ...  % Zero|Nearest|Ceiling|Floor
                'DoSatur', dosatur(param.OverflowMode));
        end
    else
        set_param(hblk, ...
            'ParameterScaling', '1',...
            'OutDataTypeMode', 'Same as input', ...
            'OutScaling', '1', ...
            'RndMeth', 'Nearest', ... 
            'DoSatur','on');
        switch param
            case 'double'
                set_param(hblk, 'ParameterDataType', 'float(''double'')');
            case 'single'
                set_param(hblk, 'ParameterDataType', 'float(''single'')');
        end
    end
catch ME %#ok<NASGU> 

end

% Gain is always tunable
set_param(hblk, 'Gain', coeff);


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
