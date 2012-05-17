function optimizezerogains(hTar, H)
%OPTIMIZEZEROGAINS Remove zero gains.

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:51 $

sys = hTar.system;
if isempty(sys), error(generatemsgid('NotSupported'),'System undefined.'); end

gains = hTar.gains;
gains = gains(find(ishandle(gains)));
if isempty(gains),return; end 

% Find all zero gain blocks
blcks = find_zerogains(hTar, H);

% Remove all zero gain blocks
remove_zerogains(hTar, blcks);

% ---------------------------------------------------------------------
function full_list = find_zerogains(hTar, H)

gains = hTar.gains;

% Remove invalid handles
gains = gains(find(ishandle(gains)));

% Call the iszerogain method
y = hTar.iszerogain(gains, H);

hndl_list = gains(find(y==1));
full_list = [];
if ~isempty(hndl_list),
    full_list = getfullname(hndl_list);
    if ~iscell(full_list),
        full_list = {full_list};
    end
end


% ---------------------------------------------------------------------
function remove_zerogains(hTar, blcks)

sys = hTar.system;

for i=1:length(blcks),
    
    % Disconnect zero gain
    [full_gain_src, full_gain_dst] = deleteio(hTar, blcks{i});
    
    % Remove zero gains
    delete_block(blcks{i});
    
    % Special case: last gain destination may be a delay
    if length(full_gain_dst)==1,
        if ~isempty(findstr('Delay', full_gain_dst{1})),
            delayblk = full_gain_dst{1};
            % Disconnect Delay block
            [dummy, full_gain_dst] = deleteio(hTar, delayblk);
            % Remove Delay block
            delete_block(delayblk);
        end
        
        % Remove adders
        [full_src, full_dst] = remove_adders(full_gain_src,full_gain_dst{1}, hTar);
        
        % Restore connections
        add_io(hTar, full_src, full_dst);
    else
        % Restore connections
        add_io(hTar, full_gain_src, full_gain_dst);
    end
    
end


% ---------------------------------------------------------------------
function [full_src, full_dst] = remove_adders(full_gain_src,full_gain_dst, hTar)

% Test if gain source is an adder (block with unconnected port)
isadder = isunconnected(full_gain_src);

if any(find(get_param(full_gain_src, 'Handle') == hTar.delays)),
    % Test if source is actually a delay and not an adder (block with unconnected port)
    isadder = 0;
    while isunconnected(full_gain_src) && any(find(get_param(full_gain_src, 'Handle') == hTar.delays));
        % Disconnect source delay
        add_src = deleteio(hTar, full_gain_src);

        % Delete source delay
        delete_block(full_gain_src);   
        
        full_gain_src = add_src;
    end
end

if isadder,
    % Disconnect source adder
    add_src = deleteio(hTar, full_gain_src);
    
    % Delete source adder
    delete_block(full_gain_src);
    
    % Test if adder source is a delay (block with unconnected port)
    isdelay = any(find(get_param(add_src, 'Handle')== hTar.delays));
    
    if isdelay,
        % Disconnect delay
        deleteio(hTar, add_src);
        
        % Delete delay
        delete_block(add_src);
    end
    
end

% Disconnect destination adder
[full_src, full_dst] = deleteio(hTar, full_gain_dst);

% Special case: propagate '-' sign (in the recursive branch of df1t and df2 strcutures)
str = getsumstr(hTar, full_gain_dst);
if strcmpi(str, '|--'), % Last adder of the structure
    % Get the next adder
    next_block = get_param(full_dst{1}, 'Handle'); % Next block is either a delay (df1t) or a adder (df2)
    if ~isempty(find(next_block==hTar.delays)),
        conn = get_param(next_block, 'PortConnectivity');
        next_adder = conn(end).DstBlock;
    else
        next_adder = next_block;
    end
    % Propagate the '-' sign
    str = getsumstr(hTar,next_adder);
    pluses = findstr('+',str);
    if length(pluses)==1,
        str(pluses) = '-'; % next_adder is a regular stage
    else
        str(end) = '-'; % next_adder is a head adder
    end
    setsumstr(hTar, next_adder, str);
end

% Delete destination adder
delete_block(full_gain_dst);


% ---------------------------------------------------------------------
function y = isunconnected(blockname)

y=0;
% Test if a block has an unconnected destination port
conn = get_param(blockname, 'portconnectivity');
if isempty(conn(end).DstBlock), % unconnected destination port
    y=1;
end
