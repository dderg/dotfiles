require("formatter").setup(
  {
    logging = false,
    filetype = {
      javascript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      typescript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      ["typescriptreact"] = {
        -- prettier
        function()
          return {
            exe = "eslint_d",
            args = {vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      }
    }
  }
)

if vim.g.vscode then
    -- VSCode extension
else
    vim.api.nvim_exec(
        [[
            augroup FormatAutogroup
            autocmd!
            autocmd BufWritePost *.js,*.ts,*.tsx FormatWrite
            autocmd BufWritePost *.lua FormatWrite
            augroup END
        ]],
        true
    )
end
