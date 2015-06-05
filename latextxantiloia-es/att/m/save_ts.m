% sTs -> Scope Sample Time
% Min Simulation Time sTs*samples
% ts.dat

clear;
tune;

sTs=.01;
mdl='PID_discrete';
names={'y' 'u' 'cont'};
samples = [300];
Tp=1.1;
mul=[2,5,10,30,50,100];

labels=strcat('t','\t','ref');
for m=1:2
  labels=strcat(labels,'\t',names(m),'_',names(3));
end

towrite=0;

for n=1:6
  Ts=Tp/mul(n);
 
  y=0; u=0; data=0;
 
  sim(mdl);
  data.y=y;
  data.u=u;
 
  for m=1:2
    labels=strcat(labels,'\t',names(m),'_',sprintf('%i',mul(n)));
  end

  towrite(1:samples,2*n+3)=data.y.signals.values(1:samples,2);
  towrite(1:samples,2*n+4)=data.u.signals.values(1:samples);
end

towrite(1:samples,1)=data.y.time(1:samples);
towrite(1:samples,2)=data.y.signals.values(1:samples);

mdl=char(strcat('PID_',names(3)));

y=0; u=0; data=0;

sim(mdl);
data.y=y;
data.u=u;
towrite(1:samples,3)=data.y.signals.values(1:samples,2);
towrite(1:samples,4)=data.u.signals.values(1:samples);

filetowrite = fopen(char('ts.dat'),'wt');
fprintf(filetowrite,char(labels));
fclose(filetowrite);
dlmwrite(char('ts.dat'),towrite,'-append','delimiter','\t','precision','%.3f','roffset',1);