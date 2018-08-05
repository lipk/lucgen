#!/usr/bin/env lua

function readAll(file)
	local handle = assert(io.open(file, 'r'))
	local contents = assert(handle:read('a'))
	handle:close()
	return contents
end

function append(array, item)
	array[#array + 1] = item;
end

function skipComment(text, i)
	i = i+2
	while i <= text:len() do
		if text:sub(i,i+1) == '*/' then
			return i
		end
		i = i+1
	end
	return i
end

function skipString(text, i)
	local ending = text:sub(i,i)
	local escapeNext = false
	i = i+1
	while i <= text:len() do
		if escapeNext then
			escapeNext = false
		else
			if text:sub(i,i) == ending then
				return i
			elseif text:sub(i,i) == '\\' then
				escapeNext = true
			end
		end
		i = i+1
	end
	return i
end

function parse(file)
	local text = readAll(file);
	local parts = {{}}
	i = 1
	local indent = 0;
	while i <= text:len() do
		local c = text:sub(i,i)
		if c == '"' or c == "'" then
			j = skipString(text, i)
			append(parts[#parts], text:sub(i,j))
			i = j
		elseif text:sub(i,i+1) == '/*' then
			j = skipComment(text, i)
			append(parts[#parts], text:sub(i,j))
			i = j
		elseif c == '@' then
			append(parts, {})
		else
			append(parts[#parts], c)
		end
		i = i+1
	end
	for i, part in ipairs(parts) do
		parts[i] = table.concat(part)
	end
	return parts
end

function process(file)
	local parts = parse(file)
	for i = 2, #parts, 2 do
		local output = {""};
		emit = function(text)
			append(output, text)
		end
		local indent = '\n' .. parts[i-1]:match('[\t ]*$')
		assert(loadstring(parts[i]))()
		parts[i] = table.concat(output):gsub('\n', indent)
	end
	return table.concat(parts)
end

i = 1
source = nil
target = nil
preload = nil
while i <= #arg do
	if arg[i] == '-o' then
		assert(target == nil)
		target = assert(arg[i+1])
		i = i+1
	elseif arg[i] == '-l' then
		assert(preload == nil)
		preload = assert(arg[i+1])
		i = i+1
	elseif arg[i] == '-h' then
		print('Usage: lucgen.lua SOURCEFILE [-o TARGETFILE] [-l PRELOADFILE] [-h]')
		os.exit()
	else
		assert(source == nil)
		source = arg[i]
	end
	i = i+1
end

assert(source)
if preload then
	assert(loadfile(preload))()
end
generated = process(source)
if target then
	local out = io.open(target, 'w')
	out:write(generated)
	out:close()
else
	io.write(generated)
end