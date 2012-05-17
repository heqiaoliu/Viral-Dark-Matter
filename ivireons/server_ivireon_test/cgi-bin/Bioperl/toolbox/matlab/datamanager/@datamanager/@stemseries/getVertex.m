function v = getVertex(h,ax)

target = get(ax,'CurrentPoint');
v = vertexpicker(get(h.HGHandle,'MarkerHandle'),target,'-force');
