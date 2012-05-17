function Value = get(sys,Property)
%GET  Access/query IDMODEL property values.
%
%   VALUE = GET(SYS,'PropertyName') returns the value of the
%   specified property of the IDMODEL model SYS.  An equivalent
%   syntax is
%       VALUE = SYS.PropertyName .
%
%   GET(SYS) displays all properties of SYS and their values.
%   Type HELP IDPROPS for more detail on IDMODEL properties.
%
%   See also SET, TFDATA, ZPKDATA, SSDATA,  IDPROPS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.10 $  $Date: 2009/12/05 02:02:59 $

% Generic GET method for all IDMODEL children.
% Uses the object-specific methods PNAMES and PVALUES
% to get the list of all public properties and their
% values (PNAMES and PVALUES must be defined for each
% particular child object)

ni = nargin;
error(nargchk(1,2,ni,'struct'));

if ni==2
    % GET(SYS,'Property') or GET(SYS,{'Prop1','Prop2',...})
    CharProp = ischar(Property);
    if CharProp
        Property = {Property};
    elseif ~iscellstr(Property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Get all public properties
    AllProps = pnames(sys);
    [~,AlgProp] = iddef('algorithm');
    AllProps = [AllProps;AlgProp'];
    
    % Loop over each queried property
    Nq = numel(Property);
    Value = cell(1,Nq);
    for i = 1:Nq
        % Find match for k-th property name and get corresponding value
        % RE: a) Must include all properties to detect multiple hits
        %     b) Limit comparison to first 7 chars (because of OutputName)
        
        % Special warning for MISO IDPOLY using matrices for B and F
        if isa(sys,'idpoly') && any(strcmpi(Property{i},{'b','f'})) && ...
                size(sys,2)>1 && pvget(sys,'BFFormat')==-1
            ctrlMsgUtils.warning('Ident:idmodel:MISOidpolyDoubleBF')
        end
        
        try
            Value{i} = pvget(sys,pnmatchd(Property{i},AllProps,7));
        catch E
            throw(E)
        end
    end
    
    % Strip cell header if PROPERTY was a string
    if CharProp,
        Value = Value{1};
    end
    
elseif nargout
    % STRUCT = GET(SYS)
    Value = cell2struct(pvget(sys),pnames(sys),1);
else
    % GET(SYS)
    %  PropStr = pnames(sys);
    % [ValStr] = pvget(sys);
    
    %disp(pvformat(PropStr,ValStr)) %LL: couldn't make this work
    cell2struct(pvget(sys),pnames(sys),1)
    
    if isa(sys,'idpoly') && size(sys,2)>1
        CF = pvget(sys,'BFFormat');
        txt = '';
        HL = feature('hotlinks'); 
        if CF==-1
            if HL
                txt = str2mat(txt,sprintf(' NOTE: This model uses double matrices for "b" and \n "f" properties. In a future release, these polynomials\n will be represented by cell arrays. Use <a href="matlab:help(''idpoly/setPolyFormat'')">setPolyFormat</a>\n command to either continue using the matrix format\n (backward compatibility mode) or to update the model\n to use cell arrays for these polynomials.'));
            else
                txt = str2mat(txt,sprintf('NOTE: This model uses double matrices for "b" and \n "f" properties. In a future release, these polynomials\n will be represented by cell arrays. Use "setPolyFormat"\n command to either continue using the matrix format\n (backward compatibility mode) or to update the model\n to use cell arrays for these polynomials. Type \n "help idpoly/setPolyFormat" for more information.'));
            end
        elseif CF==1
            if HL
                txt = str2mat(txt,sprintf('NOTE: Model has been designated to work in backward\ncompatibility mode. To switch to cell arrays for B\nand F polynomials, use the <a href="matlab:help(''idpoly/setPolyFormat'')">setPolyFormat</a> command.'));
            else
                txt = str2mat(txt,sprintf('NOTE: Model has been designated to work in backward\ncompatibility mode. To switch to cell arrays for B\nand F polynomials, use the "setPolyFormat" command.'));
            end
        else
            % CF = 0
            %txt = str2mat(txt,sprintf('\nThis model uses cell arrays for B and F polynomials.'));
        end
        disp(txt)
        disp(' ')
    end
end
