FROM ubuntu:25.04

RUN apt-get update -qq ; \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata ; \
    apt-get install -y wget git vim zsh neovim curl gcc clang sshpass cmake make nodejs ripgrep cppman universal-ctags cscope && apt-get clean

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &&  chsh -s /usr/bin/zsh; \
    echo "alias vi='nvim'" >> ~/.zshrc && mkdir -p ${HOME}/.config/nvim  && \
    echo "set runtimepath^=${HOME}/.vim runtimepath+=${HOME}/.vim/after" >> ${HOME}/.config/nvim/init.vim && \
    echo "let &packpath=&runtimepath" >> ${HOME}/.config/nvim/init.vim && \
    echo "source ${HOME}/.vimrc" >> ${HOME}/.config/nvim/init.vim ; \
    curl -fLo ${HOME}/.vimrc --create-dirs https://gitee.com/zhangfuwen/GitNote/raw/master/vim/vimrc && \
    echo "downloaded vimrc" ;\
    mkdir -p ~/.vim && \
    curl -fLo ~/.vim/coc.vim --create-dirs https://gitee.com/zhangfuwen/GitNote/raw/master/vim/coc.vim && \
    curl -fLo ~/.vim/plugins.vim --create-dirs https://gitee.com/zhangfuwen/GitNote/raw/master/vim/plugins.vim; \
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; \
    echo "run nvim install" ;\
    nvim +PlugInstall +qall ;\
    echo "done"

COPY zsh_plugins.sh /tmp/zsh_plugins.sh

RUN test -d ~/.local/bin || mkdir ~/.local/bin && curl -L git.io/antigen > ~/.local/bin/antigen.zsh && cat /tmp/zsh_plugins.sh >> ~/.zshrc && rm /tmp/zsh_plugins.sh

