function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%  Author(s): John Glass
%  Revised  : Kamesh Subbarao 10-15-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:24:16 $
this.installtip(this.Curves,tipfcn,info)
