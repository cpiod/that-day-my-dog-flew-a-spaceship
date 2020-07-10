pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- submission to gmtk 2020
-- by a cheap plastic imitation of a game dev (cpiod)
t={1,2,1} --const
tmp={{1,1,0},{0,0,0}}
mem={tmp,tmp,tmp}

function _init()
screen=11
curs=0
y_camera=0
y_goal=128

k=get_best(mem[1],{1,1,1})
?k[1].." "..k[2].." "..k[3]
?k[4]

f={true,false,true}
n=7
o=gen_obj()
s=gen_set(n)
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
   if enable[curs+1] and lsel<3 then
    enable[curs+1]=false
    lsel+=1
    for i=1,3 do
     if(sel[i]==nil) sel[i]=curs+1 break
    end
   elseif not enable[curs+1] then
    for i=1,3 do
     if(sel[i]==curs+1) sel[i]=nil
    end
    enable[curs+1]=true
    lsel-=1
   end    
  end
  
  -- confirm the selection
  if btnp(❎) and lsel==3 then
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
	
	if screen==20 then
	 -- interpretation screen
	 
	end
end

function _draw()
 cls(1)
 color(6)
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
	 for y=0,5 do -- placeholder
	  oval(40,10+64*y,70,40+64*y)
	 end
	 
	 -- objective
	 ?tostr(o[1]).." "..tostr(o[2]).." "..tostr(o[3]),20,20
	 
	 -- set
  for c=0,n-1 do
   if(enable[c+1]) color(7) else color(5)
   e1,e2,e3=unpack(s[c+1])
   ?tostr(e1),16+32*flr(c/2),128+5+35*flr(c%2)
   ?tostr(e2),16+32*flr(c/2),128+15+35*flr(c%2)
   ?tostr(e3),16+32*flr(c/2),128+25+35*flr(c%2)
  end
  
  -- selection
  ?tostr(sel[1]).." "..tostr(sel[2]).." "..tostr(sel[3]).." "..lsel,20,200
  spr(1,16+32*flr(curs/2),128+35+35*flr(curs%2))
 elseif screen==20 then
  camera(0,0)
  for i=1,#f do
   if f[i] then
    e,k=unpack(inter[i])
    ?e[1].." "..e[2].." "..e[3],10,20*i+10
    ?k[1].." "..k[2].." "..k[3].." "..tostr(k[4]),10,20*i
   end
  end
 end
end
-->8
-- hamming learning

-- get the closest guess
-- random if no memory
function get_best(mem,tuple)
 local e1,e2,e3=unpack(tuple)
 if #mem==0 then
  return rnd()<.5
 else
 -- lowest dist
  local ld=5
  for i=1,#mem do
   local k=mem[i]
   local k1,k2,k3=unpack(k)
   local d=0
   if(k1!=e1) d+=1
   if(k2!=e2) d+=1
   if(k3!=e3) d+=1
   if(d<ld) out={k1,k2,k3,i} ld=d
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

function gen_set(n)
 s={}
 for i=1,n do
  local l={}
  for j=1,#t do
			if(t[j]==1) l[j]=flr(rnd(2))
			if(t[j]==2) l[j]=flr(rnd(10)+5)
  end
  add(s,l)
 end
 return s
end
__gfx__
00000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
