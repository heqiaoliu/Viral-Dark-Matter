function hblk = portselector(hTar, name, param, RowsOrColumns, render)
%PORTSELECTOR Add a port selector to the model.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:53 $

sys = hTar.System;

if render
    hblk = add_portselector([sys '/' name],param,RowsOrColumns);
else
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','SubSystem','Name',name);
    hblk=hblk1{1} ; 
end

set_param(hblk, 'ShowName', 'off');
set_param(hblk,'MaskDisplay',['disp([''Select\n'' ' '''' RowsOrColumns '''' ']);']);

%--------------------------------------------------------------------------
function hblk = add_portselector(name,param,rowsorcols)

p = sizes;
hblk = add_block('built-in/subsystem', name);
hin = add_block('built-in/inport',[name '/input'],'Position',[100 100 100 100]+p.input);

% select rows or columns
selectrows = false;
if strcmpi(rowsorcols,'rows')
    selectrows = true;
end
% add selector blocks and output ports
pindex = 0;
ngotoidx = [];
start_pos = [200 100 200 100];   % selector block starting position

nports = str2double(param);      % Number of rows or columns to be selected
for n = 1:nports
    % If the coefficient name exists, render the selector and output
    % blocks. If not, it is not implemented coefficient. 
    stepsize = [0 50 0 50];     % shift along y-axis
    selector_pos = start_pos;     % selector block starting position
        
        % set selector block position
        selector_pos = selector_pos + (n-1)*stepsize;
        
        % add selector block for row or column selector
        if selectrows
            hsblk = add_block('built-in/Selector',...
                sprintf('%s%s%d',name,'/selector',n),...
                'NumberOfInputDimensions','2',...
                'Indices',sprintf('%d,1',n),...
                'IndexOptions','Index vector (dialog),Select all',...
                'Position',selector_pos + p.selector);
        else
             hsblk = add_block('built-in/Selector',...
                sprintf('%s%s%d',name,'/selector',n),...
                'NumberOfInputDimensions','2',...
                'Indices',sprintf('1,%d',n),...
                'IndexOptions','Select all,Index vector (dialog)',...
                'Position',selector_pos + p.selector);
        end
          
        % add output port for each coefficient
        add_block('built-in/outport',...
                sprintf('%s%s%d',name,'/output',n),...
                'Position',selector_pos+[100 0 100 0]+p.input);

        % connect the selector and output port
        blkname = get_param(hsblk,'Name');
        add_line(name,[blkname '/1'],sprintf('output%d/1',n),...
                    'autorouting','on');
end

% Recalculate the input port y-position
start_ypos = start_pos(2);
stop_ypos = selector_pos(2);
mid_ypos = (start_ypos+stop_ypos)/2;
pos = get_param(hin,'Position');
npos = [pos(1) mid_ypos pos(1) mid_ypos];
set_param(hin,'Position',npos+p.input);

% Connect input port and the selector block
for n = 1:nports
    blkname = sprintf('%s%d','selector',n);
    add_line(name,'input/1',[blkname '/1'],'autorouting','on');
end

%--------------------------------------------------------------------------
function p = sizes
% sizes defines the size of blocks

p.inputsize = [30 16];  %input, output
p.sectsize = [56 14];   %from, goto
p.selectorsize = [40 38];  % selector

p.input=[-p.inputsize/2 p.inputsize/2];
p.sect=[-p.sectsize/2 p.sectsize/2];
p.selector=[-p.selectorsize/2 p.selectorsize/2];

% [EOF]
