function dlg = getDialogSchema(this, ~)

%   Copyright 2009-2010 The MathWorks, Inc.


dlg.DialogTitle = DAStudio.message('Slvnv:simcoverage:subsysSelTitle');
tree.Type = 'tree';
tree.TreeItems  = this.m_treeItems;
tree.TreeMultiSelect = false;
tree.ExpandTree = true;
tree.ObjectProperty = 'm_selectedItem';

dlg.PostApplyMethod  = 'postApply';
dlg.StandaloneButtonSet = {'Ok', 'Cancel'};
dlg.Items = {tree};       