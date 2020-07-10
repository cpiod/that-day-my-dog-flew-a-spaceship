pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- submission to gmtk 2020
-- by a cheap plastic imitation of a game dev (cpiod)

t={1,2,2,2} --const
screen=11
curs=0
y_camera=0
y_goal=128

function _init()
m={{1,1,0,true},{0,0,0,false}}
k=get_best(m,{1,1,1})
?k[1].." "..k[2].." "..k[3]
?k[4]

f={true,false}
n=5
s=generate_set(t,n)
end

function _update60()
 cls()
	if screen==11 then
	-- selection screen
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
	end
	
	if screen==10 then
	 -- objective screen
	 if(btnp(⬇️)) screen=11
	end
	
	if screen==12 then
	 -- dog screen
	 if(btn(⬆️)) screen=11
	end
end

function _draw()
 y_goal=(screen-10)*128
 -- todo: smooth camera movement
 if y_camera<y_goal then
  y_camera += 4
 elseif y_camera>y_goal then
  y_camera -= 4
 end
 camera(0,y_camera)
 for y=0,5 do
  oval(40,10+64*y,70,40+64*y)
 end
 if screen>=10 and screen<=12 then
  spr(1,20+40*flr(curs/2),190+40*flr(curs%2))
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
  for k in all(mem) do
   local k1,k2,k3,c=unpack(k)
   local d=0
   if(k1!=e1) d+=1
   if(k2!=e2) d+=1
   if(k3!=e3) d+=1
   if(d<ld) out=k ld=d
  end
 end
 return out
end
-->8
-- regression learning

-- todo
-->8
-- set generation

function generate_set(t,n)
 s={}
 for i=1,n do
  local l={}
  for j=1,#t do
			if(t[j]==1) l[j]=rnd()<.5
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
