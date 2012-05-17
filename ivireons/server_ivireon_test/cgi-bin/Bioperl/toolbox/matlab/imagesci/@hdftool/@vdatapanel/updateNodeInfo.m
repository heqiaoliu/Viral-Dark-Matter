function updateNodeInfo(this, hdfNode)
%UPDATENODEINFO Set the currentNode for this panel.
%   This will also make changes to the display, as necessary.
%   It is called when the user selects a different node,
%   for example.
%
%   Function arguments
%   ------------------
%   THIS: the object instance.
%   HDFNODE: the node that we are displaying.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:10:33 $

    if nargin>1
        this.currentNode = hdfNode;
    end
    
    fields = {this.currentNode.nodeinfostruct.Fields.Name};
    this.datafieldApi.setString(fields);

    this.firstRecordApi.reset();

    numRecords = this.currentNode.nodeinfostruct.NumRecords;
    this.numRecordsApi.setString(num2str(numRecords));

end
