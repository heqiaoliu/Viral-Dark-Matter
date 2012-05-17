function targetdevicetypechanged(hRTWInfo, correctAttribClass)

% Get handle to current attributes class


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $  $Date: 2004/08/10 02:23:15 $
if isempty(hRTWInfo.WordLengths)
  hThisAttribClass = [];
else
  hThisAttribClass = hRTWInfo.WordLengths.classhandle;
end

% Get handle to correct attributes class
% Set WordLengths to object of correct attributes class if different
if isempty(correctAttribClass)
  hRTWInfo.WordLengths=[];
else
  [correctPackage, correctClass] = strtok(correctAttribClass, '.');
  if ~isempty(correctClass)
    correctClass(1) = [];
  end
  
  hCorrectPackage = findpackage(correctPackage);
  if isempty(hCorrectPackage)
    warnTxt = ['Could not find package: ''', correctPackage, ''''];
    hRTWInfo.WordLengths = [];
  else
    hCorrectClass = findclass(hCorrectPackage, correctClass);
    if isempty(hCorrectClass)
      warnTxt = ['Could not find class: ''', correctAttribClass, ''''];
      hRTWInfo.WordLengths = [];
    else
      if ((isempty(hThisAttribClass)) | ...
          (~hThisAttribClass.isDerivedFrom(hCorrectClass)))
         hRTWInfo.WordLengths= eval(correctAttribClass);
      end
    end
  end
end

if exist('warnTxt', 'var')
  warning(warnTxt);
end

% Refresh Simulink Data Explorer
daexplr('Refresh');