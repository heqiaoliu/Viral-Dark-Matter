function s = bfitcreateeqnstrings(datahandle,fit,pp,resid)
% BFITCREATEEQNSTRINGS Create result strings Basic Fitting GUI.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2006/11/29 21:50:27 $

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
if isequal(guistate.normalize,true)
	normalizedState = true;
	normalized = getappdata(double(datahandle),'Basic_Fit_Normalizers');
    switch fit
        case {0,1}
            normstring = sprintf('\n\nUses the centered\nand scaled variable\n\nz = (x-mu)/sigma\nmu = %0.5g\nsigma = %0.5g', ...
                normalized(1), normalized(2));
        otherwise
            normstring = sprintf('\n\nwhere z is centered\nand scaled:\n\nz = (x-mu)/sigma\nmu = %0.5g\nsigma = %0.5g', ...
                normalized(1), normalized(2));
    end
else
    normstring = '';
    normalizedState = false;
end

switch fit
case {0,1}
    s = sprintf('%s%s\n\nNorm of residuals = 0', eqnstring(fit, normalizedState), normstring);
otherwise
    s = sprintf('%s%s',eqnstring(fit, normalizedState),normstring);
   
    s = sprintf('%s\n\nCoefficients:\n',s);
    for i=1:length(pp)
    	s=[s sprintf('  p%g = %0.5g\n',i,pp(i))];
    end
    
    s = sprintf('%s\n%s\n',s,'Norm of residuals = ');
    s = [s '     ' num2str(resid,5) sprintf('\n')];

end

%-------------------------------

function s = eqnstring(fitnum, normalizedState)

if isequal(fitnum,0)
    s = 'Spline interpolant';
elseif isequal(fitnum,1)
    s = 'Shape-preserving interpolant';
else
    if normalizedState
        xz = 'z';
    else
        xz = 'x';
    end
    fit = fitnum - 1;
    s = sprintf('y =');
    for i = 1:fit
        if i == fit
            s = sprintf('%s p%s*%s +',s,num2str(i), xz);
        else
            s = sprintf('%s p%s*%s^%s +',s,num2str(i),xz,num2str(fit+1-i));
        end
        if isequal(mod(i,2),0)
            s = sprintf('%s\n     ',s);
        end
    end
    s = sprintf('%s p%s ',s,num2str(fit+1));
end

    