image={}
wimage={}
wdata["image"]=wimage
if rdata and rdata["image"] then
	image=rdata["image"]
end
function write_image(k)
	wimage[k]=image[k]
end
---------------------
function register_image(key,value)
	image[key]=value
	write_image(key)
end
image_blank=img.scan({filename=resource_prefix.."/blank.pdf"})
function image_layout_caption(w,cap,str)
	local width=math.floor(tonumber(string.match("0"..w,"[0-9]+")))
	--texio.write_nl("log","DEBUG",tex.parindent)
	tex.print("\\setbox"..tostring(cap).."\\hbox{"..str.."}\\directlua{image_layout_caption2("..tostring(width)..","..tostring(cap)..",\"\\luaescapestring{\\string"..str.."}\")}")
end
function image_layout_caption2(width,cap,str)
	local linewidth=tex.dimen["linewidth"]
	local sw=0
	if (width>linewidth/65536-40) then width=linewidth/65536-40 end
	--texio.write_nl("log","DEBUG",tex.box[cap].width/65536)
	if tex.box[cap].width>width*65536 then
		tex.print("\\setbox"..tostring(cap).."\\hbox{\\parbox{"..tostring(width).."pt}{"..str.."\\par}}")
		sw=1
	end
	--texio.write_nl("log","debug","\\makeatletter\\directlua{image_macro(\"\\the\\tmp@len@a\",\"\\the\\tmp@len@b\",\"#3\","..tostring(cap)..","..tostring(sw)..")}\\makeatother")
	tex.print("\\makeatletter\\directlua{image_macro(\"\\the\\tmp@len@a\",\"\\the\\tmp@len@b\",\"\\file\","..tostring(cap)..","..tostring(sw)..")}\\makeatother")
end
function image_macro(w,h,file,cap,sw)
	local photo,i,j,box,bh,bw,name
	local linewidth=tex.dimen["linewidth"]
	--texio.write_nl("log","DEBUG",tex.pagerightoffset/65536)
	local width=math.floor(tonumber(string.match("0"..w,"[0-9]+"))*65536)
	local height=math.floor(tonumber(string.match("0"..h,"[0-9]+"))*65536)
	if (width>linewidth) then width=linewidth end
	--print_node(tex.box[cap])
	if (sw==1) then
		box=node.copy_list(tex.box[cap].head.next.next.head.next.head)
		bw=tex.box[cap].head.next.next.head.next.width
		bh=tex.box[cap].head.next.next.head.next.height
	else
		box=node.copy_list(last_vlist(tex.box[cap]))
		bw=box.width
		bh=box.height
	end
	--texio.write_nl("debug*",tostring(box),tostring(box.height))
	local g1=node.new("glue")
	local g2=node.new("glue")
	local g3=node.new("glue")
    g1.width=(linewidth-bw)/2
    g2.width=(linewidth-bw)/2
    g3.width=tex.baselineskip.width/2
    bh=bh+g3.width
    --print_node(node.vpack(box))
    if (height<bh) then height=0 end
    --modify
    i=box
    if (i~=nil) then
		i.prev=g3
		g3.next=i
		g3.prev=nil
		box=g3
		while (i~=nil) do
			if (i.id==0) then
				j=i.head
				if (j~=nil) then
					local t=node.copy(g1)
					j.prev=t
					t.next=j
					t.prev=nil
					i.head=t
					while (j.next~=nil) do
						j=j.next
					end
					t=node.copy(g2)
					j.next=t
					t.prev=j
					t.next=nil
				end
			end
			i=i.next
		end
	end
    --modify
    local path=resource_prefix.."/"..file
    local tmp_fd=io.open(path,"r")
    if (tmp_fd==nil) then
		path=resource_prefix.."/blank.pdf"
		photo=img.copy(image_blank)
	else
		io.close(tmp_fd)
		if (false) then
			path=resource_prefix.."/blank.pdf"
			photo=img.copy(image_blank)
		else
			photo=img.scan({filename = path})
		end
	end
	--texio.write_nl("log","debug",path,photo.height,photo.width)
	photo.height=math.floor(photo.height/photo.width*width)
	photo.width=width
	if (height>0) then
		if (photo.height>height-bh) then
			photo.width=math.floor(photo.width/photo.height*(height-bh))
			photo.height=height-bh
		end
	end
	--texio.write_nl("log","debug",path,photo.height,photo.width)
	g1=node.new("glue")
	g1.width=(linewidth-photo.width)/2
	g2=node.new("glue")
	g2.width=(linewidth-photo.width)/2
	g3=node.new("glue")
    g3.width=tex.baselineskip.width/2
    --vbox=vpack(g3,hpack(g1,img.node(photo),g2),box)
    local box2,_=first_line(box,1)
    node.write(g3)
    node.write(vpack(hpack(g1,img.node(photo),g2),box))
    --node.write(box)
    if box2~=nil then node.write(box2) end
    --node.write(vbox.head)
    name=string.match(file,"[^.]+")
    --texio.write_nl("log","debug",file)

    image[name]=token.get_macro("name")
    write_image(name)
end