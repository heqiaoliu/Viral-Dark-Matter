function r = eml_scalar_atan2(y,x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

r = eml_atan2(y,x);

% % The following code captures the edge-case behavior of MATLAB.
% % Some sections may not be necessary, depending on what the run-time
% % atan2() does.  It is preserved here in case we want to use this
% % function to generate the default RTW version of atan2.
% outcls = class(y+x);
% pid2 = eml_const(cast(eml_rdivide(pi,2),outcls));
% if isnan(x) || isnan(y)
%     r = eml_guarded_nan(outcls);
% elseif isinf(y) && isinf(x)
%     if y > 0
%         y = ones(outcls);
%     else
%         y = -ones(outcls);
%     end
%     if x > 0
%         x = ones(outcls);
%     else
%         x = -ones(outcls);
%     end
%     r = eml_atan2(y,x);
% elseif x == 0
%     if y > 0
%         r = pid2;
%     elseif y < 0
%         r = -pid2;
%     else
%         r = zeros(outcls);
%     end
% else
%     r = eml_atan2(y,x);
% end
