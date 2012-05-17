function [data, view, dataprops] = createdataview(this, Nresp)
%  CREATEDATAVIEW  Abstract Factory method to create @respdata and
%                  @respview "product" objects to be associated with
%                  a @response "client" object H.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:25:17 $

for ct = Nresp:-1:1
  % Create @respdata objects
  data(ct,1) = wavepack.timedata;
  
  % Create @respview objects
  view(ct,1) = wavepack.timeview;
  view(ct).AxesGrid = this.AxesGrid;
end

% Return list of data-related properties of data object
dataprops = [data(1).findprop('Time'); data(1).findprop('Amplitude')];
