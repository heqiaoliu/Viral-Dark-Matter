function optimizenegonegains(hTar,H)
%OPTIMIZENEGONEGAINS Replace -1 gains with single connections 
%    and update the sign of the connected adder. Each target object must
%    provide getsumstr and setsumstr methods

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:49 $

sys = hTar.system;
if isempty(sys), error(generatemsgid('NotSupported'),'System undefined.'); end

gains = hTar.gains;
gains = gains(find(ishandle(gains)));
if isempty(gains),return; end 

% Find all -1 gain blocks
blcks = find_negonegains(hTar, H);

% Remove all -1 gain blocks
remove_blocks(hTar, blcks);

% ---------------------------------------------------------------------
function full_list = find_negonegains(hTar, H)

gains = hTar.gains;

% Remove invalid handles
gains = gains(find(ishandle(gains)));

% Call the isnegonegain method
y = hTar.isnegonegain(gains,H);
hndl_list = gains(find(y==1));
full_list = [];
if ~isempty(hndl_list),
    full_list = getfullname(hndl_list);
    if ~iscell(full_list),
        full_list = {full_list};
    end
end


% ---------------------------------------------------------------------
function remove_blocks(hTar, blcks)

sys = hTar.system;

for i=1:length(blcks),
    
    % Disconnect -1 gain
    [full_src, full_dst] = deleteio(hTar, blcks{i});
    
    % Remove -1 gain
    delete_block(blcks{i});
    
    % Change sign of the summer
    if issum(full_dst{1}, hTar),
        conn = changesign(full_src,full_dst{1}, hTar);
    else
        sum_src{1} = full_dst{1};
        % Find next summer
        if strcmpi(get_param(full_dst{1},'BlockType'),'DataTypeConversion'),
            % If convert block go to next delay
            p = get_param(full_dst{1}, 'portconnectivity');
            sum_src{1} = p(end).DstBlock;
        end
        p = get_param(sum_src{1}, 'portconnectivity');
        conn = changesign(sum_src{1},p(end).DstBlock, hTar);
        conn = '1';
    end
    
    % Restore connections
    add_io(hTar, full_src, full_dst(1), conn);
    
end


% ---------------------------------------------------------------------
function conn = changesign(full_src,full_sum, hTar)

% Get string of the summer
str = getsumstr(hTar, full_sum);

% Find the port where to change the sign
pconn = get_param(full_sum,'PortConnectivity');
for i=1:length(pconn),
    if pconn(i).SrcBlock==-1 | pconn(i).SrcBlock == get_param(full_src, 'handle'),
        % Port is either unconnected or link to the source block
        conn = pconn(i).Type;
        connType = str2num(conn);
    end
end

% Find the position of the sign to be changed
pipes  = findstr(str, '|');
if pipes==1,
    connType = connType+1;
end

% Change sign
if strcmpi(str(connType),'+'),
    str(connType) = '-';
else
    str(connType) = '+';
end

% Set the string of the summer
setsumstr(hTar, full_sum, str);


% ---------------------------------------------------------------------
function y = issum(blockname, hTar)

y = 1;
% Gain destination is either a sum, a convert or a delay block
hndl = get_param(blockname, 'handle');
if ~isempty(find(hndl==hTar.delays)) || ...
        strcmpi(get_param(blockname,'BlockType'),'DataTypeConversion'),
    y = 0; % Gain destination is a delay or a convert block
end
