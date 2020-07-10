pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- the day my dog got in charge
-- submission to gmtk 2020
-- by a cheap plastic imitation of a game dev

t={1,2,2,2} --const

function _init()
m={{1,1,0,true},{0,0,0,false}}
k=get_best(m,{1,1,1})
?k[1].." "..k[2].." "..k[3]
?k[4]

f={true,false}
n=5
s=generate_set(t,n)
for l in all(s) do
 ?"."
 for k in all(l) do
  ?k
 end
end
end

function _update60()

end

function _draw()

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
   if(t[j]==0) l[j]=nil
			if(t[j]==1) l[j]=rnd()<.5
			if(t[j]==2) l[j]=flr(rnd(10)+5)
  end
  add(s,l)
 end
 return s
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
