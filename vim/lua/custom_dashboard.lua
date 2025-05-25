local fill = { ',', ':', '-', '=', '#', '@' }

local ascii_heatmap = require('git-dashboard-nvim').setup {
    show_only_weeks_with_commits = false,
    show_contributions_count = true,
    use_current_branch = true,
    use_git_username_as_author = true,
    title = 'owner_with_repo_name',
    top_padding = 10,
    centered = false,
    empty_square = '.',
    colors = {
        days_and_months_labels = '#8fbcbb',
        empty_square_highlight = '#3b4252',
        filled_square_highlights = {
            '#88c0d0',
            '#a5adcb',
            '#8aadf4',
            '#8bd5ca',
            '#a6da95',
            '#eed49f'
        },
        branch_highlight = '#88c0d0',
        dashboard_title = '#88c0d0',
    },
    filled_squares = fill
}

local function in_git_repo()
  local handle = io.popen('git rev-parse --is-inside-work-tree 2>/dev/null')
  if handle == nil then return false end
  local result = handle:read('*a')
  handle:close()
  return result:match('true') ~= nil
end

local static_art = {
[[                                                     ;@             ]],
[[                                                     Saa ;7@        ]],
[[                                                  :s#LT@@7D@ ,:     ]],
[[                                 .;Lsls33CTLYsCUaPmF7lPkr78@b@7     ]],
[[                             .7tS35LvYls3t3CFCF5tvl3USsrrY8E@v      ]],
[[                           rXkFvrrr7iL77sCSUFCTlvTLsY77vr5@X@       ]],
[[                          @@tYLTLvlTvrCPaLirrrriLvTiTYTv7UbU@       ]],
[[         ;r7r:           @@XiiYTYY7Tt@@Fr;r77TvLvTLTTlYirEDU@L      ]],
[[        C5L5Fmb#Y;riT7Yra@##Zstl3UZSF3rs8rTLlvTYLvLTL77rLZ8FP@.     ]],
[[       5FivvTUtT7rr7r;;r;:;7vsC6lr;::;;;mPrvvLvLvLYYrr7sFXkECb@     ]],
[[      ;PLvr;:::::..,;;7TsFi;rrr;;;r7Yi7r5b77vvTiY7rr7TSFEUE#aF#@    ]],
[[      @85;:::;,,;75ak@@@@@ir7YrrriiTiYrYLbtr7iiTTlL3CXEPZXFDHaC#8   ]],
[[      @s;;;:;,Tk##8#b8@bS;r77rrrYYY77r77tXbTCtFUEXmEPEmZXaUF8XFS@b  ]],
[[    .X;;;;;:,;v@@@b@@#tr;77rrrrY77r7rrrYt5@mXmaEZEaEUEZXaZFFZbtFC@s ]],
[[    X7r;r;;7Pvr;368STr;rir7r7r7;;;rr7r7T5YH@EFZaXZXaXaEZXZmZF8UsCF@ ]],
[[   m3:3CrTr@@srr;;::;rr7rlLrrYTF@Ur;rr7ssLF#EDZaaZaXaXUXaXZXCb#53abr]],
[[  T#.,@HrF;XEr7r;;ssr7irTt;;Ss;@@@@S:rv5S53k7C#kUFXUXaEZXaaSCH#3UaZU]],
[[  @r 86F7Frrrrr;Y8@@r7rr6;:Fl L8Flb@YrtaC5Y#svTP#ESUaZFUFUFFCaFUUUFZ]],
[[ 7@ 7@;rLi7rrr;m@@@8;rrrY:3U  @HL .@@lC35sTPZLaX@@baFSFCUFUZmFFFUFFX]],
[[ av 5@.ri77rr7r7F8@X;rrrr78. ,@@L  @@kTtstLaml#@kHb@bP33FE6#EaFUFUFH]],
[[Z5r r@rYirrr7r7;;;L7rrY77St  .@@@ r@@Pvl5ttsUts#@HHkD#8@DPPZaFZFFFkm]],
[[@rr;v@@X;r;rr7rrrrr7r7iYrU;   @@D#6kbmY33F3C5Ssl#@kDHHP@D6aFFUFUFU@r]],
[[@Ls;;rs;;;;rviYri77rrrr7r3m:. s@EmPFSs53C3S3Sttls8@#b#8@6s8kFFUFm@@ ]],
[[r@@#tr,:;r,rrrrvrrrrrrr7rrl5Yirr;;rit#5C333S3C3Cl3D##8D8aLs#8FZ@@D  ]],
[[  3@@H#X5i;;;;rv;;;;;rrrr;rrrrirSPmEPF353USSUFF3CslLsLLL5CCvP@8U.   ]],
[[   .t##@@@@HEXFUZEZEP#D#HHHDHb@P#Dt5s5l38D3Stsl5ttlts3CFslT5v@v     ]],
[[      ;5PPD#@HXFFSFFFSFFaak#@#mF5TLvsFEZ3rirr;r7LFFLFXLr;;v5Cs@.    ]],
[[        7#FaZXUCssvTYvTlsSUESlvLYl5a#kLr;rrrrr;r7ZXFZr;vXPY3s5Z@    ]],
[[        r5rv33FXDk6EXaXUF3ts33FaPP#@E;;;7lrr7rr7YC@5;lk##@SsC3C@:   ]],
[[        ;6;;:r3stFUkk6D#66k#6kPkEFD#:::S@@a;rrrl7#@;##XXP@Us3C3#3   ]],
[[         b;5PE#ZriLSD6Z53FEZXZEZZFH;rsFL6@H;rrvlv@7;kDaP#@PT33CP#   ]],
[[         X@USaE@ssst5aUkP#6mFUCF3##5UX@7;Yrrr7LiFk;r;X8@@@Hl5C5bm   ]],
[[          @3UE@@sLsLLvsF@ilm@D6Pm@aTsP#;rrrr7TvL@Ct3tTU#bE3t355@L   ]],
[[          ;@a66TilLssst@,   3@8k@@SUa@irrrrrLLU@@8tFCCslTLl35SC@    ]],
[[           vs;r7ss55tF@r     ;@#@@8@@k;rrrYLsHH .HH3S3C53sC3FC@s    ]],
[[            @FSZ3EUFk@;       r.X7U3r;;r7slU@F    68X3UasSZFU@C     ]],
[[           ;@Ur@@i@Hl           @L;rYrlFFX@@r      bH@#P@8m@@T      ]],
[[                               ;,;s.;Zv75;                          ]],
}

local header_art = in_git_repo() and ascii_heatmap or static_art

local opts = {
    theme = 'doom',
    config = {
        header = header_art,
        center = {
            { action = '', desc = '', icon = '', key = 'n' },
        },
        footer = function()
            return {}
        end,
    },
}

require('dashboard').setup(opts)

vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function()
        if vim.bo.filetype ~= "dashboard" then
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "dashboard" then
                    vim.api.nvim_buf_delete(buf, { force = true })
                end
            end
        end
    end,
})
