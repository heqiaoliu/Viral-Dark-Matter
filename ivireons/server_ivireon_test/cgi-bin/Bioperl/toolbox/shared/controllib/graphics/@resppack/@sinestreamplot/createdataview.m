function [data, view, dataprops] = createdataview(this, Nresp)
%  CREATEDATAVIEW  Abstract Factory method to create @respdata and
%                  @respview "product" objects to be associated with
%                  a @response "client" object H.

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:24:57 $

for ct = Nresp:-1:1
   % Create data
   data(ct,1) = wavepack.timedata;   
   % Create the corresponding @SineView object
   view(ct,1) = resppack.sineview;
   view(ct,1).AxesGrid = this.AxesGrid;
end

% Return list of data-related properties of data object
dataprops = [data(1).findprop('Time'); data(1).findprop('Amplitude')];