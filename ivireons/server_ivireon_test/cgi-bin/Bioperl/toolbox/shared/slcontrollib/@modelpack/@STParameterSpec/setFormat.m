function setFormat(this,Model,newFormat) 
% SETFORMAT  method to set the format of a SISOTOOL parameter spec object
%
% this.setFormat(Model,newFormat)
%
% Inputs:
%   Model     - a modelpack.STModel object for the SISOTOOL model containing
%               the parameter
%   newFormat - a numerical index or string giving the new parameter format,
%               valid formats can be found from the 'FormatOptions' property, i.e.,
%               this.FormatOptions
%
 
% Author(s): A. Stothert 29-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/05/18 05:52:39 $

nFormatOptions = numel(this.FormatOptions);
if ischar(newFormat)
   newFormat = find(strcmp(newFormat,this.FormatOptions));
   if isempty(newFormat), newFormat = inf; end
end
if nFormatOptions > 1 && newFormat <= nFormatOptions
   %Have valid new format
   if isa(Model,'sisodata.pzgroup')
      %PZGroup object
      this.Minimum      = Model.convertValue(this.Minimum,this.Format,newFormat);
      this.Maximum      = Model.convertValue(this.Maximum,this.Format,newFormat);
      this.InitialValue = Model.convertValue(this.InitialValue,this.Format,newFormat);
      this.TypicalValue = Model.convertValue(this.TypicalValue,this.Format,newFormat);
      this.Format       = newFormat;
   elseif isa(Model,'sisodata.TunedBlock')
      %Tuned block gain object
      this.Minimum      = Model.convertGainValue(this.Minimum,this.Format,newFormat);
      this.Maximum      = Model.convertGainValue(this.Maximum,this.Format,newFormat);
      this.InitialValue = Model.convertGainValue(this.InitialValue,this.Format,newFormat);
      this.TypicalValue = Model.convertGainValue(this.TypicalValue,this.Format,newFormat);
      this.Format       = newFormat;
   else
      %Model api object
      Model.convertValue(this,newFormat);
   end
end