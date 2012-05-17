function disp(h)
%DISP   Display this object.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/04/21 03:18:46 $

try
    s.FxptFullName = h.FxptFullName;
    s.Path = h.Path;
    s.PathItem = h.PathItem;
    s.Run =  h.Run;
    s.SimMin = h.SimMin;
    s.SimMax = h.SimMax;
    s.DesignMin = h.DesignMin;
    s.DesignMax = h.DesignMax;
    s.OvfWrap = h.OvfWrap;
    s.OvfSat = h.OvfSat;
    s.DivByZero = h.DivByZero;
    s.ParamSat = h.ParamSat;
    s.SimDT = h.SimDT;
    s.SpecifiedDT = h.SpecifiedDT;
    s.ProposedFL = h.ProposedFL;
    s.ProposedRange = h.ProposedRange;
    s.WordLengthSpecified = h.WordLengthSpecified;
    s.SignedSpecified = h.SignedSpecified;
    s.RepresentableMinProposed = h.RepresentableMinProposed;
    s.RepresentableMaxProposed = h.RepresentableMaxProposed;
    s.ProposedDT = h.ProposedDT;
    s.DTGroup = h.DTGroup;
    s.ReplaceOutDataType = h.ReplaceOutDataType;
    s.LocalExtremumSet = h.LocalExtremumSet;
    s.SharedExtremumSet = h.SharedExtremumSet;
    s.InitValueMin = h.InitValueMin;
    s.InitValueMax = h.InitValueMax;
    s.ModelRequiredMin = h.ModelRequiredMin;
    s.ModelRequiredMax = h.ModelRequiredMax;
    s.Accept = h.Accept;
    s.Comments = h.Comments;
    s.Alert = h.Alert;
    
    disp(s);
catch e
    builtin('disp',h);
end


%[EOF]
