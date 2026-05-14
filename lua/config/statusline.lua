-- Git branch function with caching and Nerd Font icon
local cached_branch = ""
local last_check = 0
local function git_branch()
	local function findLast(h, n)
		local i = h:match(".*" .. n .. "()")
		if i == nil then
			return nil
		else
			return i - 1
		end
	end
	local now = vim.loop.now()
	if now - last_check > 5000 then
		cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
		local last_linebreak = findLast(cached_branch, "\n")
		cached_branch = string.sub(cached_branch, last_linebreak + 1)
		last_check = now
	end
	if cached_branch ~= "" then
		return " \u{e725} " .. cached_branch .. " "
	end
	return ""
end

-- File type with Nerd Font icon
local function file_type()
	local ft = vim.bo.filetype
	local icons = {
		astro = "\u{e628} ",
		bash = "\u{f489} ",
		c = "\u{e61e} ",
		cpp = "\u{e61d} ",
		css = "\u{e749} ",
		dart = "\u{e798} ",
		dockerfile = "\u{f308} ",
		elixer = "\u{e62d} ",
		gitcommit = "\u{f418} ",
		gitconfig = "\u{f1d3} ",
		go = "\u{e724} ",
		haskell = "\u{e777} ",
		html = "\u{e736} ",
		java = "\u{e738} ",
		javascript = "\u{e74e} ",
		javascriptreact = "\u{e7ba} ",
		json = "\u{e60b} ",
		kotlin = "\u{e634} ",
		lua = "\u{e620} ",
		markdown = "\u{e73e} ",
		php = "\u{e73d} ",
		python = "\u{e73c} ",
		ruby = "\u{e739} ",
		rust = "\u{e7a8} ",
		scss = "\u{e749} ",
		sh = "\u{f489} ",
		sql = "\u{e706} ",
		svelte = "\u{e697} ",
		swift = "\u{e755} ",
		toml = "\u{e615} ",
		typescript = "\u{e628} ",
		typescriptreact = "\u{e7ba} ",
		vim = "\u{e62b} ",
		vue = "\u{fd42} ",
		xml = "\u{f05c} ",
		yaml = "\u{f481} ",
		zsh = "\u{f489} ",
	}
	if ft == "" then
		return "\u{f15b} "
	end

	return ((icons[ft] or " \u{f15b} ") .. ft)
end

local function file_size()
	local size = vim.fn.getfsize(vim.fn.expand("%"))
	if size < 0 then
		return ""
	end
	local size_str
	if size < 1024 then
		size_str = size .. "B"
	elseif size < 1024 * 1024 then
		size_str = string.format("%.1fK", size / 1024)
	else
		size_str = string.format("%.1fM", size / 1024 / 1024)
	end
	return " \u{f016} " .. size_str .. " "
end

local function mode_icon()
	local mode = vim.fn.mode()
	local modes = {
		n = " \u{f121}  NORMAL",
		i = " \u{f11c}  INSERT",
		v = " \u{f0168} VISUAL",
		V = " \u{f0168} V-LINE",
		["\22"] = " \u{f0168} V-BLOCK",
		c = " \u{f120} COMMAND",
		s = " \u{f0c5} SELECT",
		S = " \u{f0c5} S-LINE",
		["\19"] = " \u{f0c5} S-BLOCK",
		R = " \u{f044} REPLACE",
		r = " \u{f044} REPLACE",
		["!"] = " \u{f489} SHELL",
		t = " \u{f120} TERMINAL",
	}
	return modes[mode] or (" \u{f059} " .. mode)
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size

vim.cmd([[
    highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		callback = function()
			vim.opt_local.statusline = table.concat({
				" ",
				"%#StatusLineBold#",
				"%{v:lua.mode_icon()}",
				"%#StatusLine#",
				" \u{e0b1} %f %h%m%r",
				"%{v:lua.git_branch()}",
				"\u{e0b1} ",
				"%{v:lua.file_type()} ",
				"\u{e0b1} ",
				"%{v:lua.file_size()}",
				"%=",
				" \u{f017} %l:%c  %P ",
			})
		end,
	})
	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %=  %l:%c  %P"
		end,
	})
end

setup_dynamic_statusline()
