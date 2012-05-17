function bfitAddProp(obj, propName, serialize)
%BFITADDPROP Adds an instance property to a BasicFit/DataStats object 
%
%   BFITADDPROP(OBJ, PROPNAME)
%   BFITADDPROP(OBJ, PROPNAME, SERIALIZE)
%
%   Note: This function creates an HG1 or HG2 instance property with the 
%   following properties 
%       Hidden = true;
%       Copy = off  (There is no built-in copy method in MCOS) 
%  SERIALIZE, if specified, should be 'on' or 'off', which is translated to
%  false or true in the HG2 case. If not specified, the Transient is true
%  in HG2; Serialize if 'off' for HG1.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $    $Date: 2009/05/18 20:48:26 $ 

    
    if nargin < 3
        serialize = 'off';
        transient = true;
    else
        transient = strcmp(serialize, 'off');
    end

    if feature( 'HGUsingMATLABClasses' )
        p = addprop(obj, propName);
        p.Transient = transient;
        p.Hidden = true;
    else
        p = schema.prop(handle(obj), propName, 'MATLAB array');
        p.AccessFlags.Serialize = serialize;
        p.AccessFlags.Copy = 'off';
        p.Visible = 'off';
    end
end
