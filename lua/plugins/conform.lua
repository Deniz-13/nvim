return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" }, -- Dosya kaydedilmeden hemen önce tetiklenmesi için
	cmd = { "ConformInfo" }, -- :ConformInfo komutuyla durumu kontrol edebilirsin
	opts = {},
	config = function()
		require("conform").setup({
			format_on_save = {
				timeout_ms = 500, -- Çok uzun beklememesi için 500ms idealdir
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				-- Shell (Bash/Zsh)
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },

				-- Python (Ruff her şeyi tek başına yapar: isort + black)
				python = { "ruff_format" },

				-- C / C++
				c = { "clang-format" },
				cpp = { "clang-format" },

				-- Lua
				lua = { "stylua" },

				-- Go
				go = { "gofmt", "goimports" },

				-- PHP
				php = { "php_cs_fixer" },

				-- Ruby
				ruby = { "rubocop" },

				-- Javascript / Typescript / Web
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
			},
			-- Özel ayarlar (opsiyonel)
			formatters = {
				["clang-format"] = {
					prepend_args = { "-style=file", "-fallback-style=LLVM" },
				},
				shfmt = {
					prepend_args = { "-i", "2" }, -- 2 boşluk girinti için
				},
			},
		})

		-- Manuel formatlama için kısa yol (Leader + f)
		vim.keymap.set("n", "<leader>f", function()
			require("conform").format({ bufnr = 0 })
		end, { desc = "Dosyayı formatla" })
	end,
}
