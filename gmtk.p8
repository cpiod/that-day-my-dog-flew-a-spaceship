pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- submission to gmtk 2020
-- by a cheap plastic imitation of a game dev (cpiod)
t={1,2,1, 1} --const
tmp={{1,1,0,1},{0,0,0,0}}
mem={tmp,tmp,tmp}
stars={}
socks={}

function _init()
for i=1,20 do
 add(stars,new_star())
end

screen=10
curs=0
y_camera=0
y_goal=128

k=get_best(mem[1],{1,1,1,1})
?k[1].." "..k[2].." "..k[3].." "..k[4]
?k[5]

f={true,false,true}
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
	
	if screen>=10 and screen<=12 then
	 -- animation update
	 for i=1,#stars do
	  local s=stars[i]
	  s[2]+=s[3]
	  if s[2]>50 then
	   stars[i]=new_star()
	  end
	 end
	end
	
	if screen==20 then
	 -- interpretation screen
	 
	end
end

function _draw()
 cls(1)
 color(6)
 palt(14)
 if screen>=10 and screen<=12 then
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
	 circfill(64,64,51,0)
	 for i in all(stars) do
	  --stars
	  local a,d,_,t=unpack(i)
	  local col=nil
	  if(d>t)col=5
	  if(d>2*t)col=6
	  if(d>3*t)col=7
	  if(col!=nil) pset(64+d*cos(a),64+d*sin(a),col)
	 end
	 
	 -- asteroids
	 spr(2,64+2*cos(time()/10),64+4*sin(time()/10),2,2)
	 
	 -- glass
	 circ(64,64,44,13)
	 for i=1,8 do
	  local a=i/8
	  line(64+45*cos(a),64+45*sin(a),
	  64+50*cos(a),64+50*sin(a),13)
	 end
	 circ(64,64,51,13)
--	 clip(30,80,20,20)
--	 circ(64,64,40,12)
--	 clip(40,90,15,15)
--	 circ(64,64,38,12)
	 
	 clip()
  color(1)
	 for y=2,5 do -- placeholder
	  oval(40,10+64*y,70,40+64*y)
	 end
	 
	 -- objective
	 ?tostr(o[1]).." "..tostr(o[2]).." "..tostr(o[3]),20,20
	 
	 -- set
  for c=0,n-1 do
   pal()
   palt(14)
   local nspr,c1,c2,fx=unpack(socks[c+1])
   if enable[c+1] then
    pal(3,c1)
    pal(1,c2)
   else
    pal(3,6)
    if(c1==c2) pal(1,6) else pal(1,5)
   end
		 sspr(nspr*8,0,16,16,32*flr(c/2),128+4+36*flr(c%2),32,32,fx)
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
     local nspr,c1,c2,fx=unpack(socks[sel[i]])
     pal(3,c1)
     pal(1,c2)
  		 sspr(nspr*8,0,16,16,32*(i-1),224,32,32,fx)
	  end
	 end


--  ?tostr(sel[1]).." "..tostr(sel[2]).." "..tostr(sel[3]).." "..tostr(sel[4]).." "..lsel,20,200
  -- cursor
  spr(1,16+32*flr(curs/2),128+35+35*flr(curs%2))
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

col_sock={10,11}

function gen_set(n)
 local set={}
 local socks={}
 for i=1,n do
  local l={}
  for j=1,#t do
			if(t[j]==1) l[j]=flr(rnd(2))
			if(t[j]==2) l[j]=flr(rnd(10)+5)
  end
  c=col_sock[l[1]+1]
  if(f[2]) c2=8 else c2=c
  l2={4+2*flr(rnd(2)),c,c2,rnd()<.5}
  add(set,l)
  add(socks,l2)
 end
 assert(#set==#socks)
 return set,socks
end
-->8
-- particles

function new_star()
 -- angle, dist, speed, thr color
 return {rnd(),rnd(50),rnd(1)+1,rnd(5)+10}
end
__gfx__
00000000eee7eeeeeeeeeeeeeeeeeeeeeeeeeee000eeeeeeeeeeeeee000000ee0000000000000000000000000000000000000000000000000000000000000000
00000000eee7eeeeeeeeeeeeeeeeeeeeeee00003330eeeeeeeeeeee03333330e0000000000000000000000000000000000000000000000000000000000000000
00700700ee777eeeeeeeeee55eeeeeeeee033333130eeeeeeeeeeee03133130e0000000000000000000000000000000000000000000000000000000000000000
00077000ee777eeeeeeeee56655eeeeeeee033133330eeeeeeeeeee03333330e0000000000000000000000000000000000000000000000000000000000000000
00077000e77777eeeeeee5666665eeeeeee033333130eeeeeeeeeee03133330e0000000000000000000000000000000000000000000000000000000000000000
00700700e77e77eeeeeee56600565eeeeeee03333330eeeeeeeeeee03333130e0000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeee5566600565eeeeeeee03133330eeeeeeeeee03333330e0000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeee566666055665eeeeeeee0333330eeeeeeeee033313330e0000000000000000000000000000000000000000000000000000000000000000
0000000000000000e56600565566605eeeeeee0333130eeeeeee00331333130e0000000000000000000000000000000000000000000000000000000000000000
0000000000000000e56005566666055eeeeeeee0333330eeee003333331330ee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000e56555660566565eeeee0000033330eee033033133300eee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000ee566666656665eee0003313331330eee0313033300eeeee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000ee56666666655eee031333333333130ee03333030eeeeeee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000eee55566655eeeee033333313333330eee031330eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000eeeeee555eeeeeeee0033133300000eeeee0000eeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
0000000000000000eeeeeeeeeeeeeeeeeee000000eeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
