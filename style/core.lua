function write_value(file,a)
	local t=type(a)
	if (t=="number") then
		file:write("1\n"..tostring(a).."\n")
	elseif (t=="string") then
		a=string.gsub(a,"\n"," ")
		file:write("2\n"..a.."\n")
	elseif (t=="nil") then
		file:write("-1\n0\n")
	end
	return t
end
function write_table(file,data)
	local count=0
	for _,_ in pairs(data) do count=count+1 end
	file:write("3\n"..tostring(count).."\n")
	for i,v in pairs(data) do
		write_value(file,i)
		if write_value(file,v)=="table" then
			write_table(file,v)
		end
	end
end
function read_data(file)
	local str=file:read()
	local t=nil
	if (str) then
		t=tonumber(str)
	end
	if (t) then
		local v=file:read()
		if t==1 then
			t=0
			if (v) then
				t=tonumber(v)
				if (t==nil) then t=0 end
			end
		elseif t==2 then
			t=v
			if (t==nil) then t="" end
		elseif t==3 then
			t={}
			if (v) then
				t=read_table(file,tonumber(v))
			end
		end
	end
	return t
end
function read_table(file,count)
	local t={}
	if (count) and (count>0) then
		local i
		for i=1,count do
			local a=read_data(file)
			local b=read_data(file)
			if a then
				t[a]=b
			end
		end
	end
	return t;
end

function rotate_list(head)
	local i=head
	while i do
		local tmp=i.next
		i.next=i.prev
		i.prev=tmp
		if tmp==nil then break end
		i=tmp
	end
	return i
end

function lpack(...)
	local start, tmp, cur, i
	start = select(1,...)
	tmp = start
	for i=2,select("#",...) do
		cur = select(i,...)
		if cur==nil then break end
		tmp.next = cur
		cur.prev = tmp
		tmp = cur
	end
	start.prev=nil --head
	tmp.next=nil --tail
	return start,tmp
end

function lpack_loop(n,...)
	local head,tail,i,j
	if n>0 then
		head,tail=lpack(...)
		j=tail
		i=2
		while i<=n do
			local tmp=node.copy_list(head,tail)
			if tmp then
				j.next=tmp
				tmp.prev=j
				j=node.tail(tmp)
			end
			tmp=node.copy(tail)
			j.next=tmp
			tmp.prev=j
			------------
			i=i+1
			j=tmp
		end
		tail=j
	end
	return head,tail
end

function pack_list(...)
	local start, tmp, cur, i
	start = select(1,...)
	tmp = node.tail(start)
	for i=2,select("#",...) do
		cur = select(i,...)
		if cur==nil then break end
		tmp.next = cur
		cur.prev = tmp
		tmp = node.tail(cur)
	end
	start.prev=nil --head
	tmp.next=nil --tail
	return start,tmp
end

function vpack(...)
	local head,tail=lpack(...)
	local h,b = node.vpack(head) -- ignore badness
	return h
end

function hpack(...)
	local head,tail=lpack(...)
	local h,b = node.hpack(head) -- ignore badness
	return h
end

function node_is_real(n)
	if (n~=nil) then
		if (node.type(n.id)=="glyph") then return n end
		if (n.id<2) then
			local i=n.head
			local t=i
			local r=nil
			if (i~=nil) then
				r=node_is_real(i)
				if r then return r end
				i=i.next
				while ((i~=nil)and(i~=t)) do
					r=node_is_real(i)
					if r then return r end
					i=i.next
				end
			end
		end
	end
	return nil
end

function node_top_bottom(n)
	local top,bottom
	top=0
	bottom=0
	if (n~=nil) then
		if (node.type(n.id)=="glyph") then
			local t=n.height-n.depth
			if t>top then top=t end
			if n.depth>bottom then bottom=n.depth end
		end
		if (n.id<2) then
			local i=n.head
			local t=i
			local tt,tm
			if (i~=nil) then
				tt,tm=node_top_bottom(i)
				if tt>top then top=tt end
				if tm>bottom then bottom=tm end
				i=i.next
				while ((i~=nil)and(i~=t)) do
					tt,tm=node_top_bottom(i)
					if tt>top then top=tt end
					if tm>bottom then bottom=tm end
					i=i.next
				end
			end
		end
	end
	return top,bottom
end
function first_line(head,num)
	local i,g
	i=head
	while ((i~=nil) and (num>0)) do
		--print_node(i)
		g=node_is_real(i)
		if g then
			num=num-1
		end
		i=i.next
		--texio.write("log","debug",num)
	end
	if ((i~=nil) and (i.prev~=nil)) then i.prev.next=nil i.prev=nil end
	return i,g
end
---extract hlists from \parbox
function last_vlist(n)
	local i,k,ans,tmp
	--texio.write_nl("debug*",tostring(n),tostring(n.height))
	if (n.id~=1) then
		tmp=node.vpack(n)
		n=tmp
	end
	--texio.write_nl("debug*",tostring(n),tostring(n.height))
	k=1
	while (k==1) do
		k=0
		i=n.head
		while (i~=nil) do
			if (i.id==1) then
				n=i
				k=1
			end
			i=i.next
		end
	end
	--texio.write_nl("debug*",tostring(n),tostring(n.height))
	n=n.head
	--texio.write_nl("debug tmp",tostring(tmp),tostring(tmp.height))
	if (tmp~=nil) then tmp.head=nil node.free(tmp) end
	--texio.write_nl("debug*",tostring(n),tostring(n.height))
	return n
end
