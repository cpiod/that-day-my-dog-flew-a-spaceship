pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- submission to gmtk 2020
-- by a cheap plastic imitation of a game dev (cpiod)
t={1,1,2,2} --const
tmp={{1,1,0,1},{0,0,0,0}}
mem={tmp,tmp,tmp}

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

screen=0
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
  update_expl()
  if(btnp(🅾️)) screen=10
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
  if(t[i]==1) o[i]=1+flr(rnd(2))
  if(t[i]==2) o[i]=flr(rnd(30)+5)
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
  circfill(dx+x+5,dy+y+16,rad,c)
 end
end
-->8
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
-->8
-- draw

function _draw()
 pal()
 palt(14,true)
 palt(0,false)
 
 if screen==0 then
  cls(0)
  -- title screen
  draw_mstars()
--  pal(0,5)
  local x,y=50+10*cos(time()/5),50+20*sin(time()/3)
  spr(64,x,y,4,4)
  draw_expl(x,y)
  prt("tHE DAY MY DOG GOT IN CHARGE",nil,20,9,4)
  prt("OF OUR SPACESHIP FULL OF SOCKS",nil,30,9,4)
  if(time()%1<.8) prt("press x to lose control!",nil,100,7,1)
  local s="bY A cHEAP pLASTIC iMITATION"
  ?s,64-2*#s,114,1
  local s="oF A GAME dEV (cpiod)"
  ?s,64-2*#s,120,1
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
	 ?tostr(o[1]).." "..tostr(o[2]).." "..tostr(o[3]),20,20,6
	 fillp()
	 
  draw_block(100,105,26,20)
	 if f[1] then
	  if(time()%1<.8) spr(2,105,107,2,2,o[1]==1)
 	end

  draw_block(2,105,28,20) 	
 	if f[2] then
 	 spr(16,5,111)
 	 ?"room",14,110,6
 	 o[2]="a"-- todo!!
 	 if(2*time()%1<0.8) prt(o[2],20,117,8,6)
  end
  
  draw_block(2,2,28,20)
	 if f[3] then
 	 spr(1,5,8)
 	 ?"bomb",14,7,6
 	 if(2*time()%1<0.8) prt(o[3],16,14,8,6)
  end
  
  draw_block(100,2,28,20)
	 if f[4] then
 	 spr(17,102,8)
 	 ?"freq",112,7,6
 	 if(2*time()%1<0.8) prt(o[4],115,14,8,6)
  end
  
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
eeee0ddddddddddd5ccc5ddd5c5555ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0ddddddddddd5ccc5ddd5cc5cc5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee0dddddddddddd555dddd5cc5ccc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee0ddddddddddddddddddddd5cc5cc5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e000ddddddddddddddddddddd5ccc5c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddd0ddddddddddddddddddddd5ccc55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddddddddd1111111111111dd5cc5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddd0dddddd00000000000000000555e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0dd001ddddd10d10eeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e00e01dddddd10d10eeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee01dddddd10d10eeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee01ddddddd10d10eeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeee001ddddddd100000000000eeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeee01dddddddddddddd0cc0eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeee011ddddddddddd0cc0eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeee0011111111110cc0eeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeee0000000000000eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
