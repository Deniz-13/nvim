return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"stevearc/conform.nvim",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},

	config = function()
		-- 1. Görsel Ayarlar
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			float = {
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "✘",
					[vim.diagnostic.severity.WARN] = "▲",
					[vim.diagnostic.severity.HINT] = "⚑",
					[vim.diagnostic.severity.INFO] = "»",
				},
			},
		})

		-- 2. LspAttach (Keymapler ve Vurgulama)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("my.lsp", { clear = true }),
			callback = function(args)
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
				local buf = args.buf
				local map = function(mode, lhs, rhs)
					vim.keymap.set(mode, lhs, rhs, { buffer = buf })
				end

				map("n", "K", vim.lsp.buf.hover)
				map("n", "gd", vim.lsp.buf.definition)
				map("n", "gD", vim.lsp.buf.declaration)
				map("n", "gi", vim.lsp.buf.implementation)
				map("n", "go", vim.lsp.buf.type_definition)
				map("n", "gr", vim.lsp.buf.references)
				map("n", "gs", vim.lsp.buf.signature_help)
				map("n", "gl", vim.diagnostic.open_float)
				map("n", "<F2>", vim.lsp.buf.rename)
				map("n", "<F4>", vim.lsp.buf.code_action)
				map({ "n", "x" }, "<F3>", function()
					vim.lsp.buf.format({ async = true })
				end)

				if client:supports_method("textDocument/documentHighlight") then
					local highlight_augroup = vim.api.nvim_create_augroup("my.lsp.highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		-- 3. Mason ve Araç Kurulumları (LSP dışı araçlar)
		require("fidget").setup({})
		require("mason").setup()

		require("mason-tool-installer").setup({
			ensure_installed = {
				"stylua",
				"shfmt",
				"prettier",
				"clang-format",
				"shellcheck",
				"ruff", -- Python formatter
				"php-cs-fixer", -- PHP formatter
			},
			auto_update = true,
			run_on_start = true,
		})

		-- 4. Mason-Lspconfig (LSP Sunucuları)
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"gopls",
				"bashls",
				"basedpyright",
				"intelephense",
				"ts_ls",
			},
			automatic_installation = true,
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				["lua_ls"] = function()
					require("lspconfig").lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								runtime = { version = "LuaJIT" },
								diagnostics = { globals = { "vim" } },
								workspace = {
									library = vim.api.nvim_get_runtime_file("", true),
									checkThirdParty = false,
								},
							},
						},
					})
				end,

				["zls"] = function()
					require("lspconfig").zls.setup({
						capabilities = capabilities,
						root_dir = require("lspconfig").util.root_pattern(".git", "build.zig", "zls.json"),
					})
					vim.g.zig_fmt_parse_errors = 0
					vim.g.zig_fmt_autosave = 0
				end,
			},
		})

		-- 5. Cmp Ayarları
		local cmp = require("cmp")
		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
		})
	end,
}
