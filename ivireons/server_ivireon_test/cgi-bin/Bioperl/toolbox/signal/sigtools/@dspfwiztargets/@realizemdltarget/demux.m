function hblk = demux(hTar, name, nports, param, pos, render)
%DEMUX  Add a demux block to the model.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:25 $

sys = hTar.System;
p = sizes;

if render

    % add demux
    nports = str2double(nports);
    [hblk, coeffindex] = add_demux([sys '/' name],nports,param,pos,p);
      
    % create goto ports
    nstages = length(coeffindex);
    stepsize = 20;
    goto_yidx = (-(nstages-1)/2:(nstages-1)/2)*stepsize;

    % Determine demux middle position
    xpos = pos(1) + (pos(3)-pos(1))/2;
    ypos = pos(2) + (pos(4)-pos(2))/2;
    demuxpos = [xpos ypos xpos ypos];
    
    % Determine goto block x-positions
    goto_xshift = [100 0 100 0];
    demuxpos = demuxpos + goto_xshift;
    
    % Determine goto block y-positions
    demuxpos = ones(nstages,1)*demuxpos;    % create a matrix of the position
    goto_yshift = goto_yidx'*[0 1 0 1];     % shift along y-axis
    gotoposition = demuxpos + goto_yshift;  % position for each goto block
    
    % check if the index is out-of-bound (use the upper most goto block
    % position to test). If any of the block is out-of-bound, shift all
    % block in-bound.
    goto_upperpos = gotoposition(1,:);       % the first row is the upper most block
    if goto_upperpos(2)<0
        % if y-position is less than 0, shift every blocks along y-axis.
        y_shift = abs(goto_upperpos(2));
        shiftmatrix = [zeros(nstages,1) y_shift*ones(nstages,1)];
        shiftmatrix = [shiftmatrix shiftmatrix];
        
        % new positions
        gotoposition = gotoposition + shiftmatrix;
    end
    
    idx = 1;
    for stage = coeffindex
        % set goto tag
        gotoname = sprintf('%s%s','goto',param{stage});
        
        % add goto block
        hgblk = add_block('built-in/Goto',[sys '/' gotoname]);
        set_param(hgblk, 'Position',gotoposition(idx,:)+p.sect,...
            'Orientation','right','ShowName','off','GotoTag',param{stage});
        
        % add connection with the demux
        add_line(sys,sprintf('%s/%d',name,idx),[gotoname '/1']);
        idx = idx+1;
    end
    
    % update demux position
    ymin = gotoposition(1,2)-12;  
    ymax = gotoposition(end,2)+12;
    demuxthickness = 5;
    demuxpos = [pos(1) ymin pos(3)+demuxthickness ymax];
    set_param(hblk,'Position',demuxpos,'ShowName','off');
    
else
    % search for the existing block
    hblk1=find_system(sys,'SearchDepth',1,'BlockType','SubSystem','Name',name);
    hblk=hblk1{1} ;
end

%--------------------------------------------------------------------------
function [hblk, effgotoidx] = add_demux(name,nports,param,pos,p)

hblk = add_block('built-in/subsystem', name,'Position',pos,'BackgroundColor','black');
hin = add_block('built-in/inport',[name '/input']);

% create parameter for selector block by selecting only implemented
% coefficients; for example, [1 3] represents the selection of the 1st and
% 3rd elements of the input vector.
index = 1:length(param);
effgotoidx = index(~strcmpi(param,''));

% add selector block
hs = add_block('built-in/Selector',[name '/selector'],...
                'InputPortWidth',sprintf('%d',nports),...
                'IndexParamArray',{mat2str(effgotoidx)});

% add demux block
numgoto = length(effgotoidx);
hd = add_block('built-in/Demux',[name '/demux'],...
                'Outputs',sprintf('%d',numgoto), 'DisplayOption', 'bar',...
                'Position',[300 100 300 100]+p.demux);
blkname = get_param(hd,'Name');
    
% add output ports
start_pos = [400 100 400 100];       % output block starting position
stepsize = [0 30 0 30];              % shift along y-axis
for n = 1:numgoto
    
    % output block position
    output_pos = start_pos + (n-1)*stepsize;
    
    % add output port for each coefficient
    add_block('built-in/outport',sprintf('%s/output%d',name,n),...
        'Position',output_pos+p.input);
    
    % connect the demux and output port
    add_line(name,sprintf('%s/%d',blkname,n),sprintf('output%d/1',n),...
        'autorouting','on');
end

% Recalculate the middle position of the output ports
start_ypos = start_pos(2);
stop_ypos = output_pos(4);
mid_ypos = (start_ypos+stop_ypos)/2;

% Set input port position
npos = [100 mid_ypos 100 mid_ypos];
set_param(hin,'Position',npos+p.input);

% Set selector position
npos = [200 mid_ypos 200 mid_ypos];
set_param(hs,'Position',npos+p.selector);

% Update demux position
npos = get_param(hd,'Position');
npos(2) = start_ypos-15; 
npos(4) = stop_ypos+15;
set_param(hd,'Position',npos);

% Connect input port and the selector block
add_line(name,'input/1','selector/1','autorouting','on');
add_line(name,'selector/1','demux/1','autorouting','on');

%--------------------------------------------------------------------------
function p = sizes
% sizes defines the size of blocks

p.inputsize = [30 16];  %input, output
p.sectsize = [56 14];   %from, goto
p.selectorsize = [40 38];  % selector
p.demuxsize = [5 20];   % demux

p.input=[-p.inputsize/2 p.inputsize/2];
p.sect=[-p.sectsize/2 p.sectsize/2];
p.selector=[-p.selectorsize/2 p.selectorsize/2];
p.demux = [-p.demuxsize/2 p.demuxsize/2];


% [EOF]
