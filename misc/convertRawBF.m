function convertRawBF(folder)

rep=dir([folder '\bf*.dat']);

for i=1:length(rep) 
    partname=[folder '\' rep(i).name];
    fprintf('converting file %s ...\n',partname); 
    convertfile(partname);
%     delete(partname);
end


end

function convertfile(name)

folder=fileparts(name);

fid=fopen(name,'r+b');
head=fread(fid,10,'int32');

frame=head(1); 
ndat= head(2);
nz  = head(3);
nx  = head(4);
nI  = head(5);

tmp=dir(name);
filesize=tmp.bytes;
nparts=filesize/(4*ndat+10*4);

frewind(fid);
for i=1:nparts
    
    head=fread(fid,10,'int32');
    tmp=fread(fid,ndat,'*single'); 
    tmp=reshape(tmp,[nI*2,nz,nx]);
   
    bf=tmp(1:2:end,:,:)+sqrt(-1)*tmp(2:2:end,:,:);  %convert to complex
    
    frame=head(1); 
    nameframe=sprintf('%s\\frame%.5d',folder,frame);
    save(nameframe,'bf', '-v7.3', '-nocompression');
%     save(nameframe,'bf', '-v6');
end
fclose(fid);
end