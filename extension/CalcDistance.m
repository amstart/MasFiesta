function result = CalcDistance(p1, p2)
result=zeros(size(p1,1),1);
for i=1:size(p1,1)
    result(i) = sqrt((p2(i,1)-p1(i,1))^2+(p2(i,2)-p1(i,2))^2);
end