% sTs -> Scope Sample Time
% Min Simulation Time sTs*samples
% bw.dat

clear;
tune;

sTs=Ts/3;
samples = [325,300];
freq_range = [0.01,15];
names={'y' 'u' 'mag' 'deg' '.dat'};
models={'cont','discrete','contdfilt'};

labels=strcat('freq');
in = frest.Sinestream('Frequency',linspace(freq_range(1),freq_range(2),samples(2)),'FreqUnits','Hz');

towrite=0;

for n=1:3
  mdl=char(strcat('PID_',models(n)));
  
  sysest=0; simout=0; mag=0; phase=0; freq=0;
  
  [sysest,simout] = frestimate(mdl,getlinio(mdl),in);
  [mag,phase,freq]=bode(sysest);
  
  for m=1:2
    labels=strcat(labels,'\t',names(2+m),'_',models(n));
  end
  
  towrite(1:samples(2),(2*n),1)=20*log10(mag(1,1,1:samples(2)));
  towrite(1:samples(2),(2*n)+1,1)=phase(1,1,1:samples(2));
end

towrite(1:samples(2),1)=freq(1:samples(2))/(2*pi);

filetowrite = fopen(char(strcat('bw',names(5))),'wt');
fprintf(filetowrite,char(labels));
fclose(filetowrite);
dlmwrite(char(strcat('bw',names(5))),towrite,'-append','delimiter','\t','precision','%.3f','roffset',1);