function convert(hTar, name, param, libname,render)

%CONVERT Add a Convert block to the model.

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:19 $


error(nargchk(4,5,nargin,'struct'));

sys = hTar.system;

if nargin<5
    render=true;
end


if ~isstruct(param)
    return;
else

    
    if render 
        blockname = [hTar.system '/' name];
        hblk = add_block([libname '/Data Type/Conversion'], blockname);
    else % then find the block and just update the block's parameters
        hblk1=find_system(sys,'SearchDepth',1,'BlockType','DataTypeConversion','Name',name);
        hblk=hblk1{1};
    end
    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Set parameters for the quantizer
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FL = param.outQ(2);
    if FL<0,
        outscaling = ['2^',num2str(abs(FL))];
    else
        outscaling = ['2^-',num2str(abs(FL))];
    end
    
    if isfield(param,'Signed'),
        if param.Signed,
            outdatatype = ['sfix(',num2str(param.outQ(1)),')'];
        else
            outdatatype = ['ufix(',num2str(param.outQ(1)),')'];
        end
    else
        outdatatype = ['sfix(',num2str(param.outQ(1)),')'];
    end
        
    set_param(hblk, ...
        'OutDataTypeMode', 'Specify via dialog', ...
        'OutDataType', outdatatype, ...
        'OutScaling', outscaling, ...
        'LockScale', 'off' , ...
        'RndMeth', rndmeth(param.RoundMode), ...  % Zero|Nearest|Ceiling|Floor
        'DoSatur', dosatur(param.OverflowMode));  % Checkbox

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
% Convert from quantizer/overflowmode to DoSatur property of the block.

switch Overflowmode
case 'saturate'
    DoSatur = 'on';
case 'wrap'
    DoSatur = 'off';
end

