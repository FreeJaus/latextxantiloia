% sTs -> Scope Sample Time
% Min Simulation Time sTs*samples
% step.dat

clear;
tune;

sTs=.005;
samples = [300];
names={'y' 'u' '.dat'};
models={'cont','discrete','contdfilt','fp'};

labels=strcat('t','\t','ref');
towrite=0;
for n=1:4
  mdl=char(strcat('PID_',models(n)));
  y=0; u=0; data=0;
  sim(mdl);
  data.y=y;
  data.u=u;

  for m=1:2
    labels=strcat(labels,'\t',names(m),'_',models(n));
  end
  
  towrite(1:samples(1),(2*(n+1))-1)=data.y.signals.values(1:samples(1),2);
  towrite(1:samples(1),2*(n+1))=data.u.signals.values(1:samples(1));
end

towrite(1:samples(1),1)=data.y.time(1:samples(1));
towrite(1:samples(1),2)=data.y.signals.values(1:samples(1));

filetowrite = fopen(char(strcat('step',names(3))),'wt');
fprintf(filetowrite,char(labels));
fclose(filetowrite);
dlmwrite(char(strcat('step',names(3))),towrite,'-append','delimiter','\t','precision','%.3f','roffset',1);