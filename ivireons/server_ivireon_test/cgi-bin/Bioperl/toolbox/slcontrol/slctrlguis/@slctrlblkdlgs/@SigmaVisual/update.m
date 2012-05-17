function update(this) 
% UPDATE 
%
% Update the visual with new data
 
% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/04/30 00:44:19 $

%Get the new data 
src = this.Application.DataSource;
newData = src.getRawData;
if isempty(newData)
    return;
end

%Get the new linear system to display
sys = newData.Data.LoggedData;

%Check whether the system size has changed and resize axes if needed
iNames = sys.InputName;
oNames = sys.OutputName;
newSize = [length(oNames), length(iNames)];
oldSize = this.hPlot.AxesGrid.size;
if any(newSize > oldSize(1:2))
   this.hPlot.resize(oNames,iNames);
end

%Create a new response and add to the plot
src = resppack.ltisource(sys,...
   'Name',ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizedAtTime',...
   sprintf('%g',newData.Data.time)));
r = this.hPlot.addresponse(src);
r.DataFcn = {'sigma' src r [] 0};
initsysresp(r,'sigma',this.hPlot.Options,[])
%Draw the new response
r.draw;

%Update the legend
this.updateLegend
end