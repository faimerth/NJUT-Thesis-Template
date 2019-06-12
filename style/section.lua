page_title={}
doc_level={
	[-1]="part",
	[0]="chapter",
	[1]="section",
	[2]="subsection",
	[3]="subsubsection",
	[4]="body",
}
--------rdata-------
doc_obj=rdata["doc_obj"]
if doc_obj then
	doc_obj.size=0
else
	doc_obj={size=0}
end
doc_obj_map=rdata["doc_obj_map"]
if doc_obj_map==nil then
	doc_obj_map={}
end
-------wdata-------
wdoc_obj={size=0}
wdoc_obj_map={}
wdata["doc_obj"]=wdoc_obj
wdata["doc_obj_map"]=wdoc_obj_map
function write_doc_obj(id)
	wdoc_obj.size=wdoc_obj.size+1
	wdoc_obj[wdoc_obj.size]=doc_obj[id]
end
-------------------
function get_page_title()
	local i=page_id
	local j=0
	while ((page_title[i]==nil) and (i>0)) do
	   i=i-1
	end
	if i>0 then
		j=page_title[i]
	end
	i=i+1
	j=j+1
	while i<=page_id do
		page_title[i]=page_title[i-1]
		while (doc_obj[j]) do
			--texio.write_nl("log","debug",tostring(j)..","..tostring(doc_obj[j].page_id)..","..tostring(doc_obj[j].level)..tostring(doc_obj[j].name))
			if doc_obj[j].level<=1 then
				if doc_obj[j].page_id>i then
					break
				else
					page_title[i]=j;
				end
			end
			j=j+1
		end
		--texio.write_nl("log","debug",tostring(i)..","..tostring(j)..","..tostring(page_title[i]))
		i=i+1
	end
	if page_title[page_id] and page_title[page_id]>0 then
		return doc_obj[page_title[page_id]].name
	else
		return "<?>"
	end
end
function toc_string(id)
	local o=doc_obj[id]
	local str="\\contentsline {"..doc_level[o.level].."}{"..o.name.."}{"..o.page.."}{"..o.anchor.."}\\protected@file@percent"
	return str
end
function bm_string(id)
	local o=doc_obj[id]
	local str="\\@@writetorep{0}{"..o.name.."}{"..o.anchor.."}{"..tostring(o.level).."}{toc}"
	return str
end
function register_section_star(abbr,name,sym,level,plabel)
	local i=#doc_level
	if (level==nil) or (type(level)~="number") then
		while i>-2 do
			local a=tex.count["c@"..doc_level[i]]
			if a>0 then break end
			i=i-1
		end
	else
		i=level
	end
	if (plabel==nil) then plabel=token.get_macro("ch@page") end
	if (abbr==nil) then abbr=name end
	local size=doc_obj.size+1
	doc_obj[size]={
		level=i,page_id=page_id,
		abbr=tostring(abbr),
		name=tostring(name),
		page=tostring(plabel),
		anchor="section*."..tex.count["Hy@linkcounter"],
	}
	doc_obj.size=size
	write_doc_obj(size)
	--texio.write_nl("log","debug",tostring(abbr),tostring(name),tostring(sym),tostring(level),tostring(doc_obj_map))
	if (sym~=nil) then
		sym=tostring(sym)
		doc_obj_map[sym]=size
		wdoc_obj_map[sym]=doc_obj_map[sym]
	end
	return size
end
function register_section(abbr,name,sym,level,plabel,...)
	local i=register_section_star(abbr,name,sym,level,plabel)
	tex.print("\\makeatletter\\write\\@auxout{\\unexpanded{\\@writefile{toc}{" .. toc_string(i) .. "}}}\\makeatother")
	tex.print("\\makeatletter"..bm_string(i).."\\makeatother")
end
function cite_short(sym)
	if sym then
		if (doc_obj_map[sym]) then
			return doc_obj[doc_obj_map[sym]].abbr
		else
			return "<?>"
		end
	end
end
function cite_long(sym)
	if sym then
		if (doc_obj_map[sym]) then
			return doc_obj[doc_obj_map[sym]].name
		else
			return "<?>"
		end
	end
end
