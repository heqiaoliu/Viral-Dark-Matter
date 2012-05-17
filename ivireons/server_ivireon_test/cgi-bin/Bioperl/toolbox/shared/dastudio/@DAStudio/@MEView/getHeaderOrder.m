function acceptedOrder = getHeaderOrder(h, proposedOrder)

dlgs = DAStudio.ToolRoot.getOpenDialogs(h.ViewManager);
MEView_cb(dlgs(1), 'doReorderProperties', h, proposedOrder);

acceptedOrder = h.getHeaderLabels;