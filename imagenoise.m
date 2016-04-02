function [imagewithnoise] = imagenoise(eyeimage,ci,cp)
% set up array for recording noise regions
% noise pixels will have NaN values
rowd = double(ci(1));
cold = double(ci(2));
rd = double(ci(3));

irl = round(rowd-rd);
iru = round(rowd+rd);
icl = round(cold-rd);
icu = round(cold+rd);
if (irl-10)>0
    imagepupil = eyeimage( irl-10:iru+20,icl:icu);
else
    imagepupil = eyeimage( 1:iru+20,icl:icu);
end
imagewithnoise = double(eyeimage);

rowp = cp(1)-double(irl);
r = cp(3);

%find top eyelid
topeyelid = imagepupil(1:(rowp-r),:);
lines = findline(topeyelid);

if size(lines,1) > 0
    [xl yl] = linecoords(lines, size(topeyelid));
    yl = double(yl) + irl-1;
    xl = double(xl) + icl-1;
    
    yla = max(yl);
    
    y2 = 1:yla;
    
    ind3 = sub2ind(size(eyeimage),yl,xl);
    imagewithnoise(ind3) = NaN;
    
    imagewithnoise(y2, xl) = NaN;
end

%find bottom eyelid
bottomeyelid = imagepupil((rowp+r):size(imagepupil,1),:);
lines = findline(bottomeyelid);

if size(lines,1) > 0
    
    [xl yl] = linecoords(lines, size(bottomeyelid));
    yl = double(yl)+ irl+rowp+r-2;
    xl = double(xl) + icl-1;
    
    yla = min(yl);
    
    y2 = yla:size(eyeimage,1);
    
    ind4 = sub2ind(size(eyeimage),yl,xl);
    imagewithnoise(ind4) = NaN;
    imagewithnoise(y2, xl) = NaN;
    
end

%For CASIA, eliminate eyelashes by thresholding
% ref = eyeimage < 100;
% coords = find(ref==1);
% imagewithnoise(coords) = NaN;