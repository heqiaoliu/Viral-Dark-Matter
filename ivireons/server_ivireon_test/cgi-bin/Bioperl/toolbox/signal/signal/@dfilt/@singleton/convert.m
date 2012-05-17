function Hd2 = convert(Hd,newstruct)
%CONVERT Convert structure of DFILT object.
%   CONVERT(H,NEWSTRUCT) converts DFILT object H to the structure defined by
%   string NEWSTRUCT.
%
%   EXAMPLE:
%           Hd1 = dfilt.df2t;
%           Hd2 = convert(Hd1,'df1');
%           % returns Hd2 as a direct-form 1 discrete-time filter.
%  
%   See also DFILT.

%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.9 $  $Date: 2010/05/20 03:10:10 $ 

error(nargchk(2,2,nargin,'struct'))

if ~ischar(newstruct)
  error(generatemsgid('MustBeAString'),'New structure must be entered as a string.')
end

if ~ismethod(Hd,['to',newstruct])
  error(generatemsgid('NotSupported'),'Filter structure %s not recognized.',newstruct);
end  

p = findprop(Hd, 'arithmetic');

% If the property is not there or is private, we are in "double" mode.
if ~isempty(p) && strcmpi(p.AccessFlags.PublicGet, 'On')
    switch lower(Hd.Arithmetic)
        case 'single'
            warning(generatemsgid('unquantizing'), ...
                'Using reference filter for structure conversion. Resulting filter has arithmetic set to ''double''.');
            Hd = reffilter(Hd);
        case 'fixed'
            warning(generatemsgid('unquantizing'), ...
                'Using reference filter for structure conversion. Fixed-point attributes will not be converted.');
            Hd = reffilter(Hd);
        otherwise
            % NO OP, double.
    end
end

Hd2 = feval(['to',newstruct], Hd);
setfdesign(Hd2,getfdesign(Hd)); % Carry over fdesign obj
setfmethod(Hd2,getfmethod(Hd));

if ~isa(Hd2,'dfilt.singleton')
  error(generatemsgid('DFILTErr'),'New structure is not a discrete-time filter object.');
end
