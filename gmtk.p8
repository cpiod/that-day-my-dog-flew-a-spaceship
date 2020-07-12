pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- that day my dog flew a spaceship
-- by cpiod
-- submission to gmtk 2020

-- const
t={1,1,2,2}
card={2,3}
flist={{1,0,0,0},{1,0,0,0},{1,1,0,0},{1,1,0,0},{1,1,0,1},{1,1,0,1},{1,1,1,1}}
--flist={{1,1,0,1},{1,1,1,1},{1,1,0,0},{1,1,0,1},{1,1,0,1},{1,1,1,1}}

function new_level()
	lvl+=1
	socks={}
	f={}
	for i=1,4 do
	 f[i]=flist[min(lvl,#flist)][i]
	end
	for i=1,4 do
	 f[i]=f[i]==1
	end
	if(rnd()<.3) f[3]=false
	if(lvl>3 and rnd()<.3) f[1]=false
	n=6
	if(f[2]) n+=2
	if(f[3]) n+=4
	if(f[4]) n+=4
	o=gen_obj()
	set,socks=gen_set(n)
	assert(#set==n)
	enable={}
	for i=1,n do
	 enable[i]=true
	end
	assert(#enable==n)
	sel={}
	lsel=0
	y_camera=0
	curs=0
	bool2=false -- sfx damage
end

function _init()
 mem={{},{},nil,nil} -- the models
	hp=60
	win=0
	cinem=0
	bool=false -- cinem
	stars={}
	mstars={}
	ast={}
	shocks={}
	shocksd={}
	pirate_seen=false
	radio_seen=false
	fire_seen=false
	for i=1,4 do
	 add_shock()
	end
	for i=1,4 do
	 add_shock_dog()
	end
	expl={}
	lvl=0
	init_stars()
	init_mstars()
	init_expl()
	init_ast()
	music(53,120)
	n=8
	new_level()
	screen=0 -- todo 0 dans version finale
	t0=time()
--	t3=time()
--	music(0)
end

function _update60()
 if screen==0 then
 -- title screen
  update_mstars()
  if(btnp(🅾️)) then
   screen=1
   t1=time()
  end
 end
 
 if screen==1 then
  -- animation title screen
  update_mstars()
  update_expl()
  if(time()-t1>2) screen=10 cinem=1
 end
	
	if screen>=10 and screen<=12 and cinem!=0 and cinem!=4 then
	 	if(btnp(🅾️)) cinem+=1
	 	if(cinem==3) screen=11
--	 	if(cinem==6) screen=10
 	 if(cinem==7) cinem=0
 	 if(cinem==21) cinem=0
 	 if(cinem==31) cinem=0
 	 if(cinem==41) cinem=0

	elseif screen==11 then
	-- selection screen
	 -- movement
  if btnp(⬅️) then
   sfx(12)
   if curs==0 then
    curs=n-1
   elseif curs==1 then
    curs=n-2
   else
    curs-=2
   end
  elseif btnp(➡️) then
   sfx(12)
   if curs==n-2 then
    curs=1
   elseif curs==n-1 then
    curs=0
   else
    curs+=2
   end
  elseif btnp(⬆️) then
   sfx(12)
   if(curs%2==1) curs-=1 else screen=10
  elseif btnp(⬇️) then
   sfx(12)
   if curs%2==0 then
    if(curs==n-1) curs-=1 else curs+=1
   else
    screen=12
   end
  end
--  if(cinem==4) screen=11 -- don't change screen
  assert(curs>=0 and curs<n)
  
  -- selection
  if btnp(🅾️) then
   if enable[curs+1] and lsel<4 then
    sfx(11)
    enable[curs+1]=false
    lsel+=1
    for i=1,4 do
     if(sel[i]==nil) sel[i]=curs+1 break
    end
   elseif not enable[curs+1] then
    for i=1,4 do
     if(sel[i]==curs+1) sel[i]=nil
    end
    sfx(13)
    enable[curs+1]=true
    lsel-=1
   end    
  end
  
  -- confirm the selection
  if btnp(❎) then
   if lsel==4 then
	   if(cinem==4) cinem=5
	   screen=20
	   for i=1,4 do
	    sel[i]={sel[i],rnd(8)-4,rnd(16)-8,rnd()<.5,rnd()<.5}
	   end
	   sfx(11)
	   confirm_sel()
   else
    t4=time()
   end
  end
	
	elseif screen==10 then
	 -- objective screen
	 if(btnp(⬇️)) sfx(12) screen=11
	
	elseif screen==12 then
	 -- dog screen
	 if(btnp(⬆️)) sfx(12) screen=11
	end
	
	if screen==30 or screen==31 then
	 update_expl()
	 update_mstars()
	 -- game over / victory screen
	 if(time()-t3>3 and (btnp(❎) or btnp(🅾️))) sfx(11) _init()
	end
	
	-- animation update
	if screen>=10 and screen<=12 then
  update_stars()
	end
	
	if screen==20 then
	 update_mstars()
	 update_stars()
	 if time()-t2>1.5 then
	  screen+=1
	  while screen<=24 and not f[screen-20] do
    screen+=1
   end
  end
	end
	
	if screen>=21 and screen<=29 then
  -- interpretation screen
  update_stars()
  if btnp(🅾️) then
   sfx(12)
   screen+=1
   while screen<=24 and not f[screen-20] do
    screen+=1
   end
   -- after screen 25
   if screen==26 then
    hp-=damage
    for i=1,flr(damage/4) do
     add_shock()
     add_shock_dog()
    end
    win+=win_pts 
    if hp<=0 then
     screen=30 -- game over..
     t3=time()
     music(27)
    elseif win>=60 then
     screen=31 -- win
     t3=time()
     music(0)
    else
     new_level()
     screen=12
     y_camera=128
     if f[3] and not pirate_seen then
      pirate_seen=true
      cinem=30
      screen=10
     end
     if f[4] and not radio_seen then
      radio_seen=true
      cinem=20
      screen=10
     end
     if f[2] and not fire_seen then
      fire_seen=true
      cinem=40
      screen=10
     end
    end
   end
  end
	end
end

-->8
-- hamming learning

-- get the closest guess
-- random if too far
function get_best(mem,tuple,card)
 local e1,e2,e3,e4=unpack(tuple)
 -- lowest dist
 local ld=5
 local out=nil
 local unknown={}
 for i=1,card do
  if mem[i]!=nil then
   local k1,k2,k3,k4=unpack(mem[i])
   local d=0
   if(k1!=e1) d+=1
   if(k2!=e2) d+=1
   if(k3!=e3) d+=1
   if(k4!=e4) d+=1
   if(d<ld) out={k1,k2,k3,k4,i,d} ld=d
  else
   add(unknown,i)
  end
 end
 if (#unknown>0 and ld>=3) then
  return {nil,nil,nil,nil,rnd(unknown)}
 else
  assert(out!=nil)
  return out
 end
end

function mem_update(mem,e,c,index)
 -- remove duplicates
 for i=1,card[index] do
  local same=true
  if mem[i]!=nil then
   for j=1,4 do
    if mem[i][j]!=e[j] then
     same=false
     break
    end
   end
  end
  if(same) mem[i]=nil
 end
 -- new prototype for this class
 mem[c]=e
end
-->8
-- regression learning

all_ex={nil,nil,{},{}}
nb={nil,nil,1,1}
max_nb=3

function get_equation(m,e)
 local s=""
 for i=1,4 do
  if m[i]==1 then
   if(s!="") s=s.."+"
   s=s..e[i]
  elseif m[i]>1 then
   if(s!="") s=s.."+"
   s=s..m[i].."*"..e[i]
  elseif m[i]==-1 then
   s=s.."-"..e[i]
  elseif m[i]<-1 then
   s=s..m[i].."*"..e[i]
  end
 end
 return s
end

function display_equ(m)
 return get_equation(m,{"(sock 1)","(sock 2)","(sock 3)","(sock 4)"})
end

function get_best_reg(mem,e)
 if mem==nil then
  local mean=0
  for i=1,4 do
   mean+=e[i]
  end
  return {nil,flr(mean/4+.5)}
 else
	 local out=0
	 for i=1,4 do
	  out+=mem[i]*e[i]
	 end
	 s=get_equation(mem,e)
	 assert(s!="")
	 return {s,out}
 end
end

function mem_update_reg(e,c,index)
 local e1,e2,e3,e4=unpack(e)
 local i=index
 ex=all_ex[i]
 ex[nb[i]]={e1,e2,e3,e4,c}
 nb[i]+=1
 if(nb[i]>max_nb) nb[i]=1
-- for i=1,5 do
--  printh(ex[1][i])
-- end
 local m={}
 local ld=1000
 
 -- some inertia for the current model
 if mem[index]!=nil then
  -- set ld
  a,b,c,d=unpack(mem[index])  
  ld=-5 -- bonus
  for k in all(ex) do
   ld+=abs(k[5]-a*k[1]-b*k[2]-c*k[3]-d*k[4])
  end
  m=mem[index]
 end
 
 -- a
 for i=1,4 do
  local d=0 -- no malus
  for k in all(ex) do
   d+=abs(k[5]-k[i])
  end
  if d<ld then
   ld=d
   m={0,0,0,0}
   m[i]=1
  end
 end
 
 -- only freq has complex computations
 if index==4 then
	 -- 2*a
	 for i=1,4 do
	  local d=3 -- slight malus
	  for k in all(ex) do
	   d+=abs(k[5]-2*k[i])
	  end
	  if d<ld then
	   ld=d
	   m={0,0,0,0}
	   m[i]=2
	  end
	 end
	 
	 -- a+b
	 couple={{1,1,0,0},{0,1,1,0},{0,0,1,1},{1,0,1,0},{0,1,0,1},{1,0,0,1}}
	 for l in all(couple) do
	  a,b,c,d=unpack(l)  
	  local d=5 -- malus
	  for k in all(ex) do
	   d+=abs(k[5]-a*k[1]-b*k[2]-c*k[3]-d*k[4])
	  end
	  if d<ld then
	   ld=d
	   m=l
	  end
	 end
 end
 
 mem[index]=m
end
-->8
-- generation

function gen_obj()
 local o={}
  o[1]=1+flr(rnd(card[1]))
  o[2]=1+flr(rnd(card[2]))
  o[3]=13+flr(rnd(17))
  o[4]=25+flr(rnd(25))
 return o
end

col_sock={{3,11,8},{2,8,12},{1,12,11}}

function gen_set(n)
 local set={}
 local socks={}
 for i=1,n do
  local l={}
		l[1]=1+flr(rnd(2)) -- two sizes
		l[2]=1+flr(rnd(3)) -- three colors
		l[3]=10+flr(rnd(20)) -- dots
  c1,c2,c3=unpack(col_sock[l[2]])
--  if(not f[2]) c3=c2
  -- sprite, c1, c2, c3, flip_x
  l2={4+2*flr(rnd(2)),c1,c2,c3,rnd()<.5,rnd()<.5,l[1]==1}
  add(set,l)
  add(socks,l2)
 end
 assert(#set==#socks)
 return set,socks
end
-->8
-- particles

function add_shock()
 local a=rnd()
 local d=rnd(40)
 add(shocks,{72+flr(rnd(4)),60+d*cos(a),60+d*sin(a),rnd()<.5,rnd()<.5})
end

function draw_shocks()
	for sh in all(shocks) do
	 local nspr,x,y,fx,fy=unpack(sh)
	 spr(nspr,x,y,1,1,fx,fy)
 end
end

function add_shock_dog()
 add(shocksd,{72+flr(rnd(4)),30+rnd(68),11+rnd(50),rnd()<.5,rnd()<.5})
end

function draw_shocks_dog()
	for sh in all(shocksd) do
	 local nspr,x,y,fx,fy=unpack(sh)
	 spr(nspr,x,y,1,1,fx,fy)
 end
end

function init_stars()
 for i=1,20 do
  add(stars,new_star())
 end
end

function new_star()
 -- angle, dist, speed, thr color
 return {rnd(),rnd(50),rnd(1)+1,rnd(5)+10}
end

function update_stars()
 for i=1,#stars do
  local s=stars[i]
  s[2]+=s[3]
  if s[2]>50 then
   stars[i]=new_star()
  end
 end
end

function draw_stars(y)
 for i in all(stars) do
  local a,d,_,t=unpack(i)
  local col=nil
  if(d>t)col=5
  if(d>2*t)col=6
  if(d>3*t)col=7
  if(col!=nil) pset(64+d*cos(a),y+d*sin(a),col)
 end
end

function init_ast()
 for i=1,7 do
 -- spr x y size flipx flipy deltat
  a={0+flr(rnd(3))*2,rnd(20)-10,rnd(30)-15,.8+rnd(.4),rnd()<.5,rnd()<.5,rnd()}
  add(ast,a)
 end
end

function draw_ast(dx)
 for a in all(ast) do
  local nspr,x,y,size,fx,fy,dt=unpack(a)
		sspr(nspr*8,16,16,16,64-8+x+dx+5*cos(time()/10+dt),64+y+5*sin(time()/10+dt)-8,flr(size*16),flr(size*16),fx,fy)
 end
end

function init_mstars()
 for i=1,20 do
  add(mstars,new_mstar(rnd(128)))
 end
end

function new_mstar(init_x)
 -- x, y, speed, thr color
 local speed=rnd(2)+2
 local c=speed>3 and 6 or 5
 return {init_x,rnd(128),speed,c}
end

function update_mstars()
 for i=1,#mstars do
  local s=mstars[i]
  s[1]-=s[3]
  if s[1]<0 then
   mstars[i]=new_mstar(128)
  end
 end
end

function draw_mstars()
 for i in all(mstars) do
  local x,y,_,c=unpack(i)
  pset(x,y,c)
 end
end

function init_expl()
 for i=1,20 do
  add(expl,new_expl(rnd(30)))
 end
end

function new_expl(init_rad)
-- x, y, rad
 return {rnd(6)-3,rnd(6)-3,init_rad}
end

function update_expl()
 for i=1,#expl do
  local s=expl[i]
  s[3]+=.2
  s[1]-=.7
  if s[3]>10 then
   expl[i]=new_expl(1)
  end
 end
end

function draw_expl(dx,dy)
 for i in all(expl) do
  local x,y,rad=unpack(i)
  if(rad<10) c=8
  if(rad<9) c=9
  if(rad<4) c=10
  circfill(dx+x+12,dy+y+12,rad,c)
 end
end

-->8
-- confirm selection

function confirm_sel()
 inter={}
 for i=1,4 do
  -- only check enabled features
  if f[i] then
   local e={}
   -- extract the example from the selection
   for index in all(sel) do
    -- objective 4 uses feature 3
    add(e,set[index[1]][min(3,i)])
   end
   if t[i]==1 then
	   -- get the best guess
	   inter[i]={e,get_best(mem[i],e,card[i])} -- todo cardinal
	   -- memorize the solution
	   mem_update(mem[i],e,o[i],i)
	  else
	   assert(t[i]==2)
    inter[i]={e,get_best_reg(mem[i],e)}
		  mem_update_reg(e,o[i],i)
	  end
  end
 end
 t2=time()
end
-->8
-- draw

function _draw()
 pal()
 palt(14,true)
 palt(0,false)
 
 if screen==0 or screen==1 or screen==30 or screen==31 or (screen==20 and time()-t2<1) then
  camera(0,0)
  cls(0)
  -- title screen
  draw_mstars()
  local x,y=50+10*cos(time()/5),50+10*sin(time()/3)
  local dx=min(0,time()-t0-2)
  x+=50*dx
  if screen==30 then -- derive
   y-=10*(time()-t3)
   x+=10*(time()-t3)
  end
  if screen==20 then
   for i=1,4 do
    local dx=8*cos(time()-t2+i/10+.3)
    local dy=-7*sin(time()-t2+i/10+.3)
    local col=f[2] and socks[sel[5-i][1]][3] or 11
    pset(x+dx+20,y+dy+20,col)
   end
  end
  if((screen==1 and bool) or screen==20) color(9) else color(8)
  if screen!=30 then
   circfill(x-2,y+20,2+6*time()%2)
   line(x+2,y+20,-1,y+20)
  end
  spr(64,x,y,4,4)
  if screen==1 then
   -- asteroid collision
   local x2=128-120*(time()-t1)
   sspr(0,16,16,16,x2,50+x2/40,32,32)
   if x2<x+20 then
    if(not bool) sfx(10,3) bool=true music(43,120)
    draw_expl(x,y)
   end
  elseif screen==0 then
   local dx=5*sin(time()/2)
   prt("that day my dog",nil,20,9,1)
   prt("flew a spaceship",nil,28,9,1)
   if(time()%1<.8) prt("press z to lose control!",nil,100,7,1)
   local s="bY A cHEAP pLASTIC iMITATION"
   ?s,64-2*#s,110,1
   local s="oF A GAME dEV (cpiod)"
   ?s,64-2*#s,116,1
   local s="FOR gmtk gAME jAM 2020"
   ?s,64-2*#s,122,1
  elseif screen==30 then
   -- game over screen
   draw_expl(x,y)
   prt("oh no! the spaceship",nil,20,9,1)
   prt("is still out of control",nil,28,9,1)
   prt("and is getting destroyed.",nil,36,9,1)
   prt("you lose...",nil,44,9,1)
   
   if(time()-t3>2) prt("(the dog is ok)",nil,60,9,1)
   if(time()-t3>3 and time()%1<.8) prt("press x or z to restart",nil,100,7,1)
   palt(15,true)
   palt(14,false)
   
   local x=190-30*(time()-t3)
   local y=110-10*(time()-t3)
   nspr=132+4*flr(5*time()%2)
   spr(nspr,x+10,y+20,4,4)
   spr(68,x,y,4,4)
   spr(128,x,y,4,4)
   prt("tHIS IS FINE",x-50,y+20,13,1)
  elseif screen==31 then
   -- victory screen
   prt("congratulations!",nil,20,11,1)
   prt("you reached help. you are saved.",nil,28,11,1)
   prt("now to deliver the socks!",nil,36,11,1)
   if(time()-t3>3 and time()%1<.8) prt("press x or z to restart",nil,100,7,1)
   
   local x=190-30*(time()-t3)
   local y=110-10*(time()-t3)+10*sin(time()/5)
   spr(4,x,y,2,2)
   prt("i'M IN",x-15,y-13,13,1)
   prt("SPAAAACE!",x-20,y-6,13,1)
  end
 
 elseif screen>=10 and screen<=12 then
  cls(5)
  -- camera movement
	 y_goal=(screen-10)*128
	 dy=6
  if(abs(y_camera-y_goal)<=3) dy=abs(y_camera-y_goal)
	 if y_camera<y_goal then
	  y_camera += dy
	 elseif y_camera>y_goal then
	  y_camera -= dy
	 end
	 camera(0,y_camera)
  if cinem>=1 and cinem<=3 then
   camera(flr(cos(2*time())+.5),y_camera+flr(sin(2.5*time())+.5))
  end
	 
	 -- background
	 fillp(░)
	 rectfill(-10,-10,128+10,128*3+10,0x51)
	 fillp()
	 circfill(64,64,51,0)
  draw_stars(64)
	 
	 -- asteroids
	 if f[1] then
	  if(o[1]==1) draw_ast(20) else draw_ast(-20)
	 end
	 
	 -- pirates
	 if f[3] then
		 spr(10+2*flr(3*time()%3),45,58+3*(cos(.2+time()/3)),2,2)
		 spr(10+2*flr((1.7+3*time())%3),63,59+3*(cos(.3+time()/3)),2,2)
	  spr(10+2*flr((2.4+3*time())%3),56,64+3*(cos(time()/3)),2,2)
	 end
	 
	 -- glass
	 circ(64,64,44,13)
	 for i=1,8 do
	  local a=i/8
	  line(64+45*cos(a),64+45*sin(a),
	  64+50*cos(a),64+50*sin(a),13)
	 end
	 circ(64,64,51,13)
	 clip(30,80,40,20)
	 circ(64,64,40,7)
	 clip(40,90,30,10)
	 circ(64,64,38,7)
	 clip(85,40,40,15)
	 circ(64,64,38,7)
	 
	 clip()
	 draw_shocks()
	 
  draw_block(98,105,28,20)
	 if f[1] then
	  if(2*time()%1<.8) spr(2,105,107,2,2,o[1]==1)
 	end

  draw_block(1,105,28,20) 	
 	if f[2] then
 	 if(2*time()%1<0.8) spr(16,4,111)
 	 ?"room",13,111,6
 	 prt(chr(96+o[2]),18,118,8,0)
  end
  
  draw_block(1,2,28,20)
	 if f[3] then
 	 if(2*time()%1<0.8) spr(1,3,8)
 	 ?"bomb",13,8,6
 	 prt(o[3],16,15,8,0)
  end
  
  draw_block(98,2,28,20)
	 if f[4] then
 	 if(2*time()%1<0.8) spr(17,100,8)
 	 ?"freq",110,8,6
 	 prt(o[4],113,15,8,0)
  end
  
  ?"hULL",2,32,6
  rectfill(4,40,7,100,5)
  rectfill(4,40+(60-hp),7,100,2)
  rect(4,40,7,100,0)

  ?"rADIO",108,32,6
  rectfill(121,40,124,100,5)
 	rectfill(121,40+(60-win),124,100,3)
 	rect(121,40,124,100,0)
  
  if(cinem==0) prt("uSE THE ARROWS",nil,0,12,0) prt("TO MOVE",nil,7,12,0)
  prt("mAIN dECK ⬇️",nil,120,12,0)
  prt("cOCKPIT ⬆️",nil,131,12,0)
  prt("cOMM dECK ⬇️",nil,248,12,0)
  prt("mAIN dECK ⬆️",nil,259,12,0)
  if cinem==0 or cinem==4 then
   prt("press z to select",nil,206,12,0)
   prt("what i will throw (x to throw):",nil,212,12,0)
  end
  
	 -- set
  local step=100/(flr((n-1)/2))
  for c=0,n-1 do
   pal()
   palt(14,true)
   local x,y=16+step*flr(c/2),22+128+4+36*flr(c%2)
   draw_sock(x,y,socks[c+1],enable[c+1])
  end

  for c=0,n-1 do
   if enable[c+1] and (f[3] or f[4]) then
    pal()
    palt(14,true)
    local x,y=16+step*flr(c/2),22+128+4+36*flr(c%2)
    draw_nb(x,y,set[c+1])
   end
  end
  
    -- cursor
  if cinem==0 or cinem==4 then
   circ(16+step*flr(curs/2),128+24+36*flr(curs%2),12,7)
   circ(16+step*flr(curs/2),128+24+36*flr(curs%2),11,7)
  end
  
  pal()
  palt(14,true)
  -- selection
  for i=1,4 do
   if sel[i]!=nil then
    local x,y=32*(i-1)+16,232
    draw_sock(x,y,socks[sel[i]],true)
    if (f[3] or f[4]) draw_nb(x,y,set[sel[i]])
	  end
	 end
  
  if t4!=nil and time()-t4<1 then
    prt("you need to choose 4 socks!",nil,170,9,0)
  end
  
  -- dog
	 pal()
  rectfill(4,256+20,40,256+45,1)
	 palt(14,false)
	 palt(15,true)
	 palt(0,false)
  spr(68,6,256+17,4,4)
  
  rect(4,256+20,40,256+45,0)  
  rect(3,256+19,41,256+46,0)  
  rect(2,256+18,42,256+47,0)  
  line(22,256+17,12,256+12,0)
  line(22,256+18,12,256+13,0)
  line(22,256+17,32,256+12,0)
  line(22,256+18,32,256+13,0)
  
  if(lvl==1) prt("nothing... yet",nil,256+80,7,0)
  
  for k=1,2 do
   for i=1,card[k] do
    local expl=mem[k][i]
    if expl!=nil then
     local y=255+15*(2*(k-1)+i)
     local c=k==1 and 14 or 13
     prt(get_msgf(expl,k),nil,y,c,0,15)
     prt(" MEANS "..msgo[k][i],nil,y+7,c,0,15)
    end
   end  
  end
  
  if mem[3]!=nil then
   prt("bomb FORMULA:",nil,345,15,0,15)
   prt(display_equ(mem[3]),nil,352,15,0,15)
  end
  
  if mem[4]!=nil then
   prt("freq FORMULA:",nil,360,12,0,15)
   prt(display_equ(mem[4]),nil,367,12,0,15)
  end
  
  if cinem==1 then
   prt("oh no! i lost the comm with",nil,80,9,0)
   prt("the pilot and he has bad sight!",nil,88,9,0)
   prt("why is my pilot a dog??",nil,96,9,0)
   prt("press z to continue",nil,110,7,0)
  elseif cinem==2 then
   prt("asteroids ahead! we need",nil,80,9,0)
   prt("to go "..msgo[1][o[1]].." to avoid them.",nil,88,9,0)
   prt("how to tell my dog?",nil,96,9,0)
   prt("he can't even read...",nil,104,9,0)
  elseif cinem==3 then
   prt("all i have to regain control",nil,128+80,9,0)
   prt("are small and large socks...",nil,128+88,9,0)
   prt("if i throw socks at him,",nil,128+96,9,0)    
   prt("maybe i can train him?",nil,128+104,9,0)
  elseif cinem==5 then
   prt("hooray, he got it right! and",nil,256+80,9,0)
   prt("he can tell me his reasoning!",nil,256+88,9,0)
   prt("let's keep training him.",nil,256+96,9,0)
  elseif cinem==6 then
   prt("dev advice:",nil,256+80,7,0)
   prt("there are no \"good\" answers.",nil,256+88,7,0)
   prt("the dog should be clever enough",nil,256+96,7,0)
   prt("to understand you. good luck!",nil,256+104,7,0)
  elseif cinem==20 then
   prt("the radio works again!",nil,80,9,0)
   prt("it we use the right frequency,",nil,88,9,0)
   prt("help will come!",nil,96,9,0)
   prt("radio bar on the right",nil,104,7,0)
  elseif cinem==30 then
   prt("oh no, space pirates!",nil,80,9,0)
   prt("we need to activate the shield",nil,88,9,0)
   prt("at the right energy level!",nil,96,9,0)
  elseif cinem==40 then
   prt("oh no, fire in "..msgo[2][o[2]].."! my dog",nil,80,9,0)
   prt("needs to handle it. i will use",nil,88,9,0)
   prt("the socks' colour to tell him.",nil,96,9,0)
   prt("hull bar on the left",nil,104,7,0)
  end
  
 elseif screen>=20 and screen<=25 then
  -- interpretation screens
  palt()
  camera(0,0)
  cls(0)
  fillp(░)
	 rectfill(0,0,128,128,0x01)
	 fillp()
	 circfill(35,40,30,0)
	 circfill(128-35,40,30,0)
	 circ(35,40,30,13)
	 circ(128-35,40,30,13)
	 rect(35,10,128-35,70,13)
	 rectfill(35,10+1,128-35,70-1,0)
	 clip(20,10+1,128-50,58,0)
	 draw_stars(40)
  clip()
  pal()
  palt(14,true)
  if(screen<=24) then
   -- sock for dog
   for i=1,4 do
    d=max(0,min(1,1-max(0,4*(t2-time()+1)+2)+0.2*(4-i)))
    local index,x,y = unpack(sel[i])
    draw_sock(9+22*i+x,38+y,socks[index],true,d)
 	 end
	 end
	 
	 pal()
	 palt(14,true)
	 draw_shocks_dog()
	 palt(14,false)
	 palt(15,true)
	 palt(0,false)
	 if screen!=25 then
	  -- dog
	  sspr(32,32,32,32,126-(max(0,min(.67,time()-t2-1)))*135,5,64,64)
	 end
	 
	 if screen==21 or screen==22 then
	  local i=screen-20
	  local e,k=unpack(inter[i])
	  local y=72
	  if i==1 then
	   prt("avoid the asteroids",nil,y,7,0)
	  else
	   prt("fight the fire",nil,y,7,0)
   end
   y=75
   local s="the socks are"
   if(i==1) s="woof! "..s
	  prt(s,nil,y+8,9,0)
	  prt(get_msgf(e,i),nil,y+15,6,0)
	  
	  if k[1]==nil then
	   prt("i have no idea what i'm doing!",nil,y+22,9,0)
	   prt("i'll try something new: "..msgo[i][k[5]],nil,y+29,9,0)
	  elseif k[6]==0 then
	   prt("i know it!",nil,y+22,9,0)
	   prt("i choose "..msgo[i][k[5]],nil,y+29,9,0)
	  else
 	  prt("the closest i know is",nil,y+22,9,0)
	   prt(get_msgf(k,i),nil,y+29,6,0)
	   prt("and it meant "..msgo[i][k[5]],nil,y+36,9,0)
   end
   
   if(time()%1<.8 and inter[i][2][5]!=o[i]) then
	   prt("error!",nil,y+44,8,0)
	  elseif inter[i][2][5]==o[i] then
	  	prt("all right!",nil,y+44,11,0)
	  end
   
  elseif screen==23 or screen==24 then
   local i=screen-20
   local y=85
   if i==3 then
	   prt("shoot the pirates' bomb",nil,y,7,0)
	  else
	   prt("contact the emergency frequency",nil,y,7,0)
   end
	  local e,l=unpack(inter[i])
	  local s,val=unpack(l)
	  if s==nil then
	  	prt("i have no idea what i'm doing!",nil,y+8,9,0)
	   prt("let's choose the mean value:",nil,y+15,9,0)
	   prt(tostr(val),nil,y+22,9,0)
	  else
	   prt("my best guess is:",nil,y+8,9,0)
	   prt(s,nil,y+15,9,0)
	  end
	  
	  local e=abs(inter[i][2][2]-o[i])
	  if(e>10) then
	   if(time()%1<.8) prt("large error: "..e,nil,y+32,8,0)
	  elseif(e>0) then
	   prt("small error: "..e,nil,y+32,9,0)
	  else
	  	prt("no error!",nil,y+32,11,0)
	  end

	 elseif screen==25 then
	  local y=20
	  damage=0
	  win_pts=0
	  if f[1] then
	   if inter[1][2][5]!=o[1] then
	    prt("we collided with the asteroids!",nil,y,8,0)
	    prt("hull damage: 5",nil,y+8,8,0)
	    damage+=5
	   else
	    prt("we avoided the asteroids",nil,y,6,0)
	   end
	  end
	  y+=20
	  if f[2] then
	   if inter[2][2][5]!=o[2] then
	    prt("the fire spreads!",nil,y,8,0)
	    prt("hull damage: 4",nil,y+8,8,0)
	    damage+=4
	   else
	    prt("the fire is out",nil,y,6,0)
    end
	  end
	  y+=20
	  if f[3] then
	   if abs(inter[3][2][2]-o[3])<=1 then
	    prt("the bomb is neutralized",nil,y,6,0)
	   elseif abs(inter[3][2][2]-o[3])<=3 then
	    prt("the bomb exploded far away",nil,y,9,0)
	    prt("hull damage: 1",nil,y+8,9,0)
	    damage+=1
	   else
	    local d=flr(abs(inter[3][2][2]-o[3])/3)+2
	    prt("the bomb exploded near us!",nil,y,8,0)
	    prt("hull damage: "..d,nil,y+8,8,0)
	    damage+=d
	   end
	  end
	  y+=20
	  if f[4] then
	   if inter[4][2][2]==o[4] then
	    prt("we got a clear connexion!",nil,y,11,0)
	    prt("radio: +20",nil,y+8,11,0)
	    win_pts=20
	   elseif abs(inter[4][2][2]-o[4])<=3 then
	    prt("the radio crackles a bit",nil,y,11,0)
	    prt("radio: +10",nil,y+8,11,0)
	    win_pts=10
	   elseif abs(inter[4][2][2]-o[4])<=10 then
	    prt("the radio crackles a lot",nil,y,11,0)
	    prt("radio: +5",nil,y+8,11,0)
	    win_pts=5
	   else
	    prt("wrong frequency...",nil,y,6,0)
	   end
	  end
	  if not bool2 then
	   bool2=true
	   if damage>=10 then 
	    sfx(10)
	   elseif damage>0 then
	    sfx(14)
	   end
	  end
	  y+=20
	  if damage==0 then
	   prt("no hull damage",nil,y,6,0)
	  elseif damage<=8 then
	   prt("total hull damage: "..damage,nil,y,9,0)
	  else
	   prt("total hull damage: "..damage,nil,y,8,0)
   end
	 end
 else
  assert(false)
 end
end

function get_msgf(e,i)
	local s=msgf[i][e[1]]
	for j=2,4 do
	 s=s.." "..msgf[i][e[j]]
	end
	return s
end

function draw_block(x,y,w,h)
 rectfill(x,y,x+w,y+h,5)
 rect(x,y,x+w,y+h,0)
 for i=0,1 do
  for j=0,1 do
   circ(x+3+(w-6)*i,y+3+(h-6)*j,1,0)
  end
 end
end

function prt(txt,x,y,c1,c2,dx)
 dx=dx or 0
 if(x==nil) x=64-2*#txt
 x+=dx
 for i=-1,1 do
  for j=-1,1 do
   ?txt,x+i,y+j,c2
  end
 end
 ?txt,x,y,c1
end

function draw_sock(x_center,y_center,sock,enable,mul)
 mul=mul or 1 
 local nspr,c1,c2,c3,fx,fy,big=unpack(sock)
 palt()
 palt(14,true)
 palt(0,false)
 if enable and f[2] then
  pal(3,c1)
  pal(11,c2)
  if(f[3] or f[4]) pal(1,c3) else pal(1,c2)
 elseif enable and not f[2] then
  pal(3,3)
  pal(11,11)
  pal(1,11)
 else
  pal(3,6)
  pal(11,6)
  if(f[3] or f[4]) pal(1,5) else pal(1,6)
 end
 local s=big and 32 or 16
 s*=mul
 sspr(nspr*8,0,16,16,x_center-s/2,y_center-s/2,s,s,fx,fy)
 pal()
end

function draw_nb(x_center,y_center,set)
 prt(set[3],x_center-2,y_center-4,7,0)
 if(n<=12) prt("dots",x_center-6,y_center+6,7,0)
end

msgf={{"big","small"},{"green","red","blue"}}
msgo={{"left","right"},{"room a","room b","room c","room d"}}

__gfx__
00000000eeeeeeeeeeeeeeeeeee0eeeeeeeeeee000eeeeeeeeeeeeee000000ee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000e00eeeeeeeeeeeeeee0c0eeeeee0000bb30eeeeeeeeeeee0bbbbb30e0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
007007008e00006eeeeeeee0000cc0eeee0bbbbb130eeeeeeeeeeee0b1bb130e0000000000000000eeeeee222eeeeeeeeeeeee222eeeeeeeeeeeee222eeeeeee
0007700098000006eeeee00ccccccc0eeee0bb1bbb30eeeeeeeeeee0bbbbb30e0000000000000000eeeee21112eeeeeeeeeee21112eeeeeeeeeee21112eeeeee
000770008e00006eeeee0ccccccccc10eee0bbbbb130eeeeeeeeeee0b1bbb30e0000000000000000eeee2111112eeeeeeeee2111112eeeeeeeee2111112eeeee
00700700e00eeeeeeee0ccc1111cc10eeeee0bbbbb30eeeeeeeeeee0bbbb130e00000000000000001dd211111c12dd1e1dd211111c12dd1e1dd211111c12dd1e
00000000eeeeeeeeee0ccc10000c10eeeeeee0b1bbb30eeeeeeeeee0bbbbb30e0000000000000000ddd22111c122dddeddd22111c122dddeddd22111c122ddde
00000000eeeeeeeee0ccc10eee010eeeeeeeee0bbbb30eeeeeeeee0bbb1bb30e0000000000000000ddd222111222dddeddd222111222dddeddd222111222ddde
e8e8ee8eeeeeeeeee0cc10eeeee0eeeeeeeeee0bbb130eeeeeee00bb1bbb130e0000000000000000ddde2222222edddeddde2222222edddeddde2222222eddde
8ee88eee000000000cc10eeeeeeeeeeeeeeeeee0bbbb30eeee00bbbbbb1330ee00000000000000009d9eeeeeeeee9d9e9d9eeeeeeeee9d9e9d9eeeeeeeee9d9e
ee888ee801c111100cc10eeeeeeeeeeeeeee00000bbb30eee0bb0bb1b3300eee0000000000000000898eeeeeeeee898e898eeeeeeeee898e898eeeeeeeee898e
e88988ee0c1c11100c10eeeeeeeeeeeee000bb1bbb1b30eee0b1b0bb300eeeee0000000000000000e8eeeeeeeeeee8eee8eeeeeeeeee888e888eeeeeeeeee8ee
889988ee0111c1c00c10eeeeeeeeeeee0b1b0bbbbbbb130ee0bbbb030eeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeee8eee8eeeeeeeeeeeeee
899988ee01111c100c10eeeeeeeeeeee033bb0b1b333330eee033330eeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
89a98eee00000000010eeeeeeeeeeeeee0033303300000eeeee0000eeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e8a8eeeeeeeeeeeee0eeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeee0000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee55eeeeeeeeeeeeee55eeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee56655eeeeeeeeee55665eeeeeeeeeeee5555eeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee5666665eeeeeeee5666665eeeeeeeeee566665eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee56600565eeeeee56666665eeeeeeeee56666665eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee5566600565eeeeee5666666655eeeeeee560556665eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee566666055665eeee566056666665eeeee56600056665ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e56600565566605ee56665566056665eee566666056665ee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e56005566666055ee56666660056665eee56605665665eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
e56555660566565eee566666655665eeeee5666666665eee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee566666656665eeeee55666666665eeeeee55566555eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
ee56666666655eeeeeeee55666555eeeeeeeeee55eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eee55566655eeeeeeeeeeee555eeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee555eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffeeeeeeeeeeeeeeeeeeeeeeeeeee7eeee00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffff0fffffffffffffffffffffffffeee7eeeeee7eeeeeeee77eeeeee7ee7e00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefffff060ffffffffffffffffffffffffeee7eee7e77eeeeeeeeee7eeeeee7e7e00000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefffff060ffffffffffffffffffffffffeee7ee7eeee7eeeeeeeeee7eeeeee7ee00000000000000000000000000000000
000000000eeeeeeeeeeeeeeeeeeeeeeeffff06660fffffffffffffffffffffffeeee77eeeeee7eeeeeeeeeeeeeeee7ee00000000000000000000000000000000
e0dd10d10eeeeeeeeeeeeeeeeeeeeeeeffff06760fffffffffffffffffffffffeee77eeeeeeee7eeeeeeeeeeeeee7eee00000000000000000000000000000000
ee0dd10d10eeeeeeeeeeeeeeeeeeeeeeffff067660fffffffffffff000ffffffe77ee7eeeeeeee77eeeeeeeeeee7eeee00000000000000000000000000000000
ee0dd10d10eeeeeeeeeeeeeeeeeeeeeeffff067760ffffffffffff060600ffffeeeee7eeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000
eee0dd10d10eeeeeeeeeeeeeeeeeeeeeffff0677660f00000000f06606660fff0000000000000000000000000000000000000000000000000000000000000000
eeee0ddd0000000000000000eeeeeeeeffff0677766066666666066670660fff0000000000000000000000000000000000000000000000000000000000000000
eeee0dddd1111111111110d10eeeeeeeffff06777666666666666667770660ff0000000000000000000000000000000000000000000000000000000000000000
eeee0dddddddddddddddd10d10eeeeeeffff0677776666666666666777000fff0000000000000000000000000000000000000000000000000000000000000000
eeee0dddddddddddd555dd10000eeeeeffff067776666666666666777760ffff0000000000000000000000000000000000000000000000000000000000000000
eeee00dddddddddd5ccc5ddd5c5555eeffff066666666776776666777760ffff0000000000000000000000000000000000000000000000000000000000000000
eeeee0dddddddddd5ccc5ddd5cc5cc5efff06666666777777777666777660fff0000000000000000000000000000000000000000000000000000000000000000
eeeee0ddddddddddd555dddd5cc5ccc5fff066666677777777cc776666660fff0000000000000000000000000000000000000000000000000000000000000000
eeeee0ddddddddddddddddddd5cc5cc5ff066666677cc777771c7776666660ff0000000000000000000000000000000000000000000000000000000000000000
0eeee0ddddddddddddddddddd5ccc5c5ff066666677c177777777777666660ff0000000000000000000000000000000000000000000000000000000000000000
d000eddddddddddddddddddddd5ccc55ff0666667777777777777777766660ff0000000000000000000000000000000000000000000000000000000000000000
ddd00ddddddd1111111111111dd5cc5eff0666777777777777777777777660ff0000000000000000000000000000000000000000000000000000000000000000
ddddddddddd00000000000000000555eff0667777777770000777777777770ff0000000000000000000000000000000000000000000000000000000000000000
ddd00dddddd10dd0eeeeeeeeeeeeeeeeff0777777777700000077777777770ff0000000000000000000000000000000000000000000000000000000000000000
d00ee0dddddd10dd0eeeeeeeeeeeeeeeff0777777777770000777777777770ff0000000000000000000000000000000000000000000000000000000000000000
0eeee0dddddd10dd0eeeeeeeeeeeeeeefff07777777777700777777777770fff0000000000000000000000000000000000000000000000000000000000000000
eeeee01dddddd10dd0eeeeeeeeeeeeeefff07777777777777777700777770fff0000000000000000000000000000000000000000000000000000000000000000
eeeee01ddddddd100000000000eeeeeeffff077777777777777700777770ffff0000000000000000000000000000000000000000000000000000000000000000
eeeee01dddddddddddddd0cc0eeeeeeefffff0777777000000000777770fffff0000000000000000000000000000000000000000000000000000000000000000
eeeeee011ddddddddddd0cc0eeeeeeeeffffff077777777777eee77770ffffff0000000000000000000000000000000000000000000000000000000000000000
eeeeeee0011111111110cc0eeeeeeeeefffffff007777777777ee7700fffffff0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee0000000000000eeeeeeeeeefffffffff00077777777000fffffffff0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffffffff00000000ffffffffffff0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000
fffffffffffffffffffffffffffffffffffffffff6666ffffffffffffffffffffffffffff6666fffffffffffffffffff00000000000000000000000000000000
fffffffffffffffffffffffffffffddffffffff6666666666ffffffffffffffffffffff6666666666fffffffffffffff00000000000000000000000000000000
fffffffffffffcccccccffffffffffdfffffff666666666666666fffffffffffffffff666666666666666fffffffffff00000000000000000000000000000000
ffffffffffcccccccccccccfffffffdfffffff666666666666666666ffffffffffffff666666666666666666ffffffff00000000000000000000000000000000
fffffffffccccfffffffccccffffffdffffff66666666666666666666ffffffffffff66666666666666666666fffffff00000000000000000000000000000000
fffffffcccfffffffffffffcccffffdffffff666666666666666666666fffffffffff666666666666666666666ffffff00000000000000000000000000000000
ffffffccfffffffffffffffffccfffdfffff7666666666666666666666ffffffffff7666666666666666666666ffffff00000000000000000000000000000000
fffffccfffffffffffffffffffccffdfffff76666666666666666666666fffffffff76666666666666666666666fffff00000000000000000000000000000000
fffffcffff77fffffffffffffffcffdffff777666666666666666666666ffffffff777666666666666666666666fffff00000000000000000000000000000000
ffffcffff7ffffffffffffffffffcfdffff7777666666666666666666666f666fff7777666666666666666666666ffff00000000000000000000000000000000
fffcffff7ffffffffffffffffffffcdffff777766666666666666666666666fffff777766666666666666666666666ff00000000000000000000000000000000
ffccfff7fffffffffffffffffffffccffff7777776666666666666666666fffffff7777776666666666666666666f66600000000000000000000000000000000
ffccfff7fffffffffffffffffffffccffff7777777666666666666666666fffffff7777777666666666666666666ffff00000000000000000000000000000000
ffcfffffffffffffffffffffffffffcfffff77777776666666666666666fffffffff77777776666666666666666fffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccffff77777777777666666666666fffffffff77777777777666666666666fffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccfffff777777777777777666666fffffffffff777777777777777666666ffffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccfffff777777777777777777666fffffffffff777777777777777777666ffffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccffffff7777777777777777777fffffffffff777777777777777777777fffffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccffffff77777777777777777ffffffffffff77f777777777777777777ffffffff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccffffff7ff777777777777777ffffffffff77fffff777777777777777777777ff00000000000000000000000000000000
fccfffffffffffffffffffffffffffccfffff77fff7777777777fff77ff7fffff77fffff7f7777777777ff77ffffffff00000000000000000000000000000000
ffccfffffffffffffffffffffffffccffffff77f777ffffffff77fff7777fffff77ffff77ffffffffffffff77fffffff00000000000000000000000000000000
ffccfffffffffffffffffffffffffccfffff77ff77ffffffffff77fffffffffff77ffff77fffffffffffffff7777ffff00000000000000000000000000000000
ffccfffffffffffffffffffffffffccfffff777f777ffffffffff7777fffffffff7fffff7fffffffffffffffffffffff00000000000000000000000000000000
fffccfffffffffffffffffffffffccfffffff77fff7fffffffffffffffffffffffffffff7fffffffffffffffffffffff00000000000000000000000000000000
ffffccfffffffffffffffffffffccffffffff777fffffffffffffffffffffffffffffffff7ffffffffffffffffffffff00000000000000000000000000000000
fffffcfffffffffffffffffffffcffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
fffffccfffffffffffffffffffccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
fffffffccfffffffffffffffccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
ffffffffccfffffffffffffccfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
ffffffffffcccfffffffcccfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
fffffffffffffcccccccffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000
00000000000000000000000000000000011111111111111111000111111111111100011111111100011110111111110000000000000000000000000000000000
00000000000000000000000000000000019991919199919991000199119991919100019991919100019911199119910000000000000000000000000000000000
00000000000060000000000000000000011911919191911911000191919191919100019991919100019191919191110000000000000000000000000000000000
00000000000000000000000000000000001911999199911910000191919991999100019191999100019191919191110000000000000000000000000000000000
00000000000000000000000000000000001911919191911910000191919191119100019191119100019191919191910000000000000000000000000000000000
00000000000000000000000000000000001911919191911910000199919191999100019191999100019991991199910000000000000000000000000000000000
00000000000000000000000000000000001111111111111110000111111111111100011111111100011111111111110000000000000000000000000000000000
00000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000001111111011111111100011111000011111111111111111111111111111111111100000000000000000000000000000000
00000000000000000000000000000001999191019991919100019991000119919991999119919991199191919991999100000000000000000000000000000000
00000000000000000000000000000001911191019111919100019191000191119191919191119111911191911911919100000000000000000000000000000000
00000000000005000000000000000001991191019911919100019991000199919991999191019911999199911911999100000000000000000000000000000000
00000000000000000000000000000001911191119111999100019191000111919111919191119111119191911911911100000000000000000000000000000000
00000000000000000000000000000001910199919991999100019191000199119101919119919991991191919991910000000000000000000000000000000000
00000000000000000000000000000001110111111111111100011111000111111101111111111111111111111111110000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000dd10d10000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000dd10d1000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000dd10d1000000000000000000000000000000000000000000000000000000000000000006000
000000000000000000000000000000000000000000000000000000dd10d100000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000ddd0000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000dddd1111111111110d1000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000dddddddddddddddd10d100000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000dddddddddddd555dd10000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddd5ccc5ddd5c5555000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000dddddddddd5ccc5ddd5cc5cc500000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000ddddddddddd555dddd5cc5ccc50000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000ddddddddddddddddddd5cc5cc50000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000ddddddddddddddddddd5ccc5c50000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888d0000ddddddddddddddddddddd5ccc550000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000088888ddd00ddddddd1111111111111dd5cc500000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888ddddddddddd0000000000000000055500000000000000000000000000000000000000000000000
00000000000000000000000000000000000005000000088888ddd00dddddd10dd000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008888d00000dddddd10dd00000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000888000000dddddd10dd00000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001dddddd10dd0000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001ddddddd1000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001dddddddddddddd0cc000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000011ddddddddddd0cc0000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000011111111110cc00000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000
00000000000000000000000000000000000000000000500000000000000000000000000000000000000000000006000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000011111111111111111111100011111000111111111000111001111111111110000111111111111111111111111110011100000000000000000
00000000000000017771777177711771177100017771000177711771000171011771177177710001177117717711777177711771710017100000000000000000
00000000000000017171717171117111711100011171000117117171000171017171711171110001711171717171171171717171710017100000050000000000
00000000000000017771771177117771777100011711000017117171000171017171777177100001710171717171171177117171710017100000000000000000
00000000000000017111717171111171117100017111000017117171000171117171117171110001711171717171171171717171711111100000000000000000
00000000000000017101717177717711771100017771000017117711000177717711771177710001177177117171171171717711777117100000000000000000
00000000000000011101111111111111111000011111000011111110000111111111111111110000111111111111111111111111111111100000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111000000000000000000110000000000000000000001110000000000000000000000000000011100000000000000000000000000000000000000000
00000000101010100000011000001000101011100110011000001010100001100110111011100110000001001110111011100110111011100110110000000000
00000000110011100000101000001000101011001010101000001110100010101000010001001000000001001110010001001010010001001010101000000000
00000000101000100000111000001000111010001110111000001000100011100010010001001000000001001010010001001110010001001010101000000000
00000000111011000000101000000110101001101010100000001000011010101100010011100110000011101010111001001010010011101100101000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000110000000000000000000000000000000000000110000000000000001000110111011100110110001000000000000000000000000
00000000000000000000001010111000000110000001100110111011100000101011101010000010001000101001001010101000100000000000000000000000
00000000000000000000001010110000001010000010001010111011000000101011001010000010001000111001001010101000100000000000000000000000
00000000000000000000001010100000001110000010101110101010000000101010001110000010001000100001001010101000100000000000000000000000
00000000000000000000001100100000001010000011101010101001100000111001100100000001000110100011101100111001000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000001101110111010100000011000000000000000001110000000000000111011101110111000000000000000000000
00000000000000000000111001101100000010001110010010100000100001101110111000000100011011100000001010100010101000000000000000000000
00000000000000000000110010101010000010001010010011000000100010101110110000000100101011100000111010101110101000000000000000000000
00000000000000000000100010101100000010101010010010100000101011101010100000000100111010100000100010101000101000000000000000000000
00000000000000000000100011001610000011101010010010100000111010101010011000001100101010100000111011101110111000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
001800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
010c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
001800200e0351003511035150350e0351003511035150350e0351003511035150350e0351003511035150350c0350e03510035130350c0350e03510035130350c0350e03510035130350c0350e0351003513035
011800101154300000000001054300000000000e55300000000000c553000000b5630956300003075730c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020051450c145051450c145051450c145051450c145071450e145071450e145071450e145071450e1450d145141450d145141450d145141450d145141450c145071450c145071450c145071450c14507145
00060000316722f6722b6622b65229642246321c6321a632166220c612066121f6021d6021f6021c6021c6022160221602216022260224602246021c6021c6021d6021f602206022260224602246022460224602
00080000120551f0550e005150050e005150050e005150050c005130050c005130050c005130050c005130050f005160050f005160050f005160050f005160050e005150050e005150050c005130050c00513005
00080000110430960509603096031f6030960509605096050c1030960509603096030060309605096050e7030c1030960509603096031f6030960509605096050c1030960509603096030060309605096050e703
0006000018054110500c5000c50510504105001050010505115041150011500115051350413500135001350511504115001150011505135041350013500135051450414500145001450013500135001350013505
00060000286541f6401a6201162507604076000760007605086040860008600086050c6040c6000c6000c60505604056000560005605076040760007600076050d6040d6000d6000d6050c6040c6000c6000c605
014800200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013200202005420050200502005520054200502005020055200542005020050200551e0541e0501c0541c05023054230502305023055210542105020054200501c0541c0501c0501c0501c0501c0501c0501c055
0132002025054250502505025055230542305021054210502805428050280502805527054270502305423050250542505025050250551e0541e0501e0501e0552305423050230502305023050230502305023055
0132002010140171401914014140101401714019140141400f14014140171401b1400f14014140171401b1400d1401014015140141400d1401014017140191400d1401014015140141400d140101401714019140
0132002015140191401c1401914015140191401c1401914014140191401b14017140121401414015140191401e1401914015140191401214014140151401914017140141401014012140171401e1401b14017140
013200202372423720237202372523724237202372023725237242372023720237252172421720207242072028724287202872028725257242572023724237202072420720207202072020720207202072020725
0132002028724287202872028725287242872028720287252c7242c7202c7202c7252a7242a72028724287202a7242a7202a7202a725257242572025720257252872428720287202872527724277202772027725
0019002001610016110161101611016110161104611076110b61112611166111b6112061128611306113561138611336112d6112961125611206111c6111861112611106110c6110861104611026110261101611
011e00200c505155351853517535135051553518535175350050015535185351a5350050515535185351a53500505155351c5351a53500505155351c5351a53500505155351a5351853500505155351a53518535
010f0020001630020000143002000f655002000020000163001630010000163002000f655001000010000163001630010000163002000f655002000010000163001630f65500163002000f655002000f60300163
013c002000000090750b0750c075090750c0750b0750b0050b0050c0750e075100750e0750c0750b0750000000000090750b0750c0750e0750c0751007510005000000e0751007511075100750c0751007510005
013c00200921409214092140921409214092140421404214022140221402214022140221402214042140421409214092140921409214092140921404214042140221402214022140221402214022140421404214
013c00200521405214052140521404214042140721407214092140921409214092140b2140b214072140721405214052140521405214042140421407214072140921409214092140921409214092140921409214
013c00202150624506285060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400181862500000000001862518625186251862500000186051862018625000001862500000000001862500000000001862518605186251862518605186250000000000000000000000000000000000000000
010f00200c0730000018605000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c0730000000000000000c073000000000000000
013c0020025500255004550055500455004550055500755005550055500755007550045500455000550005500255002550045500555004550045500555007550055500555007550095500a550095500755009550
013c00201a54526305155451a5451c545000001a5451c5451d5451c5451a545185451a5450000000000000001a5452100521545180051c5450000018545000001a545000001c545000001a545000000000000000
011e00200557005575025650000002565050050557005575025650000002565000000457004570045750000005570055750256500000025650000005570055750256500000025650000007570075700757500000
013c00200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013c00201d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f1251d1151a1151a1151d1151a1151a1151c1201c1251d1151a1151a1151d1151a1151a1151f1201f125
011e0020091351500009135000050920515000091350000009145000000920500000071400714007145000000913500000091350000009205000000913500000091450000009205000000c2000c2050020000000
015000200706007060050600506003060030600506005060030600306005060050600206002060030600306007060070600506005060030600306005060050600306003060050600506007060070600706007060
01280020131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a125151250f125161251b1251612511125181251d125181250e125151251a125151251f1251a125131250e125
01280020227302273521730227301f7301f7301f7301f7352473024735227302273521730217351d7301d7351f7301f7352173022730217302173522730247302673026730267302673500000000000000000000
012800202773027735267302473524730247302473024735267302673524730267352273022730227302273524730247352273021735217302173021730217351f7301f7301f7301f7301f7301f7301f7301f735
015000200f0600f0600e0600e060070600706005060050600c0600c060060600606007060090600a0600e0650f0600f0600e0600e060070600706005060050600c0600a060090600206007060070600706007065
012800200f125161251b125161250e125151251a12515125131251a1251f1251a12511125181251d125181250f125161251b125161250e125151251a12515125131251a1251f1251a125131251a1251f1251a125
012800201a5201a525185201a525135101351013510135151b5201b5251a5201a525185201852515520155251652016525185201a52518520185251a5201b520155201552015520155251f5001f5001f5001f505
012800201f5201f5251d5201b525155101551015510155151d5201d5251b5201d5251a5101a5101a5101a5151b5201b5251a5201a52518520185201552015525165201652016520165251a5001a5001a5001a505
013c00201003500500000001003509000000000e0300e0351003500000000001003500000000000e0000e00511035000000000011035000000000010030100351103500000000001103500000000000400004005
011e00201813518505000001713517505000001513515505000001013010130101350000000000000000000015135000000000010135000000000011500115001150011500111301113011130111350000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155081550c155051550c155081550c155051550c155081550c155051550c137081550c155
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1370c1550f155
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1370a1550e155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
010c00200c133000000061500615176550000000615006150c133000000061500615176550000000615006150c133000000061500615176550000000615006150c13300000006150061517655000000061500615
0118002002070020700207002070040700407004070040700c0700c0700c0700c0700a0700a0700a0700a0700e0700e0700e0700e0700d0700d0700d0700d070100701007010070100700e0700e0700e0700e075
011800200000015540155401554015545115401154011540115451354013540135401354510540105401054010545115401154011540115451054010540105401054513540135401354013545095400954009545
0118002009070090700907009070070700707007070070700907009070090700907002070020700207002070030700307003070030700a0700a0700a0700a0700707007070070700707007070070700707007075
01180020000001054010540105401054511540115401154011545105401054010540105450e5400e5400e5400e545075400754007540075450e5400e5400e5400e54505540055400554005540055400554005545
__music__
01 08004243
00 08014300
00 03014300
00 02030500
00 02030500
00 03414300
00 08014500
00 03040500
00 03020500
00 03020500
02 08010706
01 0a4d0949
00 0a0d090c
00 0a4c0b4c
00 0a0d0e4e
02 0f4d0c09
01 10124316
00 11134316
00 10121416
00 11131516
00 12424316
02 13424316
01 19425b18
00 19175a18
00 19171a18
00 1b425c18
02 1a194318
01 1f1d5e60
00 1f1d5e20
00 1f1d4320
00 221d211e
00 231d211e
02 1c1d2444
01 25262744
00 292a2844
00 2526272b
02 292a282c
01 2d181e24
00 2d181e24
00 2d181e2e
00 2d181e2e
00 2d181e6e
02 2d181e6e
01 2f454305
00 30424305
00 2f324344
00 30334344
00 2f323705
00 30333805
00 31344344
00 36354344
00 31343905
02 36353a05
01 3c423b41
00 3c423b44
00 3c3d3b44
00 3c3d3b44
00 3e523b41
00 3e423b41
00 3e3f3b44
00 3e3f3b44
00 3e013b41
02 3e013b41

