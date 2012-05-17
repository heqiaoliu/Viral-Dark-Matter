function v = getVertex(h,ax)

hpatch = get(h.HGHandle,'children');
v = vertexpicker(hpatch,get(ax,'CurrentPoint'),'-force');
