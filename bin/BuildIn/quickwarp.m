function NI = quickwarp(I,T,invT)
if invT
    T = invert(T);
end
NI = uint16(imwarp(I,affine2d(T),'OutputView',imref2d(size(I))));

