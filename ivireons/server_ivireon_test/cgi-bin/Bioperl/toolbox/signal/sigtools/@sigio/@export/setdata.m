function out = setdata(this,out)
%SETDATA SetFunction for Data property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/04/11 18:44:53 $

if isa(out, 'sigutils.vector') && ~strcmpi(class(elementat(out, 1)),'double'),
    set(this,'privData',out);
else
    datamodel = this.privData;
    if isempty(datamodel),
        datamodel = sigutils.vector;
        set(this, 'privData', datamodel);
    else
        datamodel.clear;
    end
    if ~iscell(out), out = {out}; end
    for indx = 1:length(out),
        if strcmpi(class(out{indx}),'double'),
            out{indx} = sigutils.vector(50, out{indx});
        end
        
        datamodel.addelement(out{indx});
    end
end

setupdestinations(this);

this.isapplied = false;

out = [];

% [EOF]