function calc_linestretch(num)
	--str="0"..string.match(str,"[0-9]+[.]?[0-9]*")
	--texio.write_nl("log","debug",str..tostring(tonumber(token.get_macro("linestretch"))).."pt")
	tex.print(tostring(num*tonumber(token.get_macro("linestretch"))/65536).."pt")
end
function font_size()
	return tonumber(token.get_macro("f@size"))*65536
end
function line_indent_of()
	if (tex.nest.ptr>0) then
		tex.print("\\noindent")
	end
end
function fix_lineskip(id)
	if (tex.nest.ptr>0) then
		local i=node.last_node()
		while (i) do
			node.free(i)
			i=node.last_node()
		end
		tex.print("\\par\\directlua{fix_lineskip("..tostring(id)..")}")
	else
		local n=node.new("glue")
		local size=font_size()
		if (tex.box[id].height>size) then
			n.width=(tex.baselineskip.width-size+(size/(12*65536))*169728-tex.prevdepth)
		else
			local m,_=first_line(tex.box[id].head,1)
			if (m==nil) then
				n.width=tex.baselineskip.width-tex.prevdepth-tex.box[id].height+tex.box[id].depth
			else
				local top,_=node_top_bottom(m)
				n.width=tex.baselineskip.width-tex.prevdepth-top
			end
		end
		if (n.width<tex.lineskip.width) then n.width=tex.lineskip.width end
		--texio.write_nl("log","fuck",tostring(n.width/65536))
		node.write(n)
		node.write(node.copy(tex.box[id]))
		tex.prevdepth=(size/(12*65536))*169728
		--texio.write_nl("log","fuck",tostring(tex.prevdepth/65536))
	end
end