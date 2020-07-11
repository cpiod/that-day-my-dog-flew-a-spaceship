pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- by a cheap plastic imitation of a game dev (cpiod)
-- submission to gmtk 2020
t={1,1,2,2} --const
mem={{},{}}

function _init()
stars={}
mstars={}
ast={}
socks={}
expl={}
lvl=0
init_stars()
init_mstars()
init_expl()
init_ast() -- todo faire regulierement
--music(53,120)
screen=10
curs=0
y_camera=0

f={true,true,true,true}
n=8
o=gen_obj()
s,socks=gen_set(n)
assert(#s==n)
enable={}
for i=1,n do
 enable[i]=true
end
assert(#enable==n)
sel={}
lsel=0
end

function _update60()
 if screen==0 then
 -- title screen
  update_mstars()
  if(btnp(🅾️)) then
   screen=1
   --music(43,120)
   t0=time()
  end
 end
 
 if screen==1 then
  update_mstars()
  update_expl()
  if(time()-t0>2) screen=10
 end

	if screen==11 then
	-- selection screen
	 -- movement
  if(btnp(⬅️)) curs=max(0,curs-2)
  if(btnp(➡️)) curs=min(n-1,curs+2)
  if btnp(⬆️) then
   if(curs%2==1) curs-=1 else screen=10
  end
  if btnp(⬇️) then
   if curs%2==0 then
    if(curs==n-1) curs-=1 else curs+=1
   else
    screen=12
   end
  end
  assert(curs>=0 and curs<n)
  
  -- selection
  if btnp(🅾️) then
   if enable[curs+1] and lsel<4 then
    enable[curs+1]=false
    lsel+=1
    for i=1,4 do
     if(sel[i]==nil) sel[i]=curs+1 break
    end
   elseif not enable[curs+1] then
    for i=1,4 do
     if(sel[i]==curs+1) sel[i]=nil
    end
    enable[curs+1]=true
    lsel-=1
   end    
  end
  
  -- confirm the selection
  if btnp(❎) and lsel==4 then
   screen=20
   confirm_sel()
  end
	end
	
	if screen==10 then
	 -- objective screen
	 if(btnp(⬇️)) screen=11
	end
	
	if screen==12 then
	 -- dog screen
	 if(btn(⬆️)) screen=11
	end
	
	-- animation update
	if screen>=10 and screen<=12 then
  update_stars()
	end
	
	if screen==20 then
	 -- interpretation screen
	 
	end
end

-->8
-- hamming learning

-- get the closest guess
-- random if no memory
function get_best(mem,tuple)
 local e1,e2,e3,e4=unpack(tuple)
 if #mem==0 then
  return rnd()<.5
 else
 -- lowest dist
  local ld=5
  for i=1,#mem do
   local k=mem[i]
   local k1,k2,k3,k4=unpack(k)
   local d=0
   if(k1!=e1) d+=1
   if(k2!=e2) d+=1
   if(k3!=e3) d+=1
   if(k4!=e4) d+=1
   if(d<ld) out={k1,k2,k3,k4,i} ld=d
  end
 end
 -- todo: dist min too low: other guess?
 assert(out!=nil)
 return out
end

function mem_update(mem,e,c)
 -- new prototype for this class
 mem[c+1]=e
end
-->8
-- regression learning

-- todo
-->8
-- generation

function gen_obj()
 local o={}
 for i=1,#t do
  if(i==1) o[i]=1+flr(rnd(2))
  if(i==2) o[i]=1+flr(rnd(4))
  if(i==3) o[i]=flr(rnd(30)+5)
  if(i==4) o[i]=flr(rnd(30)+5)
 end
 return o
end

col_sock={{3,11,8},{2,8,12},{1,12,11}}

function gen_set(n)
 local set={}
 local socks={}
 for i=1,n do
  local l={}
  for j=1,#t do
			if(t[j]==1) l[j]=flr(rnd(3))
			if(t[j]==2) l[j]=flr(rnd(10)+5)
  end
  c1,c2,c3=unpack(col_sock[l[1]+1])
  if(not f[2]) c3=c2
  -- sprite, c1, c2, c3, flip_x
  l2={4+2*flr(rnd(2)),c1,c2,c3,rnd()<.5,rnd()<.5}
  add(set,l)
  add(socks,l2)
 end
 assert(#set==#socks)
 return set,socks
end
-->8
-- particles

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

function draw_stars()
 for i in all(stars) do
  local a,d,_,t=unpack(i)
  local col=nil
  if(d>t)col=5
  if(d>2*t)col=6
  if(d>3*t)col=7
  if(col!=nil) pset(64+d*cos(a),64+d*sin(a),col)
 end
end

function init_ast()
 for i=1,7 do
 -- spr x y size flipx flipy deltat
  a={0,rnd(20)-10,rnd(30)-15,.8+rnd(.4),rnd()<.5,rnd()<.5,rnd()}
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
 for i=1,#f do
  -- only check enabled features
  if f[i] then
   e={}
   -- extract the example from the selection
   for index in all(sel) do
    add(e,s[index][i])
   end
   -- get the best guess
   inter[i]={e,get_best(mem[i],e)}
   -- memorize the solution
   mem_update(mem[i],e,o[i])
  end
 end
end
-->8
-- draw

function _draw()
 pal()
 palt(14,true)
 palt(0,false)
 
 if screen==0 or screen==1 then
  cls(0)
  -- title screen
  draw_mstars()
--  pal(0,5)
  local x,y=50+10*cos(time()/5),50+20*sin(time()/3)
  circfill()
  if(screen==1) color(9) else color(8)
--  color(rnd()<.5 and 10 or 9)
  circfill(x-2,y+20,2+6*time()%2)
  line(x+2,y+20,0,y+20)
  spr(64,x,y,4,4)
  if screen==1 then
	  draw_expl(x,y)
	 else
   prt("tHE DAY MY DOG GOT IN CHARGE",nil,20,9,4)
   prt("OF OUR SPACESHIP FULL OF SOCKS",nil,30,9,4)
   if(time()%1<.8) prt("press x to lose control!",nil,100,7,1)
   local s="bY A cHEAP pLASTIC iMITATION"
   ?s,64-2*#s,114,1
   local s="oF A GAME dEV (cpiod)"
   ?s,64-2*#s,120,1
  end
 end
 
 if screen>=10 and screen<=12 then
  cls(5)

  -- camera movement
	 y_goal=(screen-10)*128
	 -- todo: smooth camera movement
	 if y_camera<y_goal then
	  y_camera += 4
	 elseif y_camera>y_goal then
	  y_camera -= 4
	 end
	 camera(0,y_camera)
	 
	 -- background
	 fillp(░)
	 rectfill(0,0,128,128*3,0x51)
	 fillp()
	 circfill(64,64,51,0)
  draw_stars()
	 
	 -- asteroids
	 if(o[1]==1) draw_ast(20) else draw_ast(-20)
	 
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
  color(1)
	 for y=2,5 do -- placeholder
	  oval(40,10+64*y,70,40+64*y)
	 end
	 
	 -- objective
--	 fillp()
	 
  draw_block(98,105,28,20)
	 if f[1] then
	  if(time()%1<.8) spr(2,105,107,2,2,o[1]==1)
 	end

  draw_block(1,105,28,20) 	
 	if f[2] then
 	 spr(16,4,111)
 	 ?"room",13,111,6
 	 if(2*time()%1<0.8) prt(chr(96+o[2]),18,118,8,6)
  end
  
  draw_block(1,2,28,20)
	 if f[3] then
 	 spr(1,3,8)
 	 ?"bomb",13,8,6
 	 if(2*time()%1<0.8) prt(o[3],16,15,8,6)
  end
  
  draw_block(98,2,28,20)
	 if f[4] then
 	 spr(17,100,8)
 	 ?"freq",110,8,6
 	 if(2*time()%1<0.8) prt(o[4],113,15,8,6)
  end
  
  prt("uSE THE ARROWS",nil,0,12,13)
  prt("TO MOVE",nil,7,12,13)

  prt("mAIN dECK ⬇️",nil,120,12,13)
  prt("cOCKPIT ⬆️",nil,131,12,13)
  prt("dOG THOUGHTS ⬇️",nil,248,12,13)
  prt("mAIN dECK ⬆️",nil,259,12,13)

  
	 -- set
  for c=0,n-1 do
   pal()
   palt(14)
   local nspr,c1,c2,c3,fx,fy=unpack(socks[c+1])
   if enable[c+1] then
    pal(3,c1)
    pal(11,c2)
    pal(1,c3)
   else
    pal(3,6)
    pal(11,6)
    if(c1==c3) pal(1,6) else pal(1,5)
   end
		 sspr(nspr*8,0,16,16,32*flr(c/2),128+4+36*flr(c%2),32,32,fx,fy)
   e1,e2,e3,e4=unpack(s[c+1])
   color(7)
   ?tostr(e1),16+32*flr(c/2),128+5+35*flr(c%2)
   ?tostr(e2),16+32*flr(c/2),128+13+35*flr(c%2)
   ?tostr(e3),16+32*flr(c/2),128+21+35*flr(c%2)
   ?tostr(e4),16+32*flr(c/2),128+29+35*flr(c%2)
  end
  
  pal()
  palt(14)
  -- selection
  for i=1,4 do
   if sel[i]!=nil then
     local nspr,c1,c2,c3=unpack(socks[sel[i]])
     pal(3,c1)
     pal(11,c2)
     pal(1,c3)
  		 sspr(nspr*8,0,16,16,32*(i-1),224,32,32)
	  end
	 end


--  ?tostr(sel[1]).." "..tostr(sel[2]).." "..tostr(sel[3]).." "..tostr(sel[4]).." "..lsel,20,200
  -- cursor
  circ(16+32*flr(curs/2),128+20+36*flr(curs%2),17,6)
  circ(16+32*flr(curs/2),128+20+36*flr(curs%2),18,6)
--  spr(1,16+32*flr(curs/2),128+35+35*flr(curs%2))
 elseif screen==20 then
  camera(0,0)
  for i=1,#f do
   if f[i] then
    e,k=unpack(inter[i])
    ?e[1].." "..e[2].." "..e[3].." "..e[4],10,20*i+10
    ?k[1].." "..k[2].." "..k[3].." "..k[4].." "..tostr(k[4]),10,20*i
   end
  end
 end
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

--print


function prt(txt,x,y,c1,c2)
 if(x==nil) x=64-2*#txt
 for i=-1,1 do
  for j=-1,1 do
   ?txt,x+i,y+j,c2
  end
 end
 ?txt,x,y,c1
end
__gfx__
00000000eeeeeeeeeeeeeeeeeee0eeeeeeeeeee000eeeeeeeeeeeeee000000ee0000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeee0c0eeeeee0000bb30eeeeeeeeeeee0bbbbb30e0000000000000000000000000000000000000000000000000000000000000000
00700700e44eeeeeeeeeeee0000cc0eeee0bbbbb130eeeeeeeeeeee0b1bb130e0000000000000000000000000000000000000000000000000000000000000000
000770008e44446eeeeee00ccccccc0eeee0bb1bbb30eeeeeeeeeee0bbbbb30e0000000000000000000000000000000000000000000000000000000000000000
0007700098444446eeee0ccccccccc10eee0bbbbb130eeeeeeeeeee0b1bbb30e0000000000000000000000000000000000000000000000000000000000000000
007007008e44446eeee0ccc1111cc10eeeee0bbbbb30eeeeeeeeeee0bbbb130e0000000000000000000000000000000000000000000000000000000000000000
00000000e44eeeeeee0ccc10000c10eeeeeee0b1bbb30eeeeeeeeee0bbbbb30e0000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeee0ccc10eee010eeeeeeeee0bbbb30eeeeeeeee0bbb1bb30e0000000000000000000000000000000000000000000000000000000000000000
e8e8ee8eeeeeeeeee0cc10eeeee0eeeeeeeeee0bbb130eeeeeee00bb1bbb130e0000000000000000000000000000000000000000000000000000000000000000
8ee88eee000000000cc10eeeeeeeeeeeeeeeeee0bbbb30eeee00bbbbbb1330ee0000000000000000000000000000000000000000000000000000000000000000
ee888ee801c111100cc10eeeeeeeeeeeeeee00000bbb30eee0bb0bb1b3300eee0000000000000000000000000000000000000000000000000000000000000000
e88988ee0c1c11100c10eeeeeeeeeeeee000bb1bbb1b30eee0b1b0bb300eeeee0000000000000000000000000000000000000000000000000000000000000000
889988ee0111c1c00c10eeeeeeeeeeee0b1b0bbbbbbb130ee0bbbb030eeeeeee0000000000000000000000000000000000000000000000000000000000000000
899988ee01111c100c10eeeeeeeeeeee033bb0b1b333330eee033330eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
89a98eee00000000010eeeeeeeeeeeeee0033303300000eeeee0000eeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
e8a8eeeeeeeeeeeee0eeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee55eeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee56655eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee5666665eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee56600565eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee5566600565eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee566666055665ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e56600565566605e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e56005566666055e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e56555660566565e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee566666656665ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee56666666655eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee55566655eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee555eeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0dd10d10eeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0dd10d10eeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0dd10d10eeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0dd10d10eeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0ddd0000000000000000eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0dddd1111111111110d10eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0dddddddddddddddd10d10eeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0dddddddddddd555dd10000eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee00dddddddddd5ccc5ddd5c5555ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee0dddddddddd5ccc5ddd5cc5cc5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee0ddddddddddd555dddd5cc5ccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee0ddddddddddddddddddd5cc5cc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeee0ddddddddddddddddddd5ccc5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d000eddddddddddddddddddddd5ccc55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd00ddddddd1111111111111dd5cc5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddddddd00000000000000000555e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd00dddddd10dd0eeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00ee0dddddd10dd0eeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeee0dddddd10dd0eeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee01dddddd10dd0eeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee01ddddddd100000000000eeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee01dddddddddddddd0cc0eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee011ddddddddddd0cc0eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee0011111111110cc0eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee0000000000000eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011800200c0351004515055170550c0351004515055170550c0351004513055180550c0351004513055180550c0351104513055150550c0351104513055150550c0351104513055150550c035110451305515055
010c0020102451c0071c007102351c0071c007102251c007000001022510005000001021500000000001021013245000001320013235000001320013225000001320013225000001320013215000001320013215
003000202874028740287302872026740267301c7401c7301d7401d7401d7401d7401d7301d7301d7201d72023740237402373023720267402674026730267201c7401c7401c7401c7401c7301c7301c7201c720
0030002000040000400003000030020400203004040040300504005040050300503005020050200502005020070400704007030070300b0400b0400b0300b0300c0400c0400c0300c0300c0200c0200c0200c020
00180020176151761515615126150e6150c6150b6150c6151161514615126150d6150e61513615146150e615136151761517615156151461513615126150f6150e6150a615076150561504615026150161501615
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
001800200e0351003511035150350e0351003511035150350e0351003511035150350e0351003511035150350c0350e03510035130350c0350e03510035130350c0350e03510035130350c0350e0351003513035
011800101154300000000001054300000000000e55300000000000c553000000b5630956300003075730c00300000000000000000000000000000000000000000000000000000000000000000000000000000000
003000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01240020051450c145051450c145051450c145051450c145071450e145071450e145071450e145071450e1450d145141450d145141450d145141450d145141450c145071450c145071450c145071450c14507145
014800202174421740217402274024744247401f7441f7402074420740207401f7401d7401f7401c7441c7402174421740217402274024744247401c7441c7401d7441f740207402274024744247402474024745
012400200e145151450e145151450e145151450e145151450c145131450c145131450c145131450c145131450f145161450f145161450f145161450f145161450e145151450e145151450c145131450c14513145
011200200c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e7130c1330960509613096131f6330960509615096150c1330960509613096130062309605096050e713
014800200c5240c5200c5200c52510524105201052010525115241152011520115251352413520135201352511524115201152011525135241352013520135251452414520145201452013520135201352013525
014800200573405730057300573507734077300773007735087340873008730087350c7340c7300c7300c73505734057300573005735077340773007730077350d7340d7300d7300d7350c7340c7300c7300c735
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

