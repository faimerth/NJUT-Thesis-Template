if style_prefix==nil then style_prefix="./style" end
require(style_prefix.."/core.lua")

--generate dash line as list
--length,blank width,dash width,thickness,orienation,who is at the border
function dash_list(len,w,b,th,o,sw)
	local m=math.floor((len-b)/(w+b))
	local x=len-b-(w+b)*m
	local i,j,k,head
	local dash=node.new("rule")
	dash.width=th*65536
	dash.height=b*65536
	dash=node.hpack(dash)
	local white=node.new("glue")
	white.width=w*65536
	----------------
	local r1,r2=lpack_loop(m,node.copy(dash),node.copy(white))
	local tmp=node.copy(dash)
	r2.next=tmp
	tmp.prev=r2
	r2=tmp
	----------------
	white.width=x*32768
	tmp=node.copy(white)
	r2.next=tmp
	tmp.prev=r2
	r2=tmp
	tmp=node.copy(white)
	tmp.next=r1
	r1.prev=tmp
	r1=tmp
	----------------
	node.free(white)
	node.free(dash)
	return r1,r2
end
function punching(h,r,w)
	local s=2 --diameter of hole
	local a=(w+s)*r --size of whole staples
	local k
	local hole=node.new("rule")
	hole.width=s*65536
	hole.height=s*65536
	hole=node.hpack(hole)
	--local staple=node.new("glue")
	--staple.width=(w-s)*65536
	local staple=dash_list(w-s,20,10,0.5,1,0)
	staple=node.vpack(staple)
	local tmp=node.new("glue")
	tmp.width=(s*65536-staple.width)/2
	staple=hpack(tmp,staple,node.copy(tmp))
	staple=vpack(hole,staple,node.copy(hole))
	---------------------------------------------
	if (a<h) then
		local tmp=node.new("glue")
		tmp.width=math.floor((h-a)/(r)*65536)
		local r1,r2=lpack_loop(r,node.copy(staple),node.copy(tmp))
		tmp.next=r1
		r1.prev=tmp
		----
		tmp.width=tmp.width/2
		r2.width=r2.width/2
		k=tmp
	else
		k=node.new("hlist")
	end
	node.free(staple)
	return k,r2
end
------print one sheet---------
function publish_part(file,st,ed,center,scale)
	local arr={}
	local scale_wh={}
	local i=st
	while i<=ed do
		local pp=img.scan({filename=file,page=i})
		if pp==nil then
			return -1
		end
		if scale>0 then
			local t1=pp.height/pp.width
			--print margin
			local tw=(tex.pagewidth-10*65536)/2
			local th=(tex.pageheight-10*65536)
			local t2=th/tw
			if scale==1 then
				if (t1<t2) then
					pp.width=tw
					pp.height=tw*t1
					scale_wh[i-st+1]=1
				else
					pp.height=th
					pp.width=th/t1
					scale_wh[i-st+1]=2
				end
				if (math.abs(t1-t2)<0.00005) then scale_wh[i-st+1]=3 end
			else
				pp.width=tw
				pp.height=th
				scale_wh[i-st+1]=3
			end
		end
		arr[i-st+1]=img.node(pp)
		i=i+1
	end
	local size=ed-st+1
	if math.floor(size/4)*4<size then
		size=math.floor(size/4)*4+4
	end
	i=1
	local j=size-i+1
	local k=1
	while i<j do
		local swh=0
		if scale>0 then
			swh=scale_wh[i]
			if scale_wh[j] then
				swh=swh|scale_wh[j]
			end
		end
		local tmp=arr[j]
		if tmp==nil then
			tmp=node.new("rule")
			tmp.subtype=3
			tmp.width=arr[i].width
			tmp.height=arr[i].height
		end
		local mid,_=punching(arr[i].height/65536,3,100)
		mid=node.vpack(mid)
		local tmp2=node.new("rule")
		tmp2.width=65536/4
		tmp2.height=arr[i].height
		local tmp3=node.new("glue")
		tmp3.width=2*65536
		-------------------------
		local n1=lpack(arr[i],mid,tmp)
		if k>0 then
			n1=rotate_list(n1)
		end
		n1=node.hpack(n1)
		if n1.width<tex.pagewidth and ((swh&1)==0) then
			local n2=hpack(node.copy(tmp3),node.copy(tmp2))
			if center>0 then
				n1=hpack(hpack(node.copy(tmp2),node.copy(tmp3)),n1,n2)
			else
				n1=hpack(n1,n2)
			end
		end
		-------------------------
		if n1.height<tex.pageheight and ((swh&2)==0) then
			local tmp4=node.copy(tmp3)
			local tmp5=node.copy(tmp2)
			tmp5.height=tmp5.width
			tmp5.width=n1.width
			tmp5=node.hpack(tmp5)
			if center>0 then
				n1=vpack(vpack(node.copy(tmp5),node.copy(tmp4)),n1,vpack(tmp4,tmp5))
			else
				n1=vpack(n1,vpack(tmp4,tmp5))
			end
		else
			n1=node.vpack(n1)
		end
		node.free(tmp2)
		node.free(tmp3)
		-----------centering----------
		if center>0 then
			local tmp2=node.new("glue")
			tmp2.width=(tex.pagewidth-n1.width)/2
			local tmp3=node.new("glue")
			tmp3.width=(tex.pageheight-n1.height)/2
			n1=hpack(tmp2,n1,node.copy(tmp2))
			n1=vpack(tmp3,n1,node.copy(tmp3))
		end
		------------------------------
		tex.box[666+i]=n1
		tex.shipout(666+i)
		i=i+1
		j=j-1
		k=k*-1
	end
end

-------- convert 'paperback' to 'hardcover' ----------
--[[
	@1:	file path
	@2:	start page
	@3:	end page
	@4:	approximate number of text blocks
	@5:	centering
	@6:	stretch to page size. (1: keep original ratio, 2: full fill)
]]--
function publish(file,st,ed,ps,center,scale,...)
	tex.pagetopoffset=0
	tex.pagebottomoffset=0
	tex.pageleftoffset=0
	tex.pagerightoffset=0
	if center==nil then center=0 end
	if scale==nil then scale=0 end
	--------------------------------
	local parts={}
	local bsize=math.floor((ed-st+1)/ps)
	local tmp1=math.floor(bsize/4)*4
	local tmp2=tmp1+4
	local i,j
	if ps>1 then
		if (bsize-tmp1>tmp2-bsize) then
			tmp1=tmp2
		end
		bsize=tmp1
		ps=math.ceil((ed-st+1)/bsize)
		i=2
		while i<ps do
			parts[i]=bsize
			i=i+1
		end
		local tmp=(ed-st+1-bsize*(ps-2))
		parts[1]=math.ceil(tmp/8)*4
		if parts[1]>tmp then parts[1]=parts[1]-4 end
		parts[ps]=tmp-parts[1]
	else
		parts[1]=ed-st+1
	end
	i=1
	j=st
	texio.write_nl("log","bsize: "..tostring(bsize).." ps: "..tostring(ps))
	while (i<=ps) do
		publish_part(file,j,j+parts[i]-1,center,scale)
		texio.write_nl("log",tostring(j).." "..tostring(parts[i]))
		j=j+parts[i]
		i=i+1
	end
end
