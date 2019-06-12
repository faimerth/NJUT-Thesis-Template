# 南京工业大学本科生论文LATEX模版
本模版设计以完全自动化为目标，减少论文作者浪费在排板上的时间。使用LuaLatex1.1编写，基本遵守学校2006版本科生论文格式，兼容大部分主流宏包。~~后续功能会陆续加入敬请期待~~。欢迎任何有兴趣的朋友参与本项目。

# 非目标用户
* 你使用的宏命令/宏包无法在LuaLatex下编译。
* 你有复杂的格式需求且不会用Lua/Latex。

# 环境
* Texlive 2019
* Linux / Windows(未测试)
* 编译命令
  * `lualatex "%f"`
  * 或 `mkdir -p "./tmp" && mkdir -p "./tmp/style" && lualatex -synctex=1 -interaction=nonstopmode -halt-on-error --output-directory="./tmp" "%f"` (使用临时文件夹)
  * 或 `make` (编译论文); `make manual` (编译使用说明)

# 文档
* 学校2006版规范及参考文献标准(doc/*)
* 使用说明(manual.tex,manual.pdf)
* 论文示例/从这里开始(Thesis.tex)

# 能够自动化的功能
* 页码，页眉
* 中英文摘要，目录，参考文献及引用
* 标题、正文格式
* 图题、表题、公式编号及引用
* 单图插入

# 亟待解决
* 中文斜体

# 待实现的功能
* 脚注，图注，表注
* 自动三线表，自动跨页表，自动多表并列
* 自动多图并列
* 换页公式
* 换行、通长中文下划线

# FAQ

## 论文提交是否需要WORD版?
我全程用PDF没有任何问题。

## 这个模版对我写论文有帮助么?
已有功能都是完全自动化的，你不需要额外加入任何像\noindent、\vspace这样的排版命令。如果你只想毕业，那肯定可以帮你节省大量排版的时间。 ~~(如果已有功能有bug，我肯定会光速修复)~~

## 为什么选择LuaTex?
参见[Tex Without Tex](http://wiki.luatex.org/index.php/TeX_without_TeX)。宏展开效率低下(跟编译性语言比)，并且实现诸如自动跨页、复杂表格等功能略困难。由于没有CTeX所以只能凑合用LuaTex。PS: LuaTex编译速度明显低于XeLatex等主流Tex版本，请慎重选择。

## 为什么编译这么慢?
因为LuaTeX附带了lua脚本功能。脚本语言由于解释执行的限制，运行效率至少低一个数量级。