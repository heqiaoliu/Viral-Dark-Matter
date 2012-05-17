function h = linkdata(state)

h = graphics.linkdata;
if nargin>=1
    h.Enable = state;
end