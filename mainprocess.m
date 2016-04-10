function [hd,result,time_total,time_createtemplate,time_rebuiltDataBase] = mainprocess(testimage)
result='';
t0 = clock;
hmthresh = 0.3;
write = 1; %whether to output intermediate process image
%InputPath='C:\Users\admin\Desktop\Iris test\Iris DB\';
WorkPath=pwd;
%InputPath='/Users/zz/Desktop/Iris test/Iris DB';
InputPath=[WorkPath,'/','Iris DB'];
InputPath_=fullfile(WorkPath,'Iris DB');
%if Mac
if isunix
    savefile = [InputPath,'/','template.mat'];
%if Windows
else
    savefile = [InputPath,'template.mat'];
end
t1 = clock;
[templatetest, masktest] = createiristemplate('/Users/zz/Desktop/Iris test/standard_L.jpg',write);
time_createtemplate = etime(clock, t1);
%generate or load Iris feature library
[stae,mess]=fileattrib(savefile);
%if Windows
%FileName_bmp=dir(strcat(InputPath,'*.bmp'));
%if Mac
FileName_bmp=dir(strcat(InputPath,'/','*.bmp'));
FileName_jpg=dir(strcat(InputPath,'/','*.jpg'));
FN=[FileName_bmp;FileName_jpg];
%FN=
NumFile=length(FN);
if stae
    load(savefile);
    % if DB File number doesn't match template, rebuild template.mat
    % else read template.mat
    if NumFile == size(template,3);
        rebuilt = 0;
        time_rebuiltDataBase = 0;
    else
        rebuilt = 1;
    end
else
    % or template.mat doesn't exist
    rebuilt = 1;
end
if rebuilt
    t2 = clock;
    %if Windows
    %FileName_bmp=dir(strcat(InputPath,'*.bmp'));
    %if Mac
    FileName_bmp=dir(strcat(InputPath,'/','*.bmp'));
    FileName_jpg=dir(strcat(InputPath,'/','*.jpg'));
    FN=[FileName_bmp;FileName_jpg];
    NumFile=length(FN);
    [row,clo] = size(templatetest);
    template = zeros(row,clo,NumFile);
    mask = zeros(row,clo,NumFile);
    for i=1:NumFile
        tempFileName=FN(i).name;
        %if Windows
        %ImPath=strcat(InputPath,tempFileName);
        %if Mac
        ImPath=strcat(InputPath,'/',tempFileName);
        [template_temp, mask_temp] = createiristemplate(ImPath,write);
        template(:,:,i) = template_temp;
        mask(:,:,i) = mask_temp;
    end
    
    save(savefile,'template','mask','FN');
    time_rebuiltDataBase = etime(clock, t2);
end
%measure Hemming diatance
%NumFile = length(template);

for i=1:NumFile
    hd(i) = gethammingdistance(templatetest, masktest, template(:,:,i), mask(:,:,i), 4);
    if hd(i) < hmthresh

        result =FN(i).name;
        break;
    end

end

if i== NumFile
    k = find(hd==min(hd));
    result = FN(k).name;
end
%if Windows
if ~isunix
    Route = [InputPath,result];
%if Mac
else
    Route = [InputPath,'/',result];
end
disp(['Result is ',Route]);
time_total = etime(clock, t0);