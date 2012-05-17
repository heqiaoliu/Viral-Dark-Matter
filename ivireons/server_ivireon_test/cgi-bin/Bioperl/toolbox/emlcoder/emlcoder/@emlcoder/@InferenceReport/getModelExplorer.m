function me = getModelExplorer(this,title)

% Copyright 2002-2009 The MathWorks, Inc.

prefSection = '';
show = false;
me = DAStudio.Explorer(this, prefSection, show);
am = DAStudio.ActionManager;
am.initializeClient(me);

w = 900; h = 675;
screenSize = get(0, 'ScreenSize');
pX = max(1, (screenSize(3) - w) / 2);
pY = max(1, (screenSize(4) - h) / 2);
me.position = [pX, pY, w, h];

me.Title = title;
me.showTreeView(false);
me.showListView(false);
me.showDialogView(true);
me.showStatusBar(false);
