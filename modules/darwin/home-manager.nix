# Darwin Home Manager 配置
{ config, pkgs, lib, username, home-manager, ... }:

{
  # Import home-manager darwin module
  imports = [
    home-manager.darwinModules.home-manager
  ];

  # Configure home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.${username} = { pkgs, ... }: {
      home.stateVersion = "25.05";
      home.username = username;
      home.homeDirectory = "/Users/${username}";

      programs.home-manager.enable = true;

      # Git configuration
      programs.git = {
        enable = true;
        userName = "Vitus";
        userEmail = "zhzvitus@gmail.com";

        extraConfig = {
          init.defaultBranch = "main";
          core.editor = "nano";
          pull.rebase = false;
          push.autoSetupRemote = true;
          diff.algorithm = "histogram";
          merge.conflictstyle = "zdiff3";
          rerere.enabled = true;
          color = {
            ui = "auto";
            diff = {
              meta = "yellow bold";
              frag = "magenta bold";
              old = "red bold";
              new = "green bold";
            };
          };
        };

        aliases = {
          st = "status";
          co = "checkout";
          ci = "commit";
          br = "branch";
          last = "log -1 HEAD";
          unstage = "reset HEAD --";
          amend = "commit --amend";
          graph = "log --oneline --graph --decorate --all";
          contributors = "shortlog --summary --numbered";
        };

        delta = {
          enable = true;
          options = {
            navigate = true;
            light = false;
            line-numbers = true;
            side-by-side = true;
          };
        };
      };

      # Neovim configuration
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = false;

        plugins = with pkgs.vimPlugins; [
          gruvbox-material
          nvim-tree-lua
          lualine-nvim
          vim-fugitive
          gitsigns-nvim
          nvim-lspconfig
          nvim-treesitter.withAllGrammars
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          telescope-nvim
          comment-nvim
          nvim-autopairs
          indent-blankline-nvim
        ];

        extraConfig = ''
          set number relativenumber
          set expandtab
          set tabstop=2
          set shiftwidth=2
          set softtabstop=2
          set smartindent
          set wrap
          set ignorecase
          set smartcase
          set termguicolors
          set signcolumn=yes
          set clipboard=unnamedplus
          set updatetime=300
          set timeoutlen=300
          set undofile
          set undodir=~/.vim/undodir
          set scrolloff=8

          colorscheme gruvbox-material

          let mapleader = " "
          nnoremap <leader>e :NvimTreeToggle<CR>
          nnoremap <leader>ff :Telescope find_files<CR>
          nnoremap <leader>fg :Telescope live_grep<CR>
          nnoremap <leader>fb :Telescope buffers<CR>
          nnoremap <leader>fh :Telescope help_tags<CR>
        '';
      };

      # Tmux configuration
      programs.tmux = {
        enable = true;
        terminal = "screen-256color";
        historyLimit = 10000;
        baseIndex = 1;
        escapeTime = 0;
        keyMode = "vi";

        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          {
            plugin = dracula;
            extraConfig = ''
              set -g @dracula-plugins "cpu-usage ram-usage time"
              set -g @dracula-show-powerline true
              set -g @dracula-refresh-rate 10
            '';
          }
        ];

        extraConfig = ''
          set -g mouse on
          bind | split-window -h
          bind - split-window -v
          unbind '"'
          unbind %
          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D
          bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
          set -g status-position top
        '';
      };

      # SSH configuration
      programs.ssh = {
        enable = true;
        addKeysToAgent = "yes";
        extraConfig = ''
          Host *
            UseKeychain yes
            IdentityFile ~/.ssh/id_ed25519
        '';
      };

      # Starship prompt
      programs.starship = {
        enable = true;
        settings = {
          format = ''
            [---](bold green)$username$hostname$directory$git_branch$git_status$cmd_duration
            [---](bold green)$character
          '';

          username = {
            show_always = true;
            format = "[$user]($style) ";
          };

          hostname = {
            ssh_only = false;
            format = "[@$hostname]($style) ";
            style = "bold dimmed green";
          };

          directory = {
            truncation_length = 3;
            truncate_to_repo = false;
            format = "[$path]($style)[$read_only]($read_only_style) ";
          };

          git_branch = {
            format = "[$symbol$branch(:$remote_branch)]($style) ";
          };

          character = {
            success_symbol = "[>](bold green)";
            error_symbol = "[>](bold red)";
          };

          cmd_duration = {
            min_time = 500;
            format = "[$duration]($style) ";
          };
        };
      };

      # User packages
      home.packages = with pkgs; [
        # Development tools
        nodejs_20
        yarn
        python3
        rustup
        go

        # CLI utilities
        wget
        curl
        unzip
        zip
        openssh
        gnupg
        pass

        # Fonts
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];

      # Environment variables
      home.sessionVariables = {
        EDITOR = "nano";
        VISUAL = "nano";
        BROWSER = "open";
        PAGER = "less";
        LESS = "-R";
        NODE_ENV = "development";
        LANG = "zh_CN.UTF-8";
        LC_ALL = "zh_CN.UTF-8";
      };
    };
  };
}
