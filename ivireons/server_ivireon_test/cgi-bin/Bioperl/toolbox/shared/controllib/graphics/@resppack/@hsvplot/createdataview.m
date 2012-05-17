function [data, view, dataprops] = createdataview(this, Nresp)
%CREATEDATAVIEW  Abstract Factory method

%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:58 $
data= resppack.hsvdata;
view = resppack.hsvview;
view.AxesGrid = this.AxesGrid;
% Return list of data-related properties of data object
dataprops = data.findprop('HSV');


