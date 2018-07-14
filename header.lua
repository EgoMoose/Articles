-- table_of_contents.lua
-- use this script to generate a github friendly table of contents for markdown

assert(#arg > 0)
local fileName = arg[1];
local file = assert(io.open(fileName));
local text = file:read("*all");

local header = "";

for line in string.gmatch(text, "[^\n]+") do
	local hash, title = string.match(line, "^(#+)%s*(.+)");
	if (hash and title) then
		title = string.gsub(string.gsub(title, "%s+$", ""), "[^%w%s]+", "");
		local address = string.gsub(string.lower(title), "%s+", "-")
		local depth = string.len(hash);
		
		header = header .. string.format("\n%s* [%s](#%s)", string.rep("\t", depth-1), title, address);
	end
end

local output = io.open("header_output.txt", "w");
output:write(header);
output:close();