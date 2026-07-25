-- nvim-treesitter `main` branch configuration.
--
-- The `main` branch is a ground-up rewrite: `setup()` only reads `install_dir`,
-- and the old module options (`highlight`, `indent`, `incremental_selection`,
-- `textobjects`, `ensure_installed`) no longer exist. Parsers are installed
-- explicitly, and highlighting/indentation are started per-buffer.
local ensure_installed = {
  "astro",
  "bash",
  "c",
  "comment",
  "cpp",
  "css",
  "diff",
  "git_rebase",
  "gitcommit",
  "gitignore",
  "html",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "jsonc",
  "lua",
  "markdown",
  "markdown_inline",
  "pug",
  "python",
  "regex",
  "ruby",
  "rust",
  "tsx",
  "typescript",
  "vim",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    -- Load before the first buffer is read so the FileType autocmd below is
    -- registered in time to start highlighting on the initial file.
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
      },
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        init = function()
          vim.g.skip_ts_context_commentstring_module = true
        end,
        opts = {
          enable_autocmd = false,
        },
      },
    },
    keys = {
      { "<leader>tp", "<cmd>InspectTree<cr>", desc = "Treesitter Inspect Tree" },
    },
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()

      -- Filetype -> parser aliases. `jsonc` no longer ships its own parser on
      -- the `main` branch, so it falls back to the `json` parser.
      vim.treesitter.language.register("markdown", { "md", "mdx" })
      vim.treesitter.language.register("json", { "jsonc" })

      -- Install any wanted parsers that aren't present yet, skipping anything
      -- not offered by the registry (e.g. `jsonc`). `install()` is asynchronous
      -- and compiles via the `tree-sitter` CLI in the background.
      local installed = ts.get_installed("parsers")
      local available = ts.get_available()
      local missing = vim.tbl_filter(function(lang)
        return vim.tbl_contains(available, lang) and not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing, { summary = true })
      end

      -- On `main`, highlighting/indentation are no longer enabled through
      -- setup() options — start them ourselves whenever a buffer's language
      -- has an installed parser.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("nisi_treesitter", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang or not vim.tbl_contains(ts.get_installed("parsers"), lang) then
            return
          end

          -- Highlighting (provided by Neovim core).
          pcall(vim.treesitter.start, buf, lang)

          -- Treesitter-based indentation (experimental on `main`).
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Apply to buffers already loaded before this plugin finished setting up.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
        end
      end

      -- Textobjects also moved to an explicit setup + manual keymaps.
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true, -- automatically jump forward to matching textobj
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local select_keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      }
      for lhs, query in pairs(select_keymaps) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end
    end,
  },
}
