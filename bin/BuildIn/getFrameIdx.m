function idx = getFrameIdx
hMainGui=getappdata(0,'hMainGui');
idx = hMainGui.Values.FrameIdx(1);
if length(hMainGui.Values.FrameIdx)>2
    idx(2) = min(hMainGui.Values.FrameIdx(idx+1), hMainGui.Values.MaxIdx(idx+1)); %JochenK
else
    idx(2) = min(hMainGui.Values.FrameIdx(2), hMainGui.Values.MaxIdx(2));
end