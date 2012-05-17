function optimizeonegains(hTar, H)
%OPTIMIZEONEGAINS Replace unity gains with single connections.

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:50 $

sys = hTar.system;
if isempty(sys), error(generatemsgid('NotSupported'),'System undefined.'); end

gains = hTar.gains;
gains = gains(find(ishandle(gains)));
if isempty(gains),return; end 

% Find all unit gain blocks
blcks = find_unitgains(hTar, H);

% Remove all unit gain blocks
remove_unitgains(hTar, blcks);


% ---------------------------------------------------------------------
function full_list = find_unitgains(hTar, H)

gains = hTar.gains;

% Remove invalid handles
gains = gains(find(ishandle(gains)));

% Call the isunitgain method
y = hTar.isunitgain(gains, H);
hndl_list = gains(find(y==1));
full_list = [];
if ~isempty(hndl_list),
    full_list = getfullname(hndl_list);
    if ~iscell(full_list),
        full_list = {full_list};
    end
end


% ---------------------------------------------------------------------
function remove_unitgains(hTar, blcks)

sys = hTar.system;

for i=1:length(blcks),
    
    % Disconnect unit gain
    [full_src, full_dst] = deleteio(hTar, blcks{i});
    
    % Remove unit gain
    delete_block(blcks{i});
    
    % Restore connections
    add_io(hTar, full_src, full_dst);
    
end
