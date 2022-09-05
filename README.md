# rime

> 自用的输入法词库，基于rime输入法，适用于Linux; Windows; Android平台。

## linux

### 安装

```shell
##安装rime
sudo pacman -S fcitx5-rime fcitx5-configtool fcitx5-gtk fcitx5-qt
##皮肤
sudo pacman -S fcitx5-material-color
```

- 环境变量

`vim ~/.pam_environment`

```shell
GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=\@im=fcitx
SDL_IM_MODULE DEFAULT=fcitx
```

```shell
##用户文件夹
~/.local/share/fcitx5/rime
cd ~/.local/share/fcitx5/
git clone git@github.com:luoxding/rime.git
```

## android

### 维护
数据的维护在termux中进行

- gitrime.sh
```
mv ../storage/shared/rime .
cd rime && chmod +x push.sh
./push.sh
cd ../
mv rime ../storage/shared/rime
```

