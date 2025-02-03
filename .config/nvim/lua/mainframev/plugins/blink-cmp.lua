local icons = require("mainframev.plugins.configs.icons")

---@type LazySpec[]
return {
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = {
      "rafamadriz/friendly-snippets",
      "giuxtaposition/blink-cmp-copilot",
    },
    version = "*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-h>"] = { "select_and_accept" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        -- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        -- ["<C-e>"] = { "hide", "fallback" },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
        kind_icons = {
          Copilot = icons.copilot,
          Text = icons.text,
          Method = icons.method,
          Function = icons.func,
          Constructor = icons.cog,

          Field = icons.field,
          Variable = icons.variable,
          Property = icons.property,

          Class = icons.class,
          Interface = icons.interface,
          Struct = icons.struct,
          Module = icons.module,

          Unit = icons.unit,
          Value = icons.value,
          Enum = icons.enum,
          EnumMember = icons.enum_number,

          Keyword = icons.keyword,
          Constant = icons.constant,

          Snippet = icons.snippet,
          Color = icons.color,
          File = icons.file,
          Reference = icons.reference,
          Folder = icons.folder,
          Event = icons.event,
          Operator = icons.operator,
          TypeParameter = icons.typeParameter,
        },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "copilot", "lsp", "snippets", "buffer" },
        providers = {
          lsp = {
            name = "lsp",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            fallbacks = { "snippets", "buffer" },
            score_offset = 90, -- the higher the number, the higher the priority
          },
          -- luasnip = {
          --   name = "luasnip",
          --   enabled = true,
          --   module = "blink.cmp.sources.snippets.luasnip",
          --   min_keyword_length = 2,
          --   fallbacks = { "snippets" },
          --   score_offset = 85, -- the higher the number, the higher the priority
          -- },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 2,
          },
          snippets = {
            name = "snippets",
            enabled = true,
            module = "blink.cmp.sources.snippets",
            score_offset = 80, -- the higher the number, the higher the priority
          },
          copilot = {
            name = "copilot",
            enabled = true,
            module = "blink-cmp-copilot",
            min_keyword_length = 2,
            score_offset = 100, -- the higher the number, the higher the priority
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          window = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },
        ghost_text = {
          enabled = true,
        },
        accept = {
          auto_brackets = { enabled = true },
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
        menu = {
          winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
          draw = {
            treesitter = { "lsp", "copilot" },
            padding = 1,
            gap = 1,
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return ctx.kind_icon .. " "
                end,
                highlight = function(ctx)
                  if ctx.item.source_name == "copilot" then
                    return "BlinkCmpKindCopilot"
                  end
                  return "BlinkCmpKind" .. ctx.kind
                end,
              },
              kind = {
                ellipsis = false,
                text = function(ctx)
                  if ctx.item.source_name == "copilot" then
                    local name = ctx.item.source_name
                    return name:sub(1, 1):upper() .. name:sub(2) .. " "
                  end
                  return ctx.kind .. " "
                end,
                highlight = function(ctx)
                  if ctx.item.source_name == "copilot" then
                    return "BlinkCmpKindCopilot"
                  end
                  return "BlinkCmpKind" .. ctx.kind
                end,
              },
              label = {
                width = { fill = true, max = 60 },
                text = function(ctx)
                  return ctx.label .. (ctx.label_detail or "")
                end,
                highlight = function(ctx)
                  -- label and label details
                  local highlights = {
                    {
                      0,
                      #ctx.label,
                      group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
                    },
                  }
                  if ctx.label_detail then
                    table.insert(highlights, {
                      #ctx.label + 1,
                      #ctx.label + #ctx.label_detail,
                      group = "BlinkCmpLabelDetail",
                    })
                  end

                  -- characters matched on the label by the fuzzy matcher
                  if ctx.label_matched_indices ~= nil then
                    for _, idx in ipairs(ctx.label_matched_indices) do
                      table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                    end
                  end

                  return highlights
                end,
              },

              label_description = {
                width = { max = 30 },
                text = function(ctx)
                  return ctx.label_description or ""
                end,
                highlight = "BlinkCmpLabelDescription",
              },
            },
          },
        },
      },
      fuzzy = {
        -- use_typo_resistance = true,
        -- use_frecency = true,
        -- use_proximity = true,
        -- max_items = 200,
        prebuilt_binaries = {
          download = false,
        },
      },
    },
    opts_extend = {
      "sources.default",
      "sources.providers",
    },
  },
}
