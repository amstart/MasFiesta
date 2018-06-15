function Load(varargin)
global DFDir
if nargin > 0
    FileName = varargin{1};
    PathName = varargin{2};
    switch FileName(end)
        case 't'
            FilterIndex = 2;
        case 'i'
            FilterIndex = 1;
    end
else
    try
        [FileName, PathName, FilterIndex] = ...
        uigetfile({'*.roi','ImageJ roi (*.roi)'; '*.mat','MAT-File (*.mat)'},'Load Objects',DFDir, 'MultiSelect', 'on'); 
    catch
        [FileName, PathName, FilterIndex] = ...
        uigetfile({'*.roi','ImageJ roi (*.roi)'; '*.mat','MAT-File (*.mat)'},'Load Objects', 'MultiSelect', 'on');        
    end
end
if FilterIndex
    DFDir=PathName;
    switch FilterIndex
        case 2
            DF.loadFIESTAfile(FileName, PathName);
        case 1
            DF.loadROI(FileName, PathName);
    end
end