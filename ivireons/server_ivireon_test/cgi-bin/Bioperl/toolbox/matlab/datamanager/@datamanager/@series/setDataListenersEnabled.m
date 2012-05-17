function setDataListenersEnabled(h,state)

dataListener = h.DataListener;
if isempty(h.DataListener)
    return;
end
if isa(dataListener, 'handle.listener')    
    h.DataListener.Enable = state;
else
    h.DataListener.Enable = strcmpi(state,'on');
end
