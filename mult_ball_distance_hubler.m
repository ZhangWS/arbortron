%began 19 July 2011, modified 5 August 2011. 

%This modification is to add in
%behavior to keep track of potential collisions among ball bearings. Currently grid-detection is working but not within-grid detection. 
%I'm not sure what the behavior of balls should be when they are within
%distance 1 of each other (or sqrt 2 diagonally), but it should ideally do
%something that leads to bucket brigade behavior.

clear all;

%grid properties here
s=20; %s x s grid

N=3; %number of particles

%set initial ball bearing properties HERE
%particle 1 characteristics
ballcharge(1,1)=0.5; %ballcharge is 0 (negative), 0.5 (neutral) or 1 
%(positive) depending on which electrode it touches
xp(1,1)=8; %(this is the free moving particle)
yp(1,1)=4;

%particle 2 characteristics
ballcharge(2,1)=0.5;
xp(2,1)=8;
yp(2,1)=5;

ballcharge(3,1)=0.5;
xp(3,1)=7;
yp(3,1)=4;

dist(N,N); %creates a distance matrix for calculating distance between ball bearings

%number of time steps
iterations=10; 

%wire properties here
wirex(1)=round(s/2); %right now at 6
wirey(1)=1;
wirex(2)=round(s/2); %also at 6
wirey(2)=s;

%this is a grid that keeps track of ball positions so that we may detect
%collisions. 
gridocc=zeros(s,s);

%vstore=zeros(s,s,); %this is ONLY FOR DEBUGGING

for t=1:iterations

    %the next part sets up voltage and resistance for the grid
    for i=1:s
        for j=1:s
            v(i,j)=0;
            vnew(i,j)=0;
            r(i,j)=1;
            gridocc(i,j)=0; %hey look, all points are not occupied!
        end
    end

    %setup resistivity of wire independent of the ball bearings
    r(wirex(1),wirey(1))=0.01;
    r(wirex(2),wirey(2))=0.01;
    
    %here, specify resistivity of the particle. Floor is because distance
    %is discrete
    for n=1:N
        r(floor(xp(n,t)),floor(yp(n,t)))=0.01;
        gridocc(floor(xp(n,t)),floor(yp(n,t)))=1; %so these grid points are occupied!
    end

    for i=2:s-1
        for j=2:s-1 %define conductance, confirmed correct
               cr(i,j)=1/(r(i+1,j)+r(i,j));
               cl(i,j)=1/(r(i-1,j)+r(i,j));
               cu(i,j)=1/(r(i,j+1)+r(i,j));
               cd(i,j)=1/(r(i,j-1)+r(i,j));
               cs=cr(i,j)+cl(i,j)+cu(i,j)+cd(i,j);
               cr(i,j)=cr(i,j)/cs;
               cl(i,j)=cl(i,j)/cs;
               cd(i,j)=cd(i,j)/cs;
               cu(i,j)=cu(i,j)/cs;
        end
    end

    %explicitly set boundary conductance to 0. It's not really necessary
    %but it's nice and redundant for now.
    for i=1:s
        cu(i,1)=0;
        cd(i,1)=0;
        cr(i,1)=0;
        cl(i,1)=0;
        cu(i,s)=0;
        cd(i,s)=0;
        cr(i,s)=0;
        cl(i,s)=0;  
    end
    
    for j=1:s
        cu(1,j)=0;
        cd(1,j)=0;
        cr(1,j)=0;
        cl(1,j)=0;
        cu(s,j)=0;
        cd(s,j)=0;
        cr(s,j)=0;
        cl(s,j)=0;  
    end
    
     if N > 1 %if there's more than one ball bearing, calculate the distance
        for m=1:N %this is the name of the ball bearing
            for n=1:N %in relation to distance of the nth ball bearing
                dist(m,n)=sqrt((xp(m,t)-xp(n,t))^2+(yp(m,t)-yp(n,t))^2);
            end
        end
    
     end %end distance calculating loop. Now what?
    
    for n=1:1500 %iterative convergence achieved
        for i=1:s %isolating boundary conditions - should they be put before or after convergence calculations? Should probably check on that
            v(i,1)=v(i,2);
            vnew(i,1)=v(i,2);
            v(i,s)=v(i,s-1);
            vnew(i,s)=v(i,s-1);
        end
        
        
        for j=2:s-1 %isolating boundary conditions
            v(1,j)=v(2,j);
            vnew(1,j)=v(2,j);
            v(s,j)=v(s-1,j);
            vnew(s,j)=v(s-1,j);
        end
        
        
        %this presumably sets the voltage for the wire
        %note that the graph is flipped 90 degrees from the matrix storing v values
        v(wirex(1),wirey(1))=1;
        vnew(wirex(1),wirey(1))=1;
        v(wirex(2),wirey(2))=0;
        vnew(wirex(2),wirey(2))=0;

        for i=2:s-1
           for j=2:s-1
                for k=1:N
                    if ballcharge(k,t) ~= 0.5
                        v(floor(xp(k,t)),floor(yp(k,t)))=ballcharge(k,t);
                        vnew(floor(xp(k,t)),floor(yp(k,t)))=ballcharge(k,t);
                    end %end ifloop
                end %end k-loop
                
                %relaxation algorithm
                %impose onto vnew so that calculations in v aren't affected
                %by location where calculation begins
                vnew(i,j)=v(i+1,j)*cr(i,j)+v(i-1,j)*cl(i,j)+v(i,j+1)*cu(i,j)+v(i,j-1)*cd(i,j);
           
           end %end j-loop
        end %end i-loop
                 
        v=vnew;
        vr=round(v*1000);
        %vstore(:,:,t)=vr; %this is an extraneous matrix checking
         % potential through every iteration. As it is memory intensive, it
         % is only used for debugging
    end %n-loop

 
  
    %let's draw the initial empty grid!
    figure
    for i=1:s-1
        for j=1:s-1
            %patch builds a graph using vertices specified below.
            %two options for display - one with lines on integers or the
            %others with lines at midpoints between integers. Currently
            %lines on integers is default.
            patch([i,i+1,i+1,i]-1,[j,j,j+1,j+1]-1,[v(i,j),v(i,j),v(i,j)]);
            %patch([i,i+1,i+1,i]-.5,[j,j,j+1,j+1]-.5,[v(i,j),v(i,j),v(i,j)]);
            hold on; %holds on to the graph while it draws the next set
        end
    end
     %WHAT IS i?
 
     
     %this is probably where the N loop should start to calculate forces
     
  for n=1:N 
        x=floor(xp(n,t));
        y=floor(yp(n,t));

            Fx=((vr(x+1,y)-vr(x,y))^2-(vr(x-1,y)-vr(x,y))^2)/10000.; %calculates horizontal force Fx
            Fy=((vr(x,y+1)-vr(x,y))^2-(vr(x,y-1)-vr(x,y))^2)/10000.; %calculates vertical force Fy
            Fnw=(((vr(x-1,y+1)-vr(x,y))^2)-((vr(x+1,y-1)-vr(x,y))^2))/(10000.*sqrt(2)); %calculates diagonal force from NW quad to SE quad
            Fne=(((vr(x+1,y+1)-vr(x,y))^2)-((vr(x-1,y-1)-vr(x,y))^2))/(10000.*sqrt(2)); %calculates diagonal force from NE quad to SW quad
   
        fv=[Fx Fy Fnw Fne];
        fmax=max(abs(fv));


            
    for m=1:4
      
        if fmax == abs(fv(m))
            if fv(m) < 0
                sig = -1;
            else
                sig = 1;
            end
    
            if fmax < 1
                fmax =1;
            end 
            
            if fmax > 2
                fmax = 2;
            end
        %now need to identify which force it is!
        
        if x > 6
            xsign=-1;
        else
            xsign=1;
        end

            if m == 1
                 x=xp(n,t)+sig*fmax;%x coordinate
                 y=yp(n,t);%if max is Fy
               
            elseif m == 2
                 x=xp(n,t);
                 y=yp(n,t)+sig*fmax;%y coordinate
                
            elseif m==3 %if max is Fnw
                 x=xp(n,t)+xsign*sqrt(0.5)*fmax;
                 y=yp(n,t)+sig*sqrt(0.5)*fmax;
            elseif m==4 %if max is Fne
                 x=xp(n,t)+sig*sqrt(0.5)*fmax;
                 y=yp(n,t)+sig*sqrt(0.5)*fmax;
            end

     
            if y > s-1 %if it hits negative electrode
                y = s-1;
                ballcharge(n,t+1)=ballcharge(n,t);
                if x > round(s/2)-0.8 && x < round(s/2)+0.8   
                    ballcharge(n,t+1)=0;
                end
            elseif y < 3  
                if y < 2
                    y = 2;
                end
                ballcharge(n,t+1)=ballcharge(n,t);
                if x > round(s/2)-0.8 && x < round(s/2)+0.8
                    ballcharge(n,t+1)=1;
                end
            else
                if ballcharge(n,t) == 0.5
                    ballcharge(n,t+1)=0.5;
                else
                    ballcharge(n,t+1)=ballcharge(n,t);
                end
            end %if statement on ballpotential
                  
           if gridocc(floor(x),floor(y)) == 1 %or, if this point is occupied already
               %condition 1: if the other grid you're moving to is occupied by another ball 
               if floor(x) ~= floor(xp(n,t)) || floor(y) ~= floor(yp(n,t)) %well, oops, something else is already here
                    ballcharge(n,t+1)=(v(floor(x),floor(y))+v(floor(xp(n,t))))/2; %for now just set voltage to the grid of the other one. Objective is to make ball bearings REPEL.

                    %how to search for the other ball?
                    for i=1:N
                        if i~= n %and it's not equal to the current position
                            if floor(xp(i,t)) == floor(x) && floor(yp(i,t)) == floor(y)
                                ballcharge(i,t+1)=(v(floor(x),floor(y))+v(floor(xp(n,t))))/2;
                            end
                        end
                    end

                    %how do we change the ball charge of the other ball
                    %bearing if we don't know which one it is from x and y?
                    
                    x = xp(n,t);
                    y = yp(n,t); %stay where you are
                %condition 2: you're staying in your grid
               end
           else
               %condition 1: if the coordinates are different...
               if x ~= xp(n,t) || y~=yp(n,t) %if this spot isn't the one you're at already
                    gridocc(floor(xp(n,t)),floor(yp(n,t)))=0;
                    gridocc(floor(x),floor(y))=1;
                    %then what?
               end        
               
           end
       
        end %end force calculations
 
        xp(n,t+1)=x;
        yp(n,t+1)=y;
    
        
        
        
        plot([xp(n,t),x],[yp(n,t),y],'g');
        hold on;
        plot(xp(n,t),yp(n,t),'or','markersize',5+t)
        hold on
        axis('square');
    
    end
    
  end
end


%make patch gram showing where particle moves
figure
for i=1:s
   for j=1:s
       patch([i,i+1,i+1,i]-1,[j,j,j+1,j+1]-1,[v(i,j),v(i,j),v(i,j)]);
       %patch([i,i+1,i+1,i]-.5,[j,j,j+1,j+1]-.5,[v(i,j),v(i,j),v(i,j)]);
       hold on;
   end
end


for t=1:iterations
    for n=1:N
        plot(xp(n,t),yp(n,t),'or','markersize',5+t)
        xx(t,n)=xp(n,t);
        yy(t,n)=yp(n,t);
    end
end



for n=1:N
        plot(xx,yy,'-');
        hold on;
end
xlabel('x');
ylabel('y');

%axis('square',[0,s+1,0,s+1])
axis('square',[0,s,0,s])