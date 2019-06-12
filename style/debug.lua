function node_debug(n)
	if (n~=nil) then
		--[[if (n.id==0)and(n.subtype==0) then
			n.subtype=1
		end]]--
		file:write(tostring(n).."id:"..node.type(n.id)..">")
		if (n.id<2) then
			local i=n.head
			local t=i
			file:write(" -> "..tostring(i).."\n")
			if (i~=nil) then
				node_debug(i)
				i=i.next
				while ((i~=nil)and(i~=t)) do
					node_debug(i)
					i=i.next
				end
			end
		else
			file:write("\n")
		end
	end
end
print_count=0
debug_file=io.open("in.in","w")
debug_file:write("shit\n")
debug_file:flush()
function print_node(n)
    if print_count==0 then file=io.open("in.in","w") print_count=1 else file=io.open("in.in","a") end
    file:write("begin\n")
    node_debug(n)
	file:write("end\n")
    io.close(file)
end

