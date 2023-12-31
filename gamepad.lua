-- title:	TICuare
-- author:	Crutiatix
-- desc:	UI library for TIC-80 v0.8.0
-- script:	lua
-- input:	gamepad

ticuare={name="ticuare",elements={},z=1,hz=nil}ticuare.__index=ticuare;ticuare.me={nothing=0,click=1,noclick=2,none=3}local a={__index=ticuare}local function b(c,d,e,f,g,h)return c>e and c<e+g and d>f and d<f+h end;local function i(j,k,l)for m,n in pairs(k)do if type(n)=="table"then if type(j[m]or false)=="table"then i(j[m]or{},k[m]or{},l)else if not j[m]or l then j[m]=n end end else if not j[m]or l then j[m]=n end end end;return j end;local function o(p,q)if p==nil and q==nil then for r=0,15 do poke4(0x3FF0*2+r,r)end else poke4(0x3FF0*2+p,q)end end;local function s(t)local u={}local function v(t)if type(t)~="table"then return t elseif u[t]then return u[t]end;local w={}u[t]=w;for r,n in pairs(t)do w[v(r)]=v(n)end;return setmetatable(w,getmetatable(t))end;return v(t)end;function ticuare.print(x,e,f,y,h,z)local A,B,C=0,0,0;for D in x:gmatch("([^\n]+)")do C=C+1;A=print(D,e,f+(C-1)*h,y,z)if A>B then B=A end end;return A,C*h end;function ticuare.font(x,e,f,y,h,E,F)local A,B,C=0,0,0;for D in x:gmatch("([^\n]+)")do C=C+1;if type(E)=="table"and type(E[1])=="table"then for G,H in ipairs(E[1])do if type(y)=="table"then o(H,y[G])else o(H,y)end end else o(E[1],y)end;A=font(D,e,f+(C-1)*h,E[2],F)o()if A>B then B=A end end;return A,C*h end;function ticuare.element(I,J)if not J then J=I;I="element"end;local K=J;setmetatable(K,ticuare)K.hover,K.click=false,false;K.activity=J.activity or true;K.drag=J.drag or{activity=false}K.align=J.align or{x=0,y=0}K.visibility=J.visibility or true;if K.content then if not K.content.scroll then K.content.scroll={x=0,y=0}end;K.content.w,K.content.h=K.content.w or K.w,K.content.h or K.h end;K.type,K.z=I,ticuare.z;ticuare.z=ticuare.z+1;ticuare.hz=ticuare.z;table.insert(ticuare.elements,K)return K end;function ticuare.Element(L)return ticuare.element("element",L)end;function ticuare.Style(L)return L end;function ticuare.Group()local M={type="group",elements={}}setmetatable(M,ticuare)return M end;function ticuare:updateSelf(N)if N.mouse_x and N.mouse_y and N.event then mouse_x=N.mouse_x;mouse_y=N.mouse_y;mouse_press=N.press;mouse_event=N.event;local O,P,Q,R,S,T,U;local V,W,X=ticuare.me,self.x-(self.align.x==1 and self.w*.5 or(self.align.x==2 and self.w or 0)),self.y-(self.align.y==1 and self.h*.5-1 or(self.align.y==2 and self.h-1 or 0))O=mouse_event~=V.none and mouse_press or false;P=b(mouse_x,mouse_y,W,X,self.w,self.h)Q=mouse_event~=V.none and P or false;R,S=self.hover,self.hold;self.hover=Q or self.drag.activity and ticuare.draging_obj and ticuare.draging_obj.obj==self;self.hold=mouse_event==V.click and Q and true or O and self.hold or Q and mouse_event~=V.noclick and self.hold;if mouse_event==V.click and Q and self.onClick then self.onClick()elseif mouse_event==V.noclick and Q and S and self.onCleanRelease then self.onCleanRelease()elseif(mouse_event==V.noclick and Q and S or self.hold and not Q)and self.onRelease then self.onRelease()elseif self.hold and self.onPress then self.onPress()elseif not R and self.hover and self.onStartHover then self.onStartHover()elseif self.hover and self.onHover then self.onHover()elseif R and not self.hover and self.onReleaseHover then self.onReleaseHover()end;if self.hold and(not Q or self.drag.activity)and not ticuare.draging_obj then self.hold=self.drag.activity;ticuare.draging_obj={obj=self,d={x=W-mouse_x,y=X-mouse_y}}elseif not self.hold and Q and(ticuare.draging_obj and ticuare.draging_obj.obj==self)then self.hold=true;ticuare.draging_obj=nil end;if ticuare.draging_obj and ticuare.draging_obj.obj==self and self.drag.activity then self.x=(not self.drag.fixed or not self.drag.fixed.x)and mouse_x+ticuare.draging_obj.d.x or self.x;self.y=(not self.drag.fixed or not self.drag.fixed.y)and mouse_y+ticuare.draging_obj.d.y or self.y;local Y=self.drag.bounds;if Y then if Y.x then self.x=Y.x[1]and self.x<Y.x[1]and Y.x[1]or self.x;self.x=Y.x[2]and self.x>Y.x[2]and Y.x[2]or self.x end;if Y.y then self.y=Y.y[1]and self.y<Y.y[1]and Y.y[1]or self.y;self.y=Y.y[2]and self.y>Y.y[2]and Y.y[2]or self.y end end;if self.track then self:anchor(self.track.ref)end end;return Q elseif N.focused_element and N.event then local V,Z,_,Q,R,S=ticuare.me;Z=N.event~=V.none and N.press or false;_=self==N.focused_element;Q=N.event~=V.none and _ or false;R,S=self.hover,self.hold;self.hover=Q;self.hold=N.event==V.click and Q and true or Z and self.hold or Q and N.event~=V.noclick and self.hold;if N.event==V.click and Q and self.onClick then self.onClick()elseif N.event==V.noclick and Q and S and self.onCleanRelease then self.onCleanRelease()elseif(N.event==V.noclick and Q and S or self.hold and not Q)and self.onRelease then self.onRelease()elseif self.hold and self.onPress then self.onPress()elseif not R and self.hover and self.onStartHover then self.onStartHover()elseif self.hover and self.onHover then self.onHover()elseif R and not self.hover and self.onReleaseHover then self.onReleaseHover()end;return Q else error("updateSelf error in arguments!")end end;function ticuare:updateTrack()local Y,a0=self.drag.bounds,self.track;if a0 then self.x,self.y=a0.ref.x+a0.d.x,a0.ref.y+a0.d.y;if Y and Y.relative then if Y.x then Y.x[1]=a0.ref.x+a0.b.x[1]or nil;Y.x[2]=a0.ref.x+a0.b.x[2]or nil end;if Y.y then Y.y[1]=a0.ref.y+a0.b.y[1]or nil;Y.y[2]=a0.ref.y+a0.b.y[2]or nil end end end end;function ticuare:drawSelf()if self.visibility then local a1,a2,a3,a4,a5,a6,W,X,a7,a8,a9,aa,ab,ac,ad,ae,af;local ag,ah,ai,aj=self.shadow,self.border,self.text,self.icon;W=self.x-(self.align.x==1 and self.w*.5-1 or(self.align.x==2 and self.w-1 or 0))X=self.y-(self.align.y==1 and self.h*.5-1 or(self.align.y==2 and self.h-1 or 0))if ag and ag.colors then ag.offset=ag.offset or{x=1,y=1}a2=self.hold and ag.colors[3]and ag.colors[3]or self.hover and ag.colors[2]and ag.colors[2]or ag.colors[1]or nil;if a2 then rect(W+ag.offset.x,X+ag.offset.y,self.w,self.h,a2)end end;if self.colors then a1=self.hold and self.colors[3]and self.colors[3]or self.hover and self.colors[2]and self.colors[2]or self.colors[1]or nil;if a1 then rect(W,X,self.w,self.h,a1)end end;if ah and ah.colors and ah.width then af=ah.width or 0;a3=self.hold and ah.colors[3]and ah.colors[3]or self.hover and ah.colors[2]and ah.colors[2]or ah.colors[1]or nil;if a3 then for ak=0,ah.width-1 do rectb(W+ak,X+ak,self.w-2*ak,self.h-2*ak,a3)end end else af=0 end;if aj and aj.sprites and#aj.sprites>0 then a6=self.hold and aj.sprites[3]and aj.sprites[3]or self.hover and aj.sprites[2]and aj.sprites[2]or aj.sprites[1]ab=aj.offset or{x=0,y=0}aj.key=aj.key or-1;aj.measure=aj.measure or 1;aj.flip=aj.flip or 0;aj.rotate=aj.rotate or 0;aj.extent=aj.extent or{x=1,y=1}aj.align=aj.align or{x=0,y=0}for e=1,aj.extent.x do for f=1,aj.extent.y do spr(a6+e-1+(f-1)*16,W+(aj.align.x==1 and self.w*.5-e*aj.measure*8/2 or(aj.align.x==2 and self.w-e*aj.measure*8 or 0))+ab.x,X+(aj.align.y==1 and self.h*.5-f*aj.measure*8/2 or(aj.align.y==2 and self.h-f*aj.measure*8 or 0))+ab.y,aj.key,aj.measure,aj.flip,aj.rotate)end end end;if ai and ai.print and ai.colors[1]then ai.colors[1]=ai.colors[1]or 14;ai.gap=ai.gap or 5;ai.key=ai.key or-1;ai.height=ai.height or(ai.font and 8 or 6)ai.fixed=ai.fixed or false;if self.hold and ai.colors[3]then a5=ai.colors[3]elseif self.hover and ai.colors[2]then a5=ai.colors[2]else a5=ai.colors[1]end;if ai.shadow then if self.hold and ai.shadow.colors[3]then a4=ai.colors[3]elseif self.hover and ai.shadow.colors[2]then a4=ai.shadow.colors[2]else a4=ai.shadow.colors[1]end;ad=ai.shadow.offset or{x=1,y=1}end;ac=ai.offset or{x=0,y=0}if ai.font then a7,a8=ticuare.font(ai.print,0,200,-1,ai.height,ai.key,ai.gap)else a7,a8=ticuare.print(ai.print,0,200,-1,ai.height,ai.fixed)end;ai.align=ai.align or{x=0,y=0}if ai.align.x==1 then a9=W+self.w*.5-a7*.5+ac.x elseif ai.align.x==2 then a9=W+self.w-a7+ac.x-af else a9=W+ac.x+af end;if ai.align.y==1 then aa=X+self.h*.5-a8*.5+ac.y elseif ai.align.y==2 then aa=X+self.h-a8+ac.y-af else aa=X+ac.y+af end;if ai.font then if ai.shadow and a4 then ticuare.font(ai.print,a9+ad.x,aa+ad.y,a4,ai.height,ai.key,ai.gap)ticuare.font(ai.print,a9,aa,a5,ai.height,ai.key,ai.gap)else ticuare.font(ai.print,a9,aa,a5,ai.height,ai.key,ai.gap)end else if ai.shadow and a4 then ticuare.print(ai.print,a9+ad.x,aa+ad.y,a4,ai.height,ai.fixed)ticuare.print(ai.print,a9,aa,a5,ai.height,ai.fixed)else ticuare.print(ai.print,a9,aa,a5,ai.height,ai.fixed)end end end;if self.content and self.drawContent then if self.content.wrap and clip then clip(W+af,X+af,self.w-2*af,self.h-2*af)end;self:renderContent()if self.content.wrap and clip then clip()end end end end;function ticuare:renderContent()local al,am,ah,an,ao;al=self.x-(self.align.x==1 and self.w*.5 or(self.align.x==2 and self.w or 0))am=self.y-(self.align.y==1 and self.h*.5-1 or(self.align.y==2 and self.h-1 or 0))ah=self.border and self.border.width and self.border.width or 1;an=al-(self.content.scroll.x or 0)*(self.content.w-self.w)+ah;ao=am-(self.content.scroll.y or 0)*(self.content.h-self.h)+ah;self.drawContent(self,an,ao)end;function ticuare:Content(L)self.drawContent=L;return self end;function ticuare:scroll(L)if L~=nil then L.x=L.x or 0;L.y=L.y or 0;if self.content then L.x=L.x<0 and 0 or L.x>1 and 1 or L.x;L.y=L.y<0 and 0 or L.y>1 and 1 or L.y;self.content.scroll.x,self.content.scroll.y=L.x or self.content.scroll.x,L.y or self.content.scroll.y end;return self else if self.content then return self.content.scroll end end end;function ticuare.update(mouse_x,mouse_y,ap)local V,aq=ticuare.me,ticuare.elements;local mouse_event,ar,as,at=V.nothing,false,{},nil;if type(mouse_x)=="table"then ap=mouse_y end;if mouse_x then if ticuare.click and not ap then ticuare.click=false;mouse_event=V.noclick;ticuare.draging_obj=nil elseif not ticuare.click and ap then ticuare.click=true;mouse_event=V.click;ticuare.draging_obj=nil end;for r=1,#aq do table.insert(as,aq[r])end;table.sort(as,function(au,ak)return au.z>ak.z end)for r=1,#as do at=as[r]if at then if type(mouse_x)=="table"then if at:updateSelf{focused_element=mouse_x,press=ap,event=(ar or not at.activity)and V.none or mouse_event}then ar=true end elseif mouse_x and mouse_y and type(mouse_x)~="table"then if at:updateSelf{mouse_x=mouse_x,mouse_y=mouse_y,press=ap,event=(ar or ticuare.draging_obj and ticuare.draging_obj.obj~=at or not at.activity)and V.none or mouse_event}then ar=true end else error("Wrong arguments for update()")end end end;for r=#aq,1,-1 do if aq[r]then aq[r]:updateTrack()end end end end;function ticuare.draw()local av={}for r=1,#ticuare.elements do if ticuare.elements[r].draw then table.insert(av,ticuare.elements[r])end end;table.sort(av,function(au,ak)return au.z<ak.z end)for r=1,#av do av[r]:drawSelf()end end;function ticuare:style(aw)if self.type=="group"then for m,n in pairs(self.elements)do i(n,s(aw),false)end else i(self,s(aw),false)end;return self end;function ticuare:anchor(ax)if self.type=="group"then for m,n in pairs(self.elements)do n:anchor(ax)end else local Y,ay,az,aA,aB=self.drag.bounds,nil,nil,nil,nil;if Y and Y.x then ay=Y.x[1]-ax.x;az=Y.x[2]-ax.x elseif Y and Y.y then aA=Y.y[1]-ax.y;aB=Y.y[2]-ax.y end;self.track={ref=ax,d={x=self.x-ax.x,y=self.y-ax.y},b={x={ay,az},y={aA,aB}}}end;return self end;function ticuare:group(aC,aD)if aD then aC.elements[aD]=self else table.insert(aC.elements,self)end;return self end;function ticuare:active(aE)if aE~=nil then if self.type=="group"then for m,n in pairs(self.elements)do n:active(aE)end else self.activity=aE end;return self else if self.type=="group"then local aF={}for m,n in pairs(self.elements)do aF[m]=n:active()end;return aF else if self.activity~=nil then return self.activity end end end end;function ticuare:visible(aE)if aE~=nil then if self.type=="group"then for m,n in pairs(self.elements)do n:visible(aE)end else self.visibility=aE end;return self else if self.type=="group"then local aF={}for m,n in pairs(self.elements)do aF[m]=n:visible()end;return aF else if self.activity~=nil then return self.visibility end end end end;function ticuare:dragBounds(Y)if Y~=nil then self.drag.bounds=Y else return self.drag.bounds end end;function ticuare:horizontalRange(aG)local Y=self.drag.bounds;if aG~=nil then self.x=Y.x[1]+(Y.x[2]-Y.x[1])*aG else assert(Y and Y.x and#Y.x==2,"X bounds error!")return(self.x-Y.x[1])/(Y.x[2]-Y.x[1])end end;function ticuare:verticalRange(aG)local Y=self.drag.bounds;if aG~=nil then self.y=Y.y[1]+(Y.y[2]-Y.y[1])*aG else assert(Y and Y.y and#Y.y==2,"Y bounds error!")return(self.y-Y.y[1])/(Y.y[2]-Y.y[1])end end;function ticuare:index(aH)if aH~=nil then if self.type=="group"then local aI;for m,n in pairs(self.elements)do if not aI or n.z<aI then aI=n.z end end;for m,n in pairs(self.elements)do local aJ=n.z-aI+aH;n:index(aJ)end else self.z=aH;if aH>ticuare.hz then ticuare.hz=aH end end else return self.z end;return end;function ticuare:toFront()if self.z<ticuare.hz or self.type=="group"then return self:index(ticuare.hz+1)end end;function ticuare:remove()for r=#ticuare.elements,1,-1 do if ticuare.elements[r]==self then table.remove(ticuare.elements,r)self=nil end end end;function ticuare.empty()for r=1,#ticuare.elements do ticuare.elements[r]=nil end end


-- class for input more characters
function wordInput (x,y,length,la)
	-- support function
	function table.index(t, item)
		for i, v in ipairs(t) do
			if v == item then 
				return i 
			end
		end
	end

	-- class for input chars
	function letterInput (x,y,la) -- x, y - position; li - letter index in la- letters array 
		-- Element containing letter
		local letter = ticuare.element({
			x=x-2, y=y+1+8, w=12, h=11,
			colors={1,1,1},
			text={
				print=" ",
				font=true, -- use font instead print
				align={x=1,y=1}, -- center in horisontal and vertical axis
				offset={x=1,y=1}, -- shift
				colors={{6,9,14},{9,14,15},{14,15,15}}, -- colors for replace for default, hover and hold state
				key={{6,9,14},5} -- {{colors to be replaced}transparent color}
			},
			content={},
			
		})
			
		letter.onHover=function() -- set action when is focused
			local indx
			if btnp(0,1,10) then
				indx = table.index(la, letter.text.print) -- get index of actual letter
				letter.text.print=la[indx < #la and indx+1 or 1] -- next letter if not last else first
			elseif btnp(1,1,10) then
				indx = table.index(la, letter.text.print) -- get index of actual letter
				letter.text.print=la[indx > 1 and indx-1 or #la] -- previous letter if not first, else last
			elseif btnp(2,1,10) then  
				focused = focused > 1 and focused-1 or #elements_list 
			elseif btnp(3,1,10) then  
				focused = focused < #elements_list and focused+1 or 1 
			end
		end

		letter:Content(function(ref,x,y) -- draw arrows
			if ref.hover then
				if btn(0) then
					spr(4,x+1,y-9,0)
				else
					spr(3,x+1,y-9,0)
				end
				
				if btn(1) then
					spr(7,x+1,y+ref.h-1,0)
				else
					spr(6,x+1,y+ref.h-1,0)
				end
			else
				spr(2,x+1,y-9,0)
				spr(5,x+1,y+ref.h-1,0)
			end
		end)
		
		return letter
	end

	self={}
	self.inputs = {}
	for i=0, length-1 do -- create characters inputs
		table.insert(self.inputs, letterInput(x+i*12,y,la))
	end
	
	function self.get() -- function to get whole input text
		local result = ""
		for k, v in ipairs(self.inputs) do
			result = result..v.text.print
		end
		return result
	end
	
	function self.set(s) -- function to set letters of input
		t={}
		for i=1,#s do
			table.insert(t,s:sub(i,i))
		end
		for k, v in ipairs(self.inputs) do
			v.text.print = t and t[k] or " "
		end
	end
	return self
end	


-- BUTTON for geting and printing text from input
add = ticuare.element({
	x=120-25,y=50,w=40,h=11,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	text={
		print="ADD",
		font=true,
		align={x=1,y=1},
		offset={x=1,y=0},
		colors={{6,9,14},{9,14,15},{14,15,15}},
		key={{6,9,14},5}
	},
	onClick=function()
		list=list..input.get().."\n"
	end,
	onHover=function()
		if btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

--BUTTON for clear list and input letters
clear = ticuare.element({
	x=120+25,y=50,w=40,h=11,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	text={
		print="CLEAR",
		font=true,
		align={x=1,y=1},
		offset={x=1,y=0},
		colors={{6,9,14},{9,14,15},{14,15,15}},
		key={{6,9,14},5}
	},
	onClick=function()
		input.set("      ")
		list=""
	end,
	onHover=function()
		if btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

-- List Container
content_height=0
container = ticuare.element({
	x=120,y=95,w=70,h=60,
	align={x=1,y=1},
	colors={1,1,1},
	shadow={
		colors={1,6,9}
	},
	border={
		colors={6,9,14},
		width=1
	},
	content={
		w=0,h=0,
		wrap=true,  -- clip content
		scroll={x=0,y=0} -- set initial scroll to left top
	},
	onHover=function() -- scroll content proportionaly to position of cursor
		local s = container:scroll()
		if btnp(1,1,10) then
			container:scroll{x=0,y=s.y+0.05}
		elseif btnp(0,1,10) then
			container:scroll{x=0,y=s.y-0.05}
		elseif btnp(2,1,10) then  
			focused = focused > 1 and focused-1 or #elements_list 
		elseif btnp(3,1,10) then  
			focused = focused < #elements_list and focused+1 or 1 
		end
	end
})

container:Content(function(ref,x,y)
	w,h=ticuare.font(list,x+35-24,y+5,{6,9,14},8,{{6,9,14},5},1) -- print out added text
	ref.content.w=w	-- set content size acording to list size
	ref.content.h=h+26
end)


-- charset
letters = {" ","_","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9"}

-- Input interface
input = wordInput(120+2-(7*12)/2,10,7,letters)
input.set("TICUARE")
list = ""

elements_list={
	input.inputs[1],
	input.inputs[2],
	input.inputs[3],
	input.inputs[4],
	input.inputs[5],
	input.inputs[6],
	input.inputs[7],
	add,clear,container
}

focused=1

-- BASIC LOOP
function TIC()
	cls(0)
	ticuare.update(elements_list[focused],btn(5)) -- use gamepad cursor instead of mouse
	ticuare.draw()
end


-- <TILES>
-- 001:666000006e90000069e90000009e90000009e900000099000000000000000000
-- 002:00000000000660000069e60006999e60699999e6699999e66666666600000000
-- 003:00000000000660000069e600069eee6069eeeee669eeeee66666666600000000
-- 004:0000000000099000009ef90009eeef909eeeeef99eeeeef99999999900000000
-- 005:0000000066666666699999e6699999e606999e600069e6000006600000000000
-- 006:000000006666666669eeeee669eeeee6069eee600069e6000006600000000000
-- 007:00000000999999999eeeeef99eeeeef909eeef90009ef9000009900000000000
-- 017:a555555aa555555aaaaaaaaaaafaaafaafffaaaaaafaafaaaaaaaaaa77777777
-- 018:a888888aa888888aaaaaaaaaaafaaafaafffaaaaaafaafaaaaaaaaaa77777777
-- </TILES>

-- <SPRITES>
-- 032:5555555555555555555555555555555555555555555555555555555555555555
-- 033:555ee555555ee555555e95555559655555569555555555555556655555555555
-- 034:5ee5ee555ee5ee55555555555555555555555555555555555555555555555555
-- 035:5ee5ee555ee5ee559e9e9e955965695596969695596569555665665555555555
-- 036:555ee55555eeeee55e9555555569695555555695596969555556655555555555
-- 037:555555555ee55ee595959e556959655555965695596565656655665555555555
-- 038:55eee5555ee5ee555e9595555969596596569655695569655666656655555555
-- 039:555ee555555ee555559e55555555555555555555555555555555555555555555
-- 040:5555ee55555ee555559e55555569555555965555555965555555665555555555
-- 041:55ee5555555ee55555559e555555695555559655555965555566555555555555
-- 042:555555555ee55ee5559e9e556969696955969655596559655555555555555555
-- 043:55555555555ee555555e95555969696555569555555965555555555555555555
-- 044:5555555555555555555555555555555555555555555965555556655555665555
-- 045:5555555555555555555555555969696555555555555555555555555555555555
-- 046:5555555555555555555555555555555555555555555965555556655555555555
-- 047:555555ee55555ee555559e555559655555965555596555556655555555555555
-- 048:55eeee555e955e95596569655696969559695965566556655566665555555555
-- 049:555ee555559e9555596965555556955555596555555665555556655555555555
-- 050:55eeee555e955e95555559655555965555596555556655555666666555555555
-- 051:55eeee555e955e95555559655556965555555965566556655566665555555555
-- 052:555eee55559e9e55596569559655965569696965555566555555665555555555
-- 053:5eeeeee55e955555596969555555569555555965566556655566665555555555
-- 054:555eee55559e5555596555555696965559655965566556655566665555555555
-- 055:5eeeeee555555e95555559655555965555596555555665555556655555555555
-- 056:55eeee555e955e95596559655596965559655965566556655566665555555555
-- 057:55eeee555e955e95596559655596969555555965555566555566655555555555
-- 058:55555555555e9555555965555555555555555555555665555556655555555555
-- 059:55555555555e9555555965555555555555555555555665555556655555ee5555
-- 060:5555555555555e95555965555695555555596555555556655555555555555555
-- 061:5555555555555555596969655555555559696965555555555555555555555555
-- 062:555555555e955555555965555555569555596555566555555555555555555555
-- 063:55eeee555e955e95555559655555965555596555555555555556655555555555
-- 064:55eeee555e955e95595965655656959559596965566555555566665555555555
-- 065:55eeee555e955e95596559655696969559655965566556655665566555555555
-- 066:5eeeee555e955e95596559655696965559655965566556655666665555555555
-- 067:555eeee5559e5555596555555695555559655555556655555556666555555555
-- 068:5eeee5555e959e55596559655695569559655965566566555666655555555555
-- 069:5eeeeee55e955555596555555696955559655555566555555666666555555555
-- 070:5eeeeee55e955555596555555696955559655555566555555665555555555555
-- 071:55eeee555e955e95596555555695969559655965566556655566666555555555
-- 072:5ee55ee55e955e95596559655696969559655965566556655665566555555555
-- 073:55eeee55555e9555555965555556955555596555555665555566665555555555
-- 074:55555ee555555e95555559655555569555555965566556655566665555555555
-- 075:ee555ee59e559e55695965559696555569596555665566556655566555555555
-- 076:5ee555555e955555596555555695555559655555566555555666666555555555
-- 077:ee555ee59e959e95696969659656569569555965665556656655566555555555
-- 078:ee555ee59e955e95696959659656969569556965665556656655566555555555
-- 079:55eeee555e955e95596559655695569559655965566556655566665555555555
-- 080:5eeeee555e955e95596559655696965559655555566555555665555555555555
-- 081:5eeee5559e559e55695569559655965569556955665666555666666555555555
-- 082:5eeeee555e955e95596559655696965559656955566556655665566555555555
-- 083:55eeee555e955e95596955555596965555556965566556655566665555555555
-- 084:5eeeeee5555e9555555965555556955555596555555665555556655555555555
-- 085:5ee55ee55e955e95596559655695569559655965566556655566665555555555
-- 086:5ee55ee55e955e95596559655695569555696955556666555556655555555555
-- 087:ee555ee59e555e95695559659656569569696965666566656655566555555555
-- 088:ee5555ee5e955e95556969555556955555696955566556656655556655555555
-- 089:ee5555ee5e955e95556969555556955555596555555665555556655555555555
-- 090:eeeeeee555559e55555965555596555559655555665555556666666555555555
-- 091:55eeee55559e5555556955555596555555695555556655555566665555555555
-- 092:ee5555555e955555556955555556955555556955555556655555556655555555
-- 093:55eeee5555559e55555569555555965555556955555566555566665555555555
-- 094:555ee555559e9e55596559655555555555555555555555555555555555555555
-- 095:5555555555555555555555555555555555555555555555556666665555555555
-- 096:555ee555555ee55555559e555555555555555555555555555555555555555555
-- 097:5555555555555555559e9e555555596555969695596559655566666555555555
-- 098:5ee555555ee555555e9e9e555965596556955695596559655666665555555555
-- 099:5555555555555555559e9e555965555556955555596555555566665555555555
-- 100:55555ee555555ee5559e9e955965596556955695596559655566666555555555
-- 101:5555555555555555559e9e555965596556969695596555555566665555555555
-- 102:555eee5555ee55555e9e9e555569555555965555556955555566555555555555
-- 103:5555555555555555559e9e955965596556955695556969655555566555666655
-- 104:5ee555555ee555555e9e9e555965596556955695596559655665566555555555
-- 105:555ee55555555555555e95555559655555569555555965555555665555555555
-- 106:5555ee555555555555559e555555695555559655555569555555665556666555
-- 107:5ee555555ee555555e955e955965695556969555596569555665566555555555
-- 108:555ee555555ee555555e95555559655555569555555965555555665555555555
-- 109:55555555555555559e959e556969696596565695695559656655566555555555
-- 110:55555555555555555e9e9e555965596556955695596559655665566555555555
-- 111:5555555555555555559e9e555965596556955695596559655566665555555555
-- 112:55555555555555555e9e9e555965596556955695596969555665555556655555
-- 113:5555555555555555559e9e955965596556955695556969655555566555555665
-- 114:55555555555555555e9e9e555965596556955555596555555665555555555555
-- 115:5555555555555555559e9e555965555555969655555559655666665555555555
-- 116:55ee555555ee55555e9e9e555569555555965555556955555556665555555555
-- 117:55555555555555555e955e955965596556955695596559655566666555555555
-- 118:55555555555555555e955e955965596556955695556969555556655555555555
-- 119:55555555555555559e555e956955596596565695696969655665665555555555
-- 120:55555555555555559e555e955965695555969555596569556655566555555555
-- 121:55555555555555555e955e955965596556955695556969555556655555665555
-- 122:55555555555555555e9e9e955555695555569555556955555666666555555555
-- 123:5555ee55555ee555555e95555569555555569555555965555555665555555555
-- 124:555ee555555ee555555e95555559655555569555555965555556655555555555
-- 125:55ee5555555ee555555e95555555695555569555555965555566555555555555
-- 126:555555555eee5ee59e5e9e555555555555555555555555555555555555555555
-- 127:5555555555555555555555555555555555555555555555555555555555555555
-- 128:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 129:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 130:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 131:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 132:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 133:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 134:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 135:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 136:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 137:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 138:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 139:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 140:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 141:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 142:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 143:00000000000000000000000000000000eeeeeeeeeeeeeeee9e9e9e9e69696969
-- 144:9696969669696969666666666666666600000000000000000000000000000000
-- 145:9696969669696969666666666666666600000000000000000000000000000000
-- 146:9696969669696969666666666666666600000000000000000000000000000000
-- 147:9696969669696969666666666666666600000000000000000000000000000000
-- 148:9696969669696969666666666666666600000000000000000000000000000000
-- 149:9696969669696969666666666666666600000000000000000000000000000000
-- 150:9696969669696969666666666666666600000000000000000000000000000000
-- 151:9696969669696969666666666666666600000000000000000000000000000000
-- 152:9696969669696969666666666666666600000000000000000000000000000000
-- 153:9696969669696969666666666666666600000000000000000000000000000000
-- 154:9696969669696969666666666666666600000000000000000000000000000000
-- 155:9696969669696969666666666666666600000000000000000000000000000000
-- 156:9696969669696969666666666666666600000000000000000000000000000000
-- 157:9696969669696969666666666666666600000000000000000000000000000000
-- 158:9696969669696969666666666666666600000000000000000000000000000000
-- 159:9696969669696969666666666666666600000000000000000000000000000000
-- </SPRITES>

-- <PALETTE>
-- 000:140c1c44243430346d4e4a4e854c30346524d04648757161597dced27d2c8595a16daa2cd2aa996dc2cadad45edeeed6
-- </PALETTE>

