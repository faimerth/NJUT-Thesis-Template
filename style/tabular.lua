tabular={}
wtabular={}
wdata["tabular"]=wtabular
if rdata and rdata["tabular"] then
	tabular=rdata["tabular"]
end
function write_tabular(k)
	wtabular[k]=tabular[k]
end
---------------------
function register_tabular(key,value)
	tabular[key]=value
	write_tabular(key)
end
