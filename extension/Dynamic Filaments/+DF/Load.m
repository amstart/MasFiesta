function Load(varargin)
global CurrentDir
if nargin > 0
    FileName = varargin{1};
    PathName = varargin{2};
else
    try
        [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Objects',CurrentDir);
    catch
        [FileName, PathName] = uigetfile({'*.mat','MAT-File (*.mat)';},'Load Objects');        
    end
    CurrentDir=PathName;
end
if FileName~=0
    DF.loadFIESTAfile(FileName, PathName)
end