local M = {}

--- @class VSCodeModernConfig
--- @field cursorline? boolean
--- @field transparent_background? boolean
--- @field nvim_tree_darker? boolean
--- @field undercurl? boolean
--- @field italic_keyword? boolean
--- @field custom_dark_background? string
--- @field custom_light_background? string
--- @field custom_statusline_dark_background? string
--- @field cache_path? string
M.config = {
    cursorline = false,
    transparent_background = true, -- Set this to true
    nvim_tree_darker = false,
    undercurl = true,
    italic_keyword = false,
    custom_dark_background = '#00000000',
    custom_light_background = nil,
    custom_statusline_dark_background = nil,
    cache_path = vim.fn.stdpath 'cache' .. '/vscode_modern_theme_transparent/cache',
}

--- @overload fun(config?: VSCodeModernConfig)
function M.setup(config)
    M.config = vim.tbl_deep_extend('force', M.config, config or {})
end

local function compile_if_not_exist()
    if vim.fn.filereadable(M.config.cache_path) == 0 then
        local palette = require 'vscode_modern_theme_transparent.palette'

        local theme_dark =
            require('vscode_modern_theme_transparent.themes').dark(palette, M.config)
        local theme_light =
            require('vscode_modern_theme_transparent.themes').light(palette, M.config)

        M.compile(M.config, theme_dark, theme_light)
    end
end

function M.load()
    compile_if_not_exist()

    local f = loadfile(M.config.cache_path)
    if f ~= nil then
        f()
    else
        vim.notify(
            '[vscode_modern_theme_transparent.nvim] error trying to load cache file',
            vim.log.levels.ERROR
        )
    end
end

--- @param config VSCodeModernConfig
--- @param theme_dark VSCodeModernThemeDark
--- @param theme_light VSCodeModernThemeLight
function M.compile(config, theme_dark, theme_light)
    local lines = {
        string.format [[return string.dump(function()
vim.cmd.highlight('clear')
vim.g.colors_name="vscode_modern_theme_transparent"
local h=vim.api.nvim_set_hl
vim.opt.termguicolors=true]],
    }

    table.insert(lines, 'if vim.o.background == \'dark\' then')
    local hgs_dark = require('vscode_modern_theme_transparent.hlgroups').get(config, theme_dark)
    for group, color in pairs(hgs_dark) do
        table.insert(
            lines,
            string.format(
                [[h(0,"%s",%s)]],
                group,
                vim.inspect(color, { newline = '', indent = '' })
            )
        )
    end

    table.insert(lines, 'else')

    local hgs_light = require('vscode_modern_theme_transparent.hlgroups').get(config, theme_light)
    for group, color in pairs(hgs_light) do
        table.insert(
            lines,
            string.format(
                [[h(0,"%s",%s)]],
                group,
                vim.inspect(color, { newline = '', indent = '' })
            )
        )
    end
    table.insert(lines, 'end')

    table.insert(lines, 'end,true)')

    local cache_dir = vim.fn.stdpath 'cache' .. '/vscode_modern_theme_transparent/'

    if vim.fn.isdirectory(cache_dir) == 0 then
        vim.fn.mkdir(cache_dir, 'p')
    end

    local f = loadstring(table.concat(lines, '\n'))
    if not f then
        local path_debug_file = vim.fn.stdpath 'state'
            .. '/vscode_modern_theme_transparent-debug.lua'

        local msg = string.format(
            '[vscode_modern_theme_transparent.nvim] error, open %s for debugging',
            path_debug_file
        )
        vim.notify(msg, vim.log.levels.ERROR)

        local debug_file = io.open(path_debug_file, 'wb')
        if debug_file then
            debug_file:write(table.concat(lines, '\n'))
            debug_file:close()
        end
        return
    end

    local file = io.open(cache_dir .. '/cache', 'wb')
    if file then
        file:write(f())
        file:close()
    else
        vim.notify(
            '[vscode_modern_theme_transparent.nvim] error trying to open cache file',
            vim.log.levels.ERROR
        )
    end
end

vim.api.nvim_create_user_command('VSCodeModernCompile', function()
    local palette = require 'vscode_modern_theme_transparent.palette'

    local theme_dark = require('vscode_modern_theme_transparent.themes').dark(palette, M.config)
    local theme_light = require('vscode_modern_theme_transparent.themes').light(palette, M.config)

    M.compile(M.config, theme_dark, theme_light)

    vim.notify '[vscode_modern_theme_transparent.nvim] colorscheme compiled'
    vim.cmd.colorscheme 'vscode_modern_theme_transparent'
end, {})

return M
