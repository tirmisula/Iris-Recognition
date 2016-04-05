% createiristemplate - generates a biometric template from an iris in
% an eye image.
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%	eyeimage_filename   - the file name of the eye image
%
% Output:
%	template		    - the binary iris biometric template
%	mask			    - the binary iris noise mask


function [template, mask,circleiris,circlepupil] = createiristemplate(eyeimage_filename,write)

% path for writing diagnostic images
global DIAGPATH

stdsize = [300,400];
%normalisation parameters
radial_res = 100;
angular_res = 240;
% with these settings a 9600 bit iris template is
% created

%feature encoding parameters
nscales=1;
minWaveLength=18;
mult=1; % not applicable if using nscales = 1
sigmaOnf=0.5;

eyeimage = imread(eyeimage_filename); 
% Uni 400x300 resolution
if size(eyeimage,1)~=stdsize(1)
    %h=warndlg('图片大小不符','警告','modal'); 
    eyeimage = imresize(eyeimage,stdsize);
    imwrite(eyeimage,eyeimage_filename);
end

savefile = [eyeimage_filename,'-houghpara.mat'];
[stat,mess]=fileattrib(savefile);

if stat == 1
    % if this file has been processed before
    % then load the circle parameters and
    % noise information for that file.
    %if Windows
    %if any(strfind(savefile,'Iris DB\'))
    %if Mac
    if any(strfind(savefile,['Iris DB',filesep]))
    load(savefile);
    else
%     [circleiris circlepupil imagewithnoise] = segmentiris(eyeimage);
%     disp('+');disp(circleiris(3));disp('+');
%     disp('p');disp(circlepupil(3));disp('p');
%     save(savefile,'circleiris','circlepupil','imagewithnoise');
   [circleiris circlepupil out] =  thresh(eyeimage,50,130);
   imagewithnoise = imagenoise(eyeimage,circleiris,circlepupil);
   save(savefile,'circleiris','circlepupil','imagewithnoise');
    end
    
else
    
    % if this file has not been processed before
    % then perform automatic segmentation and
    % save the results to a file
    
%     [circleiris circlepupil imagewithnoise] = segmentiris(eyeimage);
%     disp('+');disp(circleiris(3));disp('+');
%     disp('p');disp(circlepupil(3));disp('p');
%     save(savefile,'circleiris','circlepupil','imagewithnoise');
    [circleiris circlepupil out] =  thresh(eyeimage,50,130);
   imagewithnoise = imagenoise(eyeimage,circleiris,circlepupil);
   save(savefile,'circleiris','circlepupil','imagewithnoise');
   
end

disp('iris');disp(circleiris(3));disp('iris');
disp('pupil');disp(circlepupil(3));disp('pupil');
disp('filename');disp(savefile);disp('filename');
disp('');

% WRITE NOISE IMAGE
%

imagewithnoise2 = uint8(imagewithnoise);
imagewithcircles = uint8(eyeimage);

%get pixel coords for circle around iris
[x,y] = circlecoords([circleiris(2),circleiris(1)],circleiris(3),size(eyeimage));

ind2 = sub2ind(size(eyeimage),double(y),double(x)); 

%get pixel coords for circle around pupil
[xp,yp] = circlecoords([circlepupil(2),circlepupil(1)],circlepupil(3),size(eyeimage));
ind1 = sub2ind(size(eyeimage),double(yp),double(xp));


% Write noise regions
imagewithnoise2(ind2) = 255;
imagewithnoise2(ind1) = 255;
% Write circles overlayed
imagewithcircles(ind2) = 255;
imagewithcircles(ind1) = 255;


% w = cd;
% cd(DIAGPATH);
%if Windows
%pos = findstr(eyeimage_filename,'\');
%if Mac
pos = findstr(eyeimage_filename,filesep);
posdot = findstr(eyeimage_filename,'.');
l = length(pos);
addpos = pos(l);
%if Windows
if ~isunix
final_segmented = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\segmented-',eyeimage_filename(addpos+1:posdot),'.jpg'];
mkdir(strrep([eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\'],'\','/'));
else
%if Mac
final_segmented = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot-1),'/segmented-',eyeimage_filename(addpos+1:posdot-1),'.jpg'];
mkdir(strrep([eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot-1),'/'],'\','/'));
end
imwrite(imagewithcircles,final_segmented,'jpg');
% cd(w);

if write
if ~isunix
%if Windows
final_noise = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\noise-',eyeimage_filename(addpos+1:posdot),'.jpg'];    
else 
%if Mac
final_noise = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot-1),'/noise-',eyeimage_filename(addpos+1:posdot-1),'.jpg'];    
imwrite(imagewithnoise2,final_noise,'jpg');  
end
%write the *-gabor_oiginal.jpg

writeoriginal(circleiris,circlepupil,eyeimage,eyeimage_filename,nscales, minWaveLength, mult, sigmaOnf);


end

% perform normalisation

[polar_array noise_array] = normaliseiris(imagewithnoise, circleiris(2),...
    circleiris(1), circleiris(3), circlepupil(2), circlepupil(1), circlepupil(3),eyeimage_filename, radial_res, angular_res,write);


% WRITE NORMALISED PATTERN, AND NOISE PATTERN
% w = cd;
% cd(DIAGPATH);

if write
if ~isunix
%if Windows
final_polar = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\polar-',eyeimage_filename(addpos+1:posdot),'.jpg'];
final_polarnoise = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\polarnoise-',eyeimage_filename(addpos+1:posdot),'.jpg'];
else
%if Mac
final_polar = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot-1),...
    '/polar-',eyeimage_filename(addpos+1:posdot-1),'.jpg'];
final_polarnoise = [eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot-1),...
'/polarnoise-',eyeimage_filename(addpos+1:posdot-1),'.jpg'];
end
%mkdir(strrep([eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\'],'\','/'));
%mkdir(strrep([eyeimage_filename(1:addpos),eyeimage_filename(addpos+1:posdot),'\'],'\','/'));
imwrite(polar_array,final_polar,'jpg');
imwrite(noise_array,final_polarnoise,'jpg');

% cd(w);
end
% perform feature encoding
% [template mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf); 
  [template mask] = encode(polar_array, noise_array, nscales, minWaveLength, mult, sigmaOnf,eyeimage_filename); 