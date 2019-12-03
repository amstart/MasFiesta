function vel=CalcVelocity(track)
%the major aim here is to match GFP intensity data with velocity data. If
%the frame of the GFP intensity is taken after the corresponding microtubule frame, the
%velocity of that microtubule frame should be computed with the help of the
%next frame, as the corresponding GFP frame lies between those two
%frames. UPDATE: Shifted GP instead in segmentFIESTAFils. for easier use,
%the first velocity is the same as the second
nData=size(track,1);
if nData>1
    vel=nan(nData,1);
    for i=2:nData
       vel(i)=(track(i,2)-track(i-1,2))/(track(i,1)-track(i-1,1));
    end
    vel(1) = vel(2);
else
    vel=nan(size(track,1),1);
end